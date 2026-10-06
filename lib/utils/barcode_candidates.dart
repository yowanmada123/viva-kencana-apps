import 'dart:convert';

/// Bentuk isi barcode yang berhasil dikenali.
enum ScanPayloadKind {
  /// Teks polos, mis. "97CE9523" dari label POSCO (Code 39) atau "VAG496V"
  /// dari QR Krakatau Steel.
  text,

  /// Objek JSON, mis. QR NAI:
  /// {"coilNo":"CC260819A030","BILLET":"605822A07", ...}
  json,

  /// Tautan, mis. QR Gunung Steel:
  /// https://centralapps.gunungsteel.com/view/crm/FK21618JO
  url,
}

/// Satu nilai yang mungkin merupakan No CRC.
///
/// Aplikasi TIDAK menebak mana yang benar - semua kandidat ditampilkan dan
/// petugas yang memilih. Ini sengaja: format label berbeda tiap pabrikan dan
/// akan terus bertambah, jadi menebak nama key hanya menunda masalah.
class ScanCandidate {
  /// Nilai yang dikirim ke server untuk dicek ke v_barcode_coil.
  final String value;

  /// Asal nilai ini: nama key JSON, posisi segmen URL, atau null untuk teks
  /// polos. Kalau satu nilai muncul di beberapa key, semuanya digabung -
  /// mis. "coilNo, CRC" pada label NAI.
  final String? label;

  /// Ditandai sebagai kemungkinan terkuat, supaya bisa diurutkan dan disorot
  /// di layar. Bukan keputusan final - petugas tetap bisa memilih yang lain.
  final bool likely;

  const ScanCandidate({required this.value, this.label, this.likely = false});

  ScanCandidate mergeLabel(String? other) {
    if (other == null || other.isEmpty) return this;
    if (label == null || label!.isEmpty) {
      return ScanCandidate(value: value, label: other, likely: likely);
    }
    if (label!.split(', ').contains(other)) return this;

    return ScanCandidate(
      value: value,
      label: '$label, $other',
      likely: likely,
    );
  }
}

/// Hasil pembacaan satu barcode, sudah dipecah jadi pilihan-pilihan.
class ScanPayload {
  /// Teks mentah persis seperti keluar dari scanner.
  final String raw;

  final ScanPayloadKind kind;
  final List<ScanCandidate> candidates;

  const ScanPayload({
    required this.raw,
    required this.kind,
    required this.candidates,
  });

  bool get isEmpty => candidates.isEmpty;

  /// true kalau hanya ada satu pilihan, sehingga dialog bisa tampil ringkas.
  bool get isSingle => candidates.length == 1;

  String get kindLabel {
    switch (kind) {
      case ScanPayloadKind.json:
        return 'JSON';
      case ScanPayloadKind.url:
        return 'URL';
      case ScanPayloadKind.text:
        return 'Teks';
    }
  }
}

/// Kata kunci pada nama key JSON atau segmen URL yang biasanya menandai nomor
/// coil. Dipakai hanya untuk MENGURUTKAN dan menyorot, bukan untuk memilih
/// otomatis.
final RegExp _likelyKey = RegExp(
  r'coil|crc|gulungan|prod.?no|no.?coil',
  caseSensitive: false,
);

/// Pecah isi barcode jadi daftar kandidat No CRC.
///
/// Tiga bentuk yang ditangani sesuai temuan di lapangan:
///
///   teks  "97CE9523"                          -> satu pilihan
///   JSON  {"coilNo":"CC...","BILLET":"..."}   -> satu pilihan per key
///   URL   https://host/view/crm/FK21618JO     -> satu pilihan per segmen
///
/// Bentuk lain tetap aman: apa pun yang tidak dikenali diperlakukan sebagai
/// teks polos, jadi scan tidak pernah gagal total.
ScanPayload parseScanPayload(String raw) {
  final text = raw.trim();

  if (text.isEmpty) {
    return const ScanPayload(
      raw: '',
      kind: ScanPayloadKind.text,
      candidates: [],
    );
  }

  final fromJson = _tryJson(text);
  if (fromJson != null) return fromJson;

  final fromUrl = _tryUrl(text);
  if (fromUrl != null) return fromUrl;

  /// Teks polos yang mengandung '/' juga dipecah - sebagian label menulis
  /// beberapa nomor sekaligus, mis. "BHS5061-1/97CE9523". Teks utuhnya tetap
  /// jadi pilihan pertama karena untuk teks biasa itu yang paling sering
  /// benar; potongannya menyusul di bawah supaya tidak ada yang hilang.
  final parts = _splitBySlash(text).toList();

  return ScanPayload(
    raw: text,
    kind: ScanPayloadKind.text,
    candidates: _dedupe([
      ScanCandidate(value: text, likely: true),
      for (final part in parts)
        ScanCandidate(value: part, label: 'potongan'),
    ]),
  );
}

ScanPayload? _tryJson(String text) {
  if (!text.startsWith('{') && !text.startsWith('[')) return null;

  dynamic decoded;
  try {
    decoded = json.decode(text);
  } catch (_) {
    return null;
  }

  final flat = <String, String>{};
  _flatten(decoded, '', flat);
  if (flat.isEmpty) return null;

  final candidates = _dedupe(
    flat.entries
        .map(
          (e) => ScanCandidate(
            value: e.value,
            label: e.key,
            likely: _likelyKey.hasMatch(e.key),
          ),
        )
        .toList(),
  );

  if (candidates.isEmpty) return null;

  return ScanPayload(
    raw: text,
    kind: ScanPayloadKind.json,
    candidates: candidates,
  );
}

ScanPayload? _tryUrl(String text) {
  final uri = Uri.tryParse(text);
  if (uri == null || !uri.hasScheme) return null;
  if (!uri.scheme.startsWith('http')) return null;

  final items = <ScanCandidate>[];

  /// Host ikut ditampilkan. Pada tautan yang isinya cuma domain + fragment,
  /// mis. https://magintek.my.id/#portfolio, tidak ada segmen path sama
  /// sekali - kalau host dibuang, tidak ada pilihan yang tersisa.
  final host = uri.host.trim();
  if (host.isNotEmpty) {
    items.add(ScanCandidate(value: host, label: 'host'));
  }

  final segments =
      uri.pathSegments.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  for (var i = 0; i < segments.length; i++) {
    items.add(
      ScanCandidate(
        value: segments[i],
        label: 'segmen ${i + 1}',

        /// Segmen terakhir hampir selalu identitasnya.
        likely: i == segments.length - 1 || _likelyKey.hasMatch(segments[i]),
      ),
    );
  }

  /// Bagian setelah '#'. Tanda pagarnya sendiri tidak ikut jadi nilai, karena
  /// yang dicek ke database adalah isinya. Fragment bisa berisi beberapa
  /// bagian bertanda '/', jadi dipecah juga.
  final fragmentParts =
      uri.fragment.split('/').map((e) => e.trim()).where((e) => e.isNotEmpty);

  for (final part in fragmentParts) {
    items.add(
      ScanCandidate(
        value: part,
        label: 'fragment (#)',

        /// Kalau tautan tidak punya segmen path, fragment-lah satu-satunya
        /// bagian yang membedakan - jadi itu yang paling mungkin.
        likely: segments.isEmpty || _likelyKey.hasMatch(part),
      ),
    );
  }

  /// Sebagian tautan menaruh identitas di query, mis. ?coil=ABC123.
  uri.queryParameters.forEach((key, value) {
    final clean = value.trim();
    if (clean.isEmpty) return;
    items.add(
      ScanCandidate(value: clean, label: key, likely: _likelyKey.hasMatch(key)),
    );
  });

  /// Pemecahan harfiah atas teks mentahnya, bukan lewat Uri.
  ///
  /// Uri melakukan normalisasi: segmen di-percent-decode, bagian yang dianggap
  /// bukan path diabaikan, dan bentuk tautan yang tidak lazim bisa kehilangan
  /// potongannya. Pemecahan mentah ini memastikan TIDAK ADA bagian setelah '/'
  /// yang hilang, apa pun isinya - termasuk yang bertanda '-', '.', atau '_'.
  /// Nilai yang kebetulan sama dengan hasil Uri akan digabung oleh _dedupe.
  for (final part in _splitBySlash(text)) {
    items.add(ScanCandidate(value: part, label: 'potongan'));
  }

  /// Tautan utuh selalu disertakan paling bawah sebagai jaring pengaman,
  /// supaya tidak ada bentuk URL yang membuat pilihan jadi kosong.
  items.add(ScanCandidate(value: text, label: 'URL utuh'));

  return ScanPayload(
    raw: text,
    kind: ScanPayloadKind.url,
    candidates: _dedupe(items),
  );
}

/// Pecah teks per '/' dan kembalikan potongan yang tidak kosong, apa adanya.
///
/// Tidak ada yang dipangkas selain spasi: potongan seperti "184110020-2.3"
/// atau "ABC_123" tetap utuh, karena justru bentuk seperti itulah yang biasa
/// dipakai sebagai nomor coil.
///
/// Satu-satunya yang dibuang adalah token skema ("https:", "http:") yang tidak
/// mungkin menjadi No CRC.
Iterable<String> _splitBySlash(String text) {
  return text
      .split('/')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .where((e) => e.toLowerCase() != 'https:' && e.toLowerCase() != 'http:');
}

/// Ratakan objek bersarang jadi satu level dengan key bertitik, supaya JSON
/// seperti {"material":{"id":"X"}} tetap menghasilkan kandidat "material.id".
void _flatten(dynamic node, String prefix, Map<String, String> out) {
  if (node is Map) {
    node.forEach((key, value) {
      final name = prefix.isEmpty ? '$key' : '$prefix.$key';
      _flatten(value, name, out);
    });
    return;
  }

  if (node is List) {
    for (var i = 0; i < node.length; i++) {
      _flatten(node[i], prefix.isEmpty ? '$i' : '$prefix.$i', out);
    }
    return;
  }

  if (node == null) return;

  final value = node.toString().trim();
  if (value.isEmpty) return;

  out[prefix.isEmpty ? 'value' : prefix] = value;
}

/// Gabungkan kandidat bernilai sama. Pada label NAI, "coilNo" dan "CRC"
/// berisi nilai yang persis sama - lebih berguna ditampilkan sebagai satu
/// pilihan bertuliskan "coilNo, CRC" daripada dua baris kembar.
///
/// Yang ditandai [ScanCandidate.likely] diletakkan di atas.
List<ScanCandidate> _dedupe(List<ScanCandidate> items) {
  final merged = <String, ScanCandidate>{};

  for (final item in items) {
    final value = item.value.trim();
    if (value.isEmpty) continue;

    final existing = merged[value];
    if (existing == null) {
      merged[value] = ScanCandidate(
        value: value,
        label: item.label,
        likely: item.likely,
      );
    } else {
      merged[value] = existing
          .mergeLabel(item.label)
          .copyLikely(existing.likely || item.likely);
    }
  }

  /// List.sort pada Dart tidak dijamin stabil, jadi urutan asal dipakai
  /// sebagai pemecah seri. Tanpa ini, pilihan cadangan seperti "URL utuh"
  /// bisa naik ke atas menggeser pilihan yang lebih masuk akal.
  final ordered = merged.values.toList();
  final rank = {for (var i = 0; i < ordered.length; i++) ordered[i].value: i};

  ordered.sort((a, b) {
    if (a.likely != b.likely) return a.likely ? -1 : 1;
    return rank[a.value]!.compareTo(rank[b.value]!);
  });

  return ordered;
}

extension on ScanCandidate {
  ScanCandidate copyLikely(bool value) =>
      ScanCandidate(value: this.value, label: label, likely: value);
}
