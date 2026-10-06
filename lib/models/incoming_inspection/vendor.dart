import 'dart:convert';

/// Data vendor dari tabel `vendor` (db fg_inv).
/// Dipakai untuk filter pencarian sebelum mengambil data v_barcode_coil.
class Vendor {
  final String vendorId;
  final String vendorName;

  Vendor({required this.vendorId, required this.vendorName});

  Vendor copyWith({String? vendorId, String? vendorName}) {
    return Vendor(
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
    );
  }

  Map<String, dynamic> toMap() {
    return {'vendor_id': vendorId, 'vendor_name': vendorName};
  }

  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor(
      vendorId: map['vendor_id']?.toString() ?? '',
      vendorName: map['vendor_name']?.toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Vendor.fromJson(String source) => Vendor.fromMap(json.decode(source));

  /// Label yang ditampilkan di dropdown pencarian: "V001 - PT Sumber Baja"
  String get label =>
      vendorName.isEmpty ? vendorId : '$vendorId - $vendorName';

  @override
  String toString() => 'Vendor(vendor_id: $vendorId, vendor_name: $vendorName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vendor && other.vendorId == vendorId;
  }

  @override
  int get hashCode => vendorId.hashCode;
}
