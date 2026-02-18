import 'dart:convert';

class StockOpnameHdr {
  final String millId;
  final String trId;
  final DateTime trDate;
  final String whId;
  final String categoryId;
  final String catDesc; // 🔥 hasil join barangjadi_mst_cat
  final String remark;
  final DateTime? dtFinish;
  final String stat;
  final DateTime? dtModified;
  final String userId;
  final String trType;
  final DateTime? dtCek;

  StockOpnameHdr({
    required this.millId,
    required this.trId,
    required this.trDate,
    required this.whId,
    required this.categoryId,
    required this.catDesc,
    required this.remark,
    required this.dtFinish,
    required this.stat,
    required this.dtModified,
    required this.userId,
    required this.trType,
    required this.dtCek,
  });

  // =======================
  // COPY WITH
  // =======================
  StockOpnameHdr copyWith({
    String? millId,
    String? trId,
    DateTime? trDate,
    String? whId,
    String? categoryId,
    String? catDesc,
    String? remark,
    DateTime? dtFinish,
    String? stat,
    DateTime? dtModified,
    String? userId,
    String? trType,
    DateTime? dtCek,
  }) {
    return StockOpnameHdr(
      millId: millId ?? this.millId,
      trId: trId ?? this.trId,
      trDate: trDate ?? this.trDate,
      whId: whId ?? this.whId,
      categoryId: categoryId ?? this.categoryId,
      catDesc: catDesc ?? this.catDesc,
      remark: remark ?? this.remark,
      dtFinish: dtFinish ?? this.dtFinish,
      stat: stat ?? this.stat,
      dtModified: dtModified ?? this.dtModified,
      userId: userId ?? this.userId,
      trType: trType ?? this.trType,
      dtCek: dtCek ?? this.dtCek,
    );
  }

  // =======================
  // TO MAP (REQUEST / LOCAL)
  // =======================
  Map<String, dynamic> toMap() {
    return {
      'mill_id': millId,
      'tr_id': trId,
      'tr_date': trDate.toIso8601String(),
      'wh_id': whId,
      'category_id': categoryId,
      'cat_desc': catDesc,
      'remark': remark,
      'dt_finish': dtFinish?.toIso8601String(),
      'stat': stat,
      'dt_modified': dtModified?.toIso8601String(),
      'user_id': userId,
      'tr_type': trType,
      'dt_cek': dtCek?.toIso8601String(),
    };
  }

  // =======================
  // FROM MAP (API RESPONSE)
  // =======================
  factory StockOpnameHdr.fromMap(Map<String, dynamic> map) {
    return StockOpnameHdr(
      millId: map['mill_id'] ?? '',
      trId: map['tr_id'] ?? '',
      trDate:
          map['tr_date'] != null
              ? DateTime.parse(map['tr_date'])
              : DateTime.now(),
      whId: map['wh_id'] ?? '',
      categoryId: map['category_id'] ?? '',
      catDesc: map['cat_desc'] ?? '',
      remark: map['remark'] ?? '',
      dtFinish:
          map['dt_finish'] != null &&
                  !map['dt_finish'].toString().startsWith('1900')
              ? DateTime.parse(map['dt_finish'])
              : null,
      stat: map['stat'] ?? '',
      dtModified:
          map['dt_modified'] != null
              ? DateTime.parse(map['dt_modified'])
              : null,
      userId: map['user_id'] ?? '',
      trType: map['tr_type'] ?? '',
      dtCek: map['dt_cek'] != null ? DateTime.parse(map['dt_cek']) : null,
    );
  }

  // =======================
  // JSON
  // =======================
  String toJson() => json.encode(toMap());

  factory StockOpnameHdr.fromJson(String source) =>
      StockOpnameHdr.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StockOpnameHdr &&
        other.millId == millId &&
        other.trId == trId &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return millId.hashCode ^ trId.hashCode ^ categoryId.hashCode;
  }
}
