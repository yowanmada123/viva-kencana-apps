import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vivakencanaapp/utils/number_input.dart';

String _type(ThousandsInputFormatter formatter, String text) {
  return formatter
      .formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: text),
      )
      .text;
}

/// Simulasi mengetik satu karakter demi satu karakter di akhir teks, persis
/// seperti user di keyboard: tiap ketikan diformat ulang sebelum ketikan berikut.
String _typeEach(ThousandsInputFormatter formatter, String keys) {
  var value = TextEditingValue.empty;
  for (final key in keys.split('')) {
    final text = value.text + key;
    value = formatter.formatEditUpdate(
      value,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );
  }
  return value.text;
}

void main() {
  group('ThousandsInputFormatter', () {
    final formatter = ThousandsInputFormatter();

    test('mengetik angka panjang tidak berubah jadi desimal', () {
      expect(_typeEach(formatter, '1222434'), '1.222.434');
      expect(_typeEach(formatter, '123456789012'), '123.456.789.012');
    });

    test('mengetik 1222434,54 jadi 1.222.434,54', () {
      expect(_typeEach(formatter, '1222434,54'), '1.222.434,54');
    });

    test('tombol titik yang diketik jadi koma desimal', () {
      expect(_typeEach(formatter, '1222434.54'), '1.222.434,54');
    });

    test('desimal dibatasi 4 digit saat mengetik', () {
      expect(_typeEach(formatter, '2,523523'), '2,5235');
    });

    test('paste teks berformat Indonesia', () {
      expect(_type(formatter, '1.222.434,54'), '1.222.434,54');
    });

    test('menyisipkan pemisah ribuan', () {
      expect(_type(formatter, '1234567'), '1.234.567');
    });

    test('titik dan koma jadi koma desimal', () {
      expect(_type(formatter, '1234,5'), '1.234,5');
      expect(_typeEach(formatter, '2.5'), '2,5');
    });

    test('desimal dibatasi 4 digit', () {
      expect(_type(formatter, '2,523523234324'), '2,5235');
    });

    test('tanpa desimal untuk rupiah bulat', () {
      final rupiah = ThousandsInputFormatter(maxDecimalDigits: 0);
      expect(_type(rupiah, '15000,75'), '1.500.075');
    });
  });

  group('formatWeight / parseWeight', () {
    test('tidak membuang presisi 4 desimal', () {
      expect(formatWeight(2.5235), '2,5235');
      expect(parseWeight(formatWeight(2.5235)), 2.5235);
    });

    test('kosong jadi null', () {
      expect(parseWeight(''), isNull);
    });
  });
}
