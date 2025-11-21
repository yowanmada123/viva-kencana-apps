import 'dart:convert';

import '../../utils/datetime_convertion.dart';

class ApprovalPR {
  final String prId;
  final String millId;
  final DateTime? dtPr;
  final String deptId;
  final String department;
  final String picName;
  final String aprv1Flag;
  final String aprv2Flag;
  final String aprv1By;
  final String aprv2By;
  final String rawFlag;
  final String picId;
  final String stat;
  final DateTime? dtRjc;
  final String memoTxt;
  final DateTime? dtAprv1;
  final DateTime? dtAprv2;

  ApprovalPR({
    required this.prId,
    required this.millId,
    required this.dtPr,
    required this.deptId,
    required this.department,
    required this.picName,
    required this.aprv1Flag,
    required this.aprv2Flag,
    required this.aprv1By,
    required this.aprv2By,
    required this.rawFlag,
    required this.picId,
    required this.stat,
    required this.dtRjc,
    required this.memoTxt,
    required this.dtAprv1,
    required this.dtAprv2,
  });

  ApprovalPR copyWith({
    String? prId,
    String? millId,
    DateTime? dtPr,
    String? deptId,
    String? department,
    String? picName,
    String? aprv1Flag,
    String? aprv2Flag,
    String? aprv1By,
    String? aprv2By,
    String? rawFlag,
    String? picId,
    String? stat,
    DateTime? dtRjc,
    String? memoTxt,
    DateTime? dtAprv1,
    DateTime? dtAprv2,
  }) {
    return ApprovalPR(
      prId: prId ?? this.prId,
      millId: millId ?? this.millId,
      dtPr: dtPr ?? this.dtPr,
      deptId: deptId ?? this.deptId,
      department: department ?? this.department,
      picName: picName ?? this.picName,
      aprv1Flag: aprv1Flag ?? this.aprv1Flag,
      aprv2Flag: aprv2Flag ?? this.aprv2Flag,
      aprv1By: aprv1By ?? this.aprv1By,
      aprv2By: aprv2By ?? this.aprv2By,
      rawFlag: rawFlag ?? this.rawFlag,
      picId: picId ?? this.picId,
      stat: stat ?? this.stat,
      dtRjc: dtRjc ?? this.dtRjc,
      memoTxt: memoTxt ?? this.memoTxt,
      dtAprv1: dtAprv1 ?? this.dtAprv1,
      dtAprv2: dtAprv2 ?? this.dtAprv2,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pr_id': prId,
      'mill_id': millId,
      'dt_pr': dtPr?.toIso8601String(),
      'dept_id': deptId,
      'department': department,
      'pic_name': picName,
      'aprv1_flag': aprv1Flag,
      'aprv2_flag': aprv2Flag,
      'aprv1_by': aprv1By,
      'aprv2_by': aprv2By,
      'raw_flag': rawFlag,
      'pic_id': picId,
      'stat': stat,
      'dt_rjc': dtRjc?.toIso8601String(),
      'memo_txt': memoTxt,
      'dt_aprv1': dtAprv1?.toIso8601String(),
      'dt_aprv2': dtAprv2?.toIso8601String(),
    };
  }

  factory ApprovalPR.fromMap(Map<String, dynamic> map) {
    return ApprovalPR(
      prId: map['pr_id'] ?? '',
      millId: map['mill_id'] ?? '',
      dtPr: parseDateTime(map['dt_pr'] ?? ''),
      deptId: map['dept_id'] ?? '',
      department: map['department'] ?? '',
      picName: map['pic_name'] ?? '',
      aprv1Flag: map['aprv1_flag'] ?? '',
      aprv2Flag: map['aprv2_flag'] ?? '',
      aprv1By: map['aprv1_by'] ?? '',
      aprv2By: map['aprv2_by'] ?? '',
      rawFlag: map['raw_flag'] ?? '',
      picId: map['pic_id'] ?? '',
      stat: map['stat'] ?? '',
      dtRjc: parseDateTime(map['dt_rjc'] ?? ''),
      memoTxt: map['memo_txt'] ?? '',
      dtAprv1: parseDateTime(map['dt_aprv1'] ?? ''),
      dtAprv2: parseDateTime(map['dt_aprv2'] ?? ''),
    );
  }

  String toJson() => json.encode(toMap());

  factory ApprovalPR.fromJson(String source) =>
      ApprovalPR.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ApprovalPR(prId: $prId, millId: $millId, dtPr: $dtPr, deptId: $deptId, department: $department, picName: $picName, aprv1Flag: $aprv1Flag, aprv2Flag: $aprv2Flag, aprv1By: $aprv1By, aprv2By: $aprv2By, rawFlag: $rawFlag, picId: $picId, stat: $stat, dtRjc: $dtRjc, memoTxt: $memoTxt, dtAprv1: $dtAprv1, dtAprv2: $dtAprv2)';
  }
}
