import 'package:flutter_test/flutter_test.dart';
import 'package:vivakencanaapp/bloc/receive_warehouse/rw_receive/rw_receive_bloc.dart';

/// RwReceiveBloc.parseTrId mengubah isi barcode hasil scan menjadi tr_id.
///
/// Fungsi ini statis dan murni (tanpa API, tanpa state), jadi tidak butuh
/// mock: cukup panggil, lalu bandingkan hasilnya dengan yang diharapkan.
void main() {
  group('barcode berisi tr_id mentah (label CODE128 dari web)', () {
    test('dikembalikan apa adanya', () {
      expect(RwReceiveBloc.parseTrId('TR2411000123'), 'TR2411000123');
    });

    test('spasi dan enter di awal/akhir dibuang', () {
      /// Beberapa scanner menambahkan \n atau spasi di akhir hasil scan.
      expect(RwReceiveBloc.parseTrId('  TR2411000123\n'), 'TR2411000123');
    });
  });

  group('barcode berisi JSON', () {
    test('mengambil nilai key tr_id', () {
      expect(
        RwReceiveBloc.parseTrId('{"tr_id":"TR2411000123","qty":10}'),
        'TR2411000123',
      );
    });

    test('nilai tr_id ikut di-trim', () {
      expect(
        RwReceiveBloc.parseTrId('{"tr_id":" TR2411000123 "}'),
        'TR2411000123',
      );
    });

    test('tr_id berupa angka diubah menjadi teks', () {
      expect(RwReceiveBloc.parseTrId('{"tr_id":12345}'), '12345');
    });

    test('JSON tanpa key tr_id mengembalikan teks aslinya', () {
      expect(RwReceiveBloc.parseTrId('{"no":"X"}'), '{"no":"X"}');
    });

    test('tr_id bernilai null mengembalikan teks aslinya', () {
      expect(RwReceiveBloc.parseTrId('{"tr_id":null}'), '{"tr_id":null}');
    });
  });

  group('input rusak atau kosong', () {
    test('diawali { tapi bukan JSON valid: tidak crash, kembalikan teks', () {
      expect(RwReceiveBloc.parseTrId('{bukan json'), '{bukan json');
    });

    test('teks kosong menjadi string kosong', () {
      expect(RwReceiveBloc.parseTrId(''), isEmpty);
    });

    test('hanya spasi menjadi string kosong', () {
      /// String kosong inilah yang membuat bloc memunculkan pesan
      /// "Barcode tidak berisi tr_id yang bisa dibaca".
      expect(RwReceiveBloc.parseTrId('   '), isEmpty);
    });
  });
}
