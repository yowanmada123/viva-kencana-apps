import 'dart:convert';

class CustomerInfo {
  final String customerId;
  final String namaCustomer;
  CustomerInfo({required this.customerId, required this.namaCustomer});

  CustomerInfo copyWith({String? customerId, String? namaCustomer}) {
    return CustomerInfo(
      customerId: customerId ?? this.customerId,
      namaCustomer: namaCustomer ?? this.namaCustomer,
    );
  }

  Map<String, dynamic> toMap() {
    return {'CustomerId': customerId, 'NamaCustomer': namaCustomer};
  }

  factory CustomerInfo.fromMap(Map<String, dynamic> map) {
    return CustomerInfo(
      customerId: map['CustomerId'] ?? '',
      namaCustomer: map['NamaCustomer'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomerInfo.fromJson(String source) =>
      CustomerInfo.fromMap(json.decode(source));

  @override
  String toString() =>
      'CustomerInfo(customerId: $customerId, namaCustomer: $namaCustomer)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CustomerInfo &&
        other.customerId == customerId &&
        other.namaCustomer == namaCustomer;
  }

  @override
  int get hashCode => customerId.hashCode ^ namaCustomer.hashCode;
}
