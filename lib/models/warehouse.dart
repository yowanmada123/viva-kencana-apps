import 'dart:convert';

class Warehouse {
  final String millID;
  final String whID;
  final String descr;
  final String activeFlag;
  final String dtCreated;
  final String dtModified;
  final String userID;
  final String deptID;
  final String whLock;
  final String userCreated;
  final String locID;
  final String whCategory;
  Warehouse({
    required this.millID,
    required this.whID,
    required this.descr,
    required this.activeFlag,
    required this.dtCreated,
    required this.dtModified,
    required this.userID,
    required this.deptID,
    required this.whLock,
    required this.userCreated,
    required this.locID,
    required this.whCategory,
  });

  Warehouse copyWith({
    String? millID,
    String? whID,
    String? descr,
    String? activeFlag,
    String? dtCreated,
    String? dtModified,
    String? userID,
    String? deptID,
    String? whLock,
    String? userCreated,
    String? locID,
    String? whCategory,
  }) {
    return Warehouse(
      millID: millID ?? this.millID,
      whID: whID ?? this.whID,
      descr: descr ?? this.descr,
      activeFlag: activeFlag ?? this.activeFlag,
      dtCreated: dtCreated ?? this.dtCreated,
      dtModified: dtModified ?? this.dtModified,
      userID: userID ?? this.userID,
      deptID: deptID ?? this.deptID,
      whLock: whLock ?? this.whLock,
      userCreated: userCreated ?? this.userCreated,
      locID: locID ?? this.locID,
      whCategory: whCategory ?? this.whCategory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mill_id': millID,
      'wh_id': whID,
      'descr': descr,
      'active_flag': activeFlag,
      'dt_created': dtCreated,
      'dt_modified': dtModified,
      'user_id': userID,
      'dept_id': deptID,
      'wh_lock': whLock,
      'user_created': userCreated,
      'loc_id': locID,
      'wh_category': whCategory,
    };
  }

  factory Warehouse.fromMap(Map<String, dynamic> map) {
    return Warehouse(
      millID: map['mill_id'] ?? '',
      whID: map['wh_id'] ?? '',
      descr: map['descr'] ?? '',
      activeFlag: map['active_flag'] ?? '',
      dtCreated: map['dt_created'] ?? '',
      dtModified: map['dt_modified'] ?? '',
      userID: map['user_id'] ?? '',
      deptID: map['dept_id'] ?? '',
      whLock: map['wh_lock'] ?? '',
      userCreated: map['user_created'] ?? '',
      locID: map['loc_id'] ?? '',
      whCategory: map['wh_category'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Warehouse.fromJson(String source) =>
      Warehouse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Warehouse(mill_id: $millID, wh_id: $whID, descr: $descr, active_flag: $activeFlag, dt_created: $dtCreated, dt_modified: $dtModified, user_id: $userID, dept_id: $deptID, wh_lock: $whLock, user_created: $userCreated, loc_id: $locID, wh_category: $whCategory)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Warehouse &&
        other.millID == millID &&
        other.whID == whID &&
        other.descr == descr &&
        other.activeFlag == activeFlag &&
        other.dtCreated == dtCreated &&
        other.dtModified == dtModified &&
        other.userID == userID &&
        other.deptID == deptID &&
        other.whLock == whLock &&
        other.userCreated == userCreated &&
        other.locID == locID &&
        other.whCategory == whCategory;
  }

  @override
  int get hashCode {
    return millID.hashCode ^
        whID.hashCode ^
        descr.hashCode ^
        activeFlag.hashCode ^
        dtCreated.hashCode ^
        dtModified.hashCode ^
        userID.hashCode ^
        deptID.hashCode ^
        whLock.hashCode ^
        userCreated.hashCode ^
        locID.hashCode ^
        whCategory.hashCode;
  }
}
