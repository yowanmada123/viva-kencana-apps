import 'package:dartz/dartz.dart';
import 'package:vivakencanaapp/models/fdpi/approval_pr/approval_pr.dart';

import '../../models/errors/custom_exception.dart';
import '../data_providers/rest_api/approval/approval_pr_rest.dart';

class ApprovalPrRepository {
  final ApprovalPrRest approvalPrRest;

  ApprovalPrRepository({required this.approvalPrRest});

  Future<Either<CustomException, List<ApprovalPR>>> getPRList() async {
    return approvalPrRest.getPRList();
  }

  Future<Either<CustomException, String>> approvalPR({
    required String prId,
    required String typeAprv,
  }) async {
    return approvalPrRest.approvalPR(prId: prId, typeAprv: typeAprv);
  }

  Future<Either<CustomException, String>> rejectPR({
    required String prId,
    required String typeAprv,
  }) async {
    return approvalPrRest.rejectPR(prId: prId, typeAprv: typeAprv);
  }
}
