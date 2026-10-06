import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Format angka gaya Indonesia: titik sebagai pemisah ribuan, koma sebagai
/// desimal. Dipakai untuk kolom bertipe money di database (mis. wgt_net dan
/// wgt_label pada Incoming Inspection).
///
/// Tipe money di SQL Server menyimpan 4 digit desimal, jadi format dan input
/// dibatasi 4 desimal juga supaya angka yang tampil sama dengan yang tersimpan.
const int moneyDecimalDigits = 4;
final NumberFormat _weightFormat = NumberFormat('#,##0.####', 'id_ID');
final NumberFormat _integerFormat = NumberFormat('#,##0', 'id_ID');

/// Ubah angka jadi teks berformat ribuan: 5565 -> "5.565".
String formatWeight(num value) => _weightFormat.format(value);

/// Kebalikan dari [formatWeight]. Mengembalikan null kalau teksnya kosong atau
/// tidak bisa dibaca sebagai angka, supaya "tidak diisi" bisa dibedakan dari
/// "nilainya nol".
double? parseWeight(String text) {
  final cleaned = text.replaceAll('.', '').replaceAll(',', '.').trim();
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

/// Memformat isian angka sambil diketik: pemisah ribuan disisipkan otomatis.
///
/// Koma adalah pemisah desimal. Titik yang *baru saja diketik* user juga
/// dianggap koma desimal (keyboard angka Android sering hanya punya titik),
/// sedangkan titik yang sudah ada di teks selalu pemisah ribuan hasil format
/// sebelumnya. Tanpa pembedaan ini, "1.234" + ketik "5" akan terbaca sebagai
/// "1,2345" alih-alih "12.345". Kursor selalu diletakkan di akhir;
/// untuk kolom angka pendek seperti berat, itu perilaku yang wajar dan jauh
/// lebih sederhana daripada menghitung ulang posisi kursor tiap format ulang.
class ThousandsInputFormatter extends TextInputFormatter {
  /// Batas digit di belakang koma. Ketikan yang melebihinya diabaikan.
  /// Pakai 0 untuk kolom bilangan bulat seperti rupiah tanpa sen.
  final int maxDecimalDigits;

  ThousandsInputFormatter({this.maxDecimalDigits = moneyDecimalDigits});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final input = newValue.text;
    if (input.isEmpty) return newValue;

    final decimalIndex =
        maxDecimalDigits > 0 ? _decimalIndex(oldValue, newValue) : -1;

    /// Sisakan digit saja: semua titik/koma lain dibuang, desimal dibatasi.
    final whole = StringBuffer();
    final decimal = StringBuffer();

    for (var i = 0; i < input.length; i++) {
      final unit = input.codeUnitAt(i);
      if (unit < 0x30 || unit > 0x39) continue;

      if (decimalIndex >= 0 && i > decimalIndex) {
        if (decimal.length < maxDecimalDigits) decimal.write(input[i]);
      } else {
        whole.write(input[i]);
      }
    }

    final wholeDigits = whole.toString();
    if (wholeDigits.isEmpty) return const TextEditingValue();

    final decimalDigits = decimalIndex >= 0 ? decimal.toString() : null;

    /// Kalau angkanya terlalu panjang untuk int, biarkan apa adanya daripada
    /// menghapus ketikan user.
    final wholeNumber = int.tryParse(wholeDigits);
    var text =
        wholeNumber == null ? wholeDigits : _integerFormat.format(wholeNumber);

    if (decimalDigits != null) text = '$text,$decimalDigits';

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// Posisi pemisah desimal di [newValue], atau -1 kalau tidak ada.
  ///
  /// Koma pertama selalu desimal. Kalau tidak ada koma, titik baru dianggap
  /// desimal hanya jika titik itu satu-satunya karakter yang barusan diketik.
  int _decimalIndex(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    final comma = text.indexOf(',');
    if (comma >= 0) return _hasDigitBefore(text, comma) ? comma : -1;

    final cursor = newValue.selection.baseOffset;
    final typedOneChar = text.length == oldValue.text.length + 1;
    if (typedOneChar &&
        cursor > 0 &&
        cursor <= text.length &&
        text[cursor - 1] == '.' &&
        _hasDigitBefore(text, cursor - 1)) {
      return cursor - 1;
    }

    return -1;
  }

  bool _hasDigitBefore(String text, int index) {
    for (var i = 0; i < index; i++) {
      final unit = text.codeUnitAt(i);
      if (unit >= 0x30 && unit <= 0x39) return true;
    }
    return false;
  }
}
