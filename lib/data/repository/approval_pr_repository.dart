import 'package:dartz/dartz.dart';
import 'package:vivakencanaapp/models/approval_pr/approval_pr.dart';
import 'package:vivakencanaapp/models/approval_pr/approval_pr_department.dart';
import 'package:vivakencanaapp/models/approval_pr/approval_pr_fdpi.dart';

import '../../models/errors/custom_exception.dart';
import '../data_providers/rest_api/approval/approval_pr_rest.dart';

class ApprovalPRRepository {
  final ApprovalPRRest approvalPRRest;

  ApprovalPRRepository({required this.approvalPRRest});

  Future<Either<CustomException, List<Department>>>
  getPrDepartmentListAndUserData() async {
    return approvalPRRest.getPrDepartmentListAndUserData();
  }

  Future<Either<CustomException, List<ApprovalPrFSunrise>>> getPRList(
    String entityId,
  ) async {
    return approvalPRRest.getPRList(entityId: entityId);
  }

  Future<Either<CustomException, String>> approvalPR({
    required String prId,
    required String entityId,
  }) async {
    return approvalPRRest.approvalPR(prId: prId, entityId: entityId);
  }

  Future<Either<CustomException, String>> rejectPR({
    required String prId,
    required String entityId,
  }) async {
    return approvalPRRest.rejectPR(prId: prId, entityId: entityId);
  }
}
