import 'dart:convert';

class Mill {
  final String millID;
  final String millName;
  final String officeID;
  final String region;

  Mill({
    required this.millID,
    required this.millName,
    required this.officeID,
    required this.region,
  });

  Mill copyWith({
    String? millID,
    String? millName,
    String? officeID,
    String? region,
  }) {
    return Mill(
      millID: millID ?? this.millID,
      millName: millName ?? this.millName,
      officeID: officeID ?? this.officeID,
      region: region ?? this.region,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mill_id': millID,
      'mill_name': millName,
      'office_id': officeID,
      'region': region,
    };
  }

  factory Mill.fromMap(Map<String, dynamic> map) {
    return Mill(
      millID: map['mill_id'] ?? '',
      millName: map['mill_name'] ?? '',
      officeID: map['office_id'] ?? '',
      region: map['region'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Mill.fromJson(String source) => Mill.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Mill(mill_id: $millID, mill_name: $millName, office_id: $officeID, region: $region)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Mill &&
        other.millID == millID &&
        other.millName == millName &&
        other.officeID == officeID &&
        other.region == region;
  }

  @override
  int get hashCode {
    return millID.hashCode ^
        millName.hashCode ^
        officeID.hashCode ^
        region.hashCode;
  }
}
