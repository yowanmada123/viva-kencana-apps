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
}
