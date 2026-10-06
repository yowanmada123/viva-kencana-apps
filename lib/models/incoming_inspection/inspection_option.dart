import 'dart:convert';

/// Semua isi dropdown form header Incoming Inspection, datang dari satu
/// panggilan `GET api/getInspectionOption`.
///
/// Sebelumnya pilihan ini di-hardcode di aplikasi. Sekarang server yang
/// menentukan, jadi kalau master crew berubah atau kode cuaca ditambah,
/// aplikasi tidak perlu dirilis ulang.
class InspectionOption {
  final List<Crew> crew;
  final List<ShiftOption> shift;
  final List<OptionItem> cuaca;
  final List<OptionItem> tAtap;
  final List<OptionItem> tKondisi;
  final List<OptionItem> storage;
  final List<OptionItem> kondisiCrc;

  InspectionOption({
    required this.crew,
    required this.shift,
    required this.cuaca,
    required this.tAtap,
    required this.tKondisi,
    required this.storage,
    required this.kondisiCrc,
  });

  factory InspectionOption.fromMap(Map<String, dynamic> map) {
    return InspectionOption(
      crew: _list(map['crew'], Crew.fromMap),
      shift: _list(map['shift'], ShiftOption.fromMap),
      cuaca: _list(map['cuaca'], OptionItem.fromMap),
      tAtap: _list(map['t_atap'], OptionItem.fromMap),
      tKondisi: _list(map['t_kondisi'], OptionItem.fromMap),
      storage: _list(map['storage'], OptionItem.fromMap),
      kondisiCrc: _list(map['kondisi_crc'], OptionItem.fromMap),
    );
  }

  static List<T> _list<T>(
    dynamic source,
    T Function(Map<String, dynamic>) builder,
  ) {
    if (source is! List) return const [];
    return source
        .whereType<Map>()
        .map((e) => builder(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Bentuk {value: label} yang langsung bisa dipakai BaseDropdownButton.
  static Map<String, String> asMap(List<OptionItem> items) {
    return {for (final item in items) item.value: item.label};
  }
}

/// Satu pilihan sederhana: nilai yang dikirim ke server + label untuk user.
/// Contoh: {"value": "CGL1", "label": "CGL 1"}.
class OptionItem {
  final String value;
  final String label;

  OptionItem({required this.value, required this.label});

  factory OptionItem.fromMap(Map<String, dynamic> map) {
    final value = map['value']?.toString().trim() ?? '';
    final label = map['label']?.toString().trim() ?? '';
    return OptionItem(value: value, label: label.isEmpty ? value : label);
  }

  Map<String, dynamic> toMap() => {'value': value, 'label': label};

  @override
  String toString() => 'OptionItem($value: $label)';

  @override
  bool operator ==(Object other) =>
      other is OptionItem && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Baris tabel `crew` yang section_id-nya ENT. Yang disimpan ke
/// inspection_hdr.crew_id adalah [crewId], yang ditampilkan [crewName].
class Crew {
  final String millId;
  final String crewId;
  final String crewName;

  Crew({required this.millId, required this.crewId, required this.crewName});

  factory Crew.fromMap(Map<String, dynamic> map) {
    return Crew(
      millId: map['mill_id']?.toString().trim() ?? '',
      crewId: map['crew_id']?.toString().trim() ?? '',
      crewName: map['crew_name']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'mill_id': millId,
    'crew_id': crewId,
    'crew_name': crewName,
  };

  String toJson() => json.encode(toMap());

  String get label => crewName.isEmpty ? crewId : crewName;

  @override
  bool operator ==(Object other) => other is Crew && other.crewId == crewId;

  @override
  int get hashCode => crewId.hashCode;
}

/// Baris tabel `shift`. [descr] berisi rentang jam, mis. "07:00 - 15:00",
/// dipakai untuk mengisi otomatis jam mulai dan selesai.
class ShiftOption {
  final String millId;
  final String shiftNum;
  final String descr;

  ShiftOption({
    required this.millId,
    required this.shiftNum,
    required this.descr,
  });

  factory ShiftOption.fromMap(Map<String, dynamic> map) {
    return ShiftOption(
      millId: map['mill_id']?.toString().trim() ?? '',
      shiftNum: map['shift_num']?.toString().trim() ?? '',
      descr: map['descr']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'mill_id': millId,
    'shift_num': shiftNum,
    'descr': descr,
  };

  String get label => descr.isEmpty ? shiftNum : '$shiftNum ($descr)';

  /// Ambil jam mulai dan selesai dari descr "07:00 - 15:00".
  /// Mengembalikan null kalau formatnya bukan itu, supaya jam tidak diisi
  /// dengan nilai ngawur.
  ({int hour, int minute})? get startTime => _parse(0);
  ({int hour, int minute})? get endTime => _parse(1);

  ({int hour, int minute})? _parse(int index) {
    final parts = descr.split('-');
    if (parts.length < 2) return null;

    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(parts[index].trim());
    if (match == null) return null;

    return (
      hour: int.parse(match.group(1)!),
      minute: int.parse(match.group(2)!),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ShiftOption && other.shiftNum == shiftNum;

  @override
  int get hashCode => shiftNum.hashCode;
}
