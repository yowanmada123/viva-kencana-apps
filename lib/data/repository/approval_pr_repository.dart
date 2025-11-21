import 'package:dartz/dartz.dart';
import 'package:vivakencanaapp/models/approval_pr/approval_pr.dart';
import 'package:vivakencanaapp/models/approval_pr/approval_pr_department.dart';

import '../../models/errors/custom_exception.dart';
import '../data_providers/rest_api/approval/approval_pr_rest.dart';

class ApprovalPRRepository {
  final ApprovalPRRest approvalPRRest;

  ApprovalPRRepository({required this.approvalPRRest});

  Future<Either<CustomException, List<Department>>>
  getPrDepartmentListAndUserData() async {
    return approvalPRRest.getPrDepartmentListAndUserData();
  }

  Future<Either<CustomException, List<ApprovalPR>>> getPRList({
    required String departmentId,
    required String approveStatus,
    required String startDate,
    required String endDate,
  }) async {
    return approvalPRRest.getPRList(
      departmentId: departmentId,
      approveStatus: approveStatus,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Either<CustomException, String>> approvalPR({
    required String prId,
    required String typeAprv,
  }) async {
    return approvalPRRest.approvalPR(prId: prId, typeAprv: typeAprv);
  }

  Future<Either<CustomException, String>> rejectPR({
    required String prId,
    required String typeAprv,
  }) async {
    return approvalPRRest.rejectPR(prId: prId, typeAprv: typeAprv);
  }
}
