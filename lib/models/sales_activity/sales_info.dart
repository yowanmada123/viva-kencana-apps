import 'dart:convert';

class SalesInfo {
  final List<SalesData> salesData;
  final LastVisit? lastVisit;

  SalesInfo({required this.salesData, this.lastVisit});

  SalesInfo copyWith({
    List<SalesData>? salesData,
    LastVisit? lastVisit,
  }) {
    return SalesInfo(
      salesData: salesData ?? this.salesData,
      lastVisit: lastVisit ?? this.lastVisit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'salesData': salesData.map((x) => x.toMap()).toList(),
      'lastVisit': lastVisit?.toMap(),
    };
  }

  factory SalesInfo.fromMap(Map<String, dynamic> map) {
    return SalesInfo(
      salesData: List<SalesData>.from(
        map['salesData']?.map((x) => SalesData.fromMap(x)),
      ),
      lastVisit: map['lastVisit'] != null
          ? LastVisit.fromMap(map['lastVisit'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SalesInfo.fromJson(String source) =>
      SalesInfo.fromMap(json.decode(source));

  @override
  String toString() =>
      'SalesInfo(salesData: $salesData, lastVisit: $lastVisit)';

  @override
  int get hashCode => salesData.hashCode ^ lastVisit.hashCode;
}

class LastVisit {
  final String trId;
  final String trDate;
  LastVisit({required this.trId, required this.trDate});

  LastVisit copyWith({String? trId, String? trDate}) {
    return LastVisit(trId: trId ?? this.trId, trDate: trDate ?? this.trDate);
  }

  Map<String, dynamic> toMap() {
    return {'tr_id': trId, 'tr_date': trDate};
  }

  factory LastVisit.fromMap(Map<String, dynamic> map) {
    return LastVisit(trId: map['tr_id'] ?? '', trDate: map['tr_date'] ?? '');
  }

  String toJson() => json.encode(toMap());

  factory LastVisit.fromJson(String source) =>
      LastVisit.fromMap(json.decode(source));

  @override
  String toString() => 'LastVisit(trId: $trId, trDate: $trDate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LastVisit && other.trId == trId && other.trDate == trDate;
  }

  @override
  int get hashCode => trId.hashCode ^ trDate.hashCode;
}

class SalesData {
  final String salesId;
  final String namaSales;
  final String alamat;
  final String kota;
  final String telepon;
  final String region;
  final String email;
  final String officeId;
  final String office;
  final String officeLat;
  final String officeLng;
  SalesData({
    required this.salesId,
    required this.namaSales,
    required this.alamat,
    required this.kota,
    required this.telepon,
    required this.region,
    required this.email,
    required this.officeId,
    required this.office,
    required this.officeLat,
    required this.officeLng,
  });

  SalesData copyWith({
    String? salesId,
    String? namaSales,
    String? alamat,
    String? kota,
    String? telepon,
    String? region,
    String? email,
    String? officeId,
    String? office,
    String? officeLat,
    String? officeLng,
  }) {
    return SalesData(
      salesId: salesId ?? this.salesId,
      namaSales: namaSales ?? this.namaSales,
      alamat: alamat ?? this.alamat,
      kota: kota ?? this.kota,
      telepon: telepon ?? this.telepon,
      region: region ?? this.region,
      email: email ?? this.email,
      officeId: officeId ?? this.officeId,
      office: office ?? this.office,
      officeLat: officeLat ?? this.officeLat,
      officeLng: officeLng ?? this.officeLng,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'SalesId': salesId,
      'NamaSales': namaSales,
      'Alamat': alamat,
      'Kota': kota,
      'Telepon': telepon,
      'region': region,
      'e_mail': email,
      'office_id': officeId,
      'office': office,
      'office_lat': officeLat,
      'office_lng': officeLng,
    };
  }

  factory SalesData.fromMap(Map<String, dynamic> map) {
    return SalesData(
      salesId: map['SalesId'] ?? '',
      namaSales: map['NamaSales'] ?? '',
      alamat: map['Alamat'] ?? '',
      kota: map['Kota'] ?? '',
      telepon: map['Telepon'] ?? '',
      region: map['region'] ?? '',
      email: map['e_mail'] ?? '',
      officeId: map['office_id'] ?? '',
      office: map['office'] ?? '',
      officeLat: map['office_lat'] ?? '',
      officeLng: map['office_lng'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SalesData.fromJson(String source) =>
      SalesData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SalesData(salesId: $salesId, namaSales: $namaSales, alamat: $alamat, kota: $kota, telepon: $telepon, region: $region, email: $email, officeId: $officeId, office: $office, officeLat: $officeLat, officeLng: $officeLng)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SalesData &&
        other.salesId == salesId &&
        other.namaSales == namaSales &&
        other.alamat == alamat &&
        other.kota == kota &&
        other.telepon == telepon &&
        other.region == region &&
        other.email == email &&
        other.officeId == officeId &&
        other.office == office &&
        other.officeLat == officeLat &&
        other.officeLng == officeLng;
  }

  @override
  int get hashCode {
    return salesId.hashCode ^
        namaSales.hashCode ^
        alamat.hashCode ^
        kota.hashCode ^
        telepon.hashCode ^
        region.hashCode ^
        email.hashCode ^
        officeId.hashCode ^
        office.hashCode ^
        officeLat.hashCode ^
        officeLng.hashCode;
  }
}
