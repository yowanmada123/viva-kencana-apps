class BinStockOpname {
  final String binId;

  BinStockOpname({required this.binId});

  factory BinStockOpname.fromMap(Map<String, dynamic> map) {
    return BinStockOpname(binId: map['bin_id'] ?? '');
  }
}
