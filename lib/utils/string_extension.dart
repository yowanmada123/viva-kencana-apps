extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String capitalizeWords() {
    if (isEmpty) {
      return this;
    }
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  String removeTrailingZeros() {
    String value = this;
    if (value.contains('.')) {
      value = value.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return value;
  }

  String toComma2() {
    // Ubah string menjadi double dulu
    final number = double.tryParse(this.replaceAll(',', '.')) ?? 0.0;

    // Format dengan 2 angka di belakang koma
    String formatted = number.toStringAsFixed(2);

    // Ganti titik menjadi koma
    formatted = formatted.replaceAll('.', ',');

    return formatted;
  }
}
