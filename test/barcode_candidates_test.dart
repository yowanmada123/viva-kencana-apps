import 'package:flutter_test/flutter_test.dart';
import 'package:vivakencanaapp/utils/barcode_candidates.dart';

/// Contoh isi barcode di bawah ini diambil apa adanya dari label coil yang
/// benar-benar dipakai di lapangan, supaya parser diuji terhadap data nyata
/// dan bukan terhadap contoh karangan.
void main() {
  group('teks polos', () {
    test('Code 39 label POSCO', () {
      final result = parseScanPayload('97CE9523');

      expect(result.kind, ScanPayloadKind.text);
      expect(result.isSingle, isTrue);
      expect(result.candidates.single.value, '97CE9523');
      expect(result.candidates.single.likely, isTrue);
    });

    test('QR label Krakatau Steel', () {
      final result = parseScanPayload('VAG496V');

      expect(result.kind, ScanPayloadKind.text);
      expect(result.candidates.single.value, 'VAG496V');
    });

    test('spasi dan baris baru dibersihkan', () {
      final result = parseScanPayload('  VAG496V \n');
      expect(result.candidates.single.value, 'VAG496V');
    });

    test('teks polos bergaris miring ikut dipecah tanpa kehilangan apa pun', () {
      final result = parseScanPayload('BHS5061-1/97CE9523');

      final values = result.candidates.map((e) => e.value).toList();

      /// Teks utuh tetap jadi pilihan pertama.
      expect(result.candidates.first.value, 'BHS5061-1/97CE9523');

      /// Kedua potongannya tetap tersedia.
      expect(values, contains('BHS5061-1'));
      expect(values, contains('97CE9523'));
    });
  });

  group('JSON', () {
    const naiQr = '''
{
  "coilNo":"CC260819A030",
  "BILLET":"605822A07",
  "HRC":"PP260728C048",
  "CRC":"CC260819A030"
}
''';

    test('QR label NAI dipecah per key', () {
      final result = parseScanPayload(naiQr);

      expect(result.kind, ScanPayloadKind.json);

      /// coilNo dan CRC bernilai sama, jadi digabung jadi satu pilihan.
      expect(result.candidates.length, 3);

      final values = result.candidates.map((e) => e.value).toList();
      expect(values, contains('CC260819A030'));
      expect(values, contains('605822A07'));
      expect(values, contains('PP260728C048'));
    });

    test('nilai kembar digabung labelnya dan naik ke atas', () {
      final result = parseScanPayload(naiQr);
      final first = result.candidates.first;

      expect(first.value, 'CC260819A030');
      expect(first.likely, isTrue);
      expect(first.label, contains('coilNo'));
      expect(first.label, contains('CRC'));
    });

    test('objek bersarang jadi key bertitik', () {
      final result = parseScanPayload('{"material":{"id":"ABC123"}}');

      expect(result.kind, ScanPayloadKind.json);
      expect(result.candidates.single.value, 'ABC123');
      expect(result.candidates.single.label, 'material.id');
    });

    test('JSON rusak jatuh ke teks polos, tidak error', () {
      final result = parseScanPayload('{"coilNo":');

      expect(result.kind, ScanPayloadKind.text);
      expect(result.candidates.single.value, '{"coilNo":');
    });
  });

  group('URL', () {
    test('QR label Gunung Steel dipecah per segmen, host ikut', () {
      final result = parseScanPayload(
        'https://centralapps.gunungsteel.com/view/crm/FK21618JO',
      );

      expect(result.kind, ScanPayloadKind.url);

      final values = result.candidates.map((e) => e.value).toList();
      expect(values, containsAll(['view', 'crm', 'FK21618JO']));
      expect(values, contains('centralapps.gunungsteel.com'));
    });

    test('segmen terakhir ditandai sebagai kemungkinan terkuat', () {
      final result = parseScanPayload(
        'https://centralapps.gunungsteel.com/view/crm/FK21618JO',
      );

      expect(result.candidates.first.value, 'FK21618JO');
      expect(result.candidates.first.likely, isTrue);
    });

    test('URL tanpa path, hanya domain dan fragment', () {
      final result = parseScanPayload('https://magintek.my.id/#portfolio');

      expect(result.kind, ScanPayloadKind.url);

      final values = result.candidates.map((e) => e.value).toList();
      expect(values, contains('magintek.my.id'));
      expect(values, contains('portfolio'));

      /// Tanpa segmen path, fragment-lah yang paling membedakan.
      expect(result.candidates.first.value, 'portfolio');
      expect(result.candidates.first.likely, isTrue);

      /// Bukan lagi satu pilihan berisi URL panjang saja.
      expect(result.isSingle, isFalse);
    });

    test('fragment bertanda garis miring ikut dipecah', () {
      final result = parseScanPayload('https://contoh.id/#/coil/ABC123');

      final values = result.candidates.map((e) => e.value).toList();
      expect(values, containsAll(['coil', 'ABC123']));
    });

    test('URL utuh selalu tersedia sebagai pilihan terakhir', () {
      const url = 'https://magintek.my.id/#portfolio';
      final result = parseScanPayload(url);

      expect(result.candidates.last.value, url);
      expect(result.candidates.last.label, 'URL utuh');
    });

    test('potongan bertanda - dan . tidak hilang', () {
      final result = parseScanPayload(
        'https://contoh.id/pl/BHS5061-1/184110020-2.3',
      );

      final values = result.candidates.map((e) => e.value).toList();
      expect(values, contains('BHS5061-1'));
      expect(values, contains('184110020-2.3'));

      /// Tidak dipecah lagi per '-' atau '.'.
      expect(values, isNot(contains('184110020')));
      expect(values, isNot(contains('2.3')));
    });

    test('skema tidak ikut jadi pilihan', () {
      final result = parseScanPayload('https://contoh.id/ABC123');

      final values = result.candidates.map((e) => e.value).toList();
      expect(values, isNot(contains('https:')));
    });

    test('query param ikut jadi pilihan', () {
      final result = parseScanPayload('https://contoh.id/cek?coil=ABC123');

      final values = result.candidates.map((e) => e.value).toList();
      expect(values, contains('ABC123'));
    });
  });

  group('kasus tepi', () {
    test('teks kosong tidak menghasilkan pilihan', () {
      expect(parseScanPayload('   ').isEmpty, isTrue);
    });

    test('teks yang bukan http tetap dianggap teks polos', () {
      final result = parseScanPayload('mailto:a@b.c');
      expect(result.kind, ScanPayloadKind.text);
    });
  });
}
