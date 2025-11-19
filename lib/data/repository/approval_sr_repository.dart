import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../models/errors/custom_exception.dart';
import '../../models/sales_activity/customer_detail.dart';
import '../../models/sales_activity/customer_info.dart';
import '../../models/sales_activity/history_detail.dart';
import '../../models/sales_activity/history_image.dart';
import '../../models/sales_activity/history_visit.dart';
import '../../models/sales_activity/sales_info.dart';
import '../../models/sales_activity/submit_data.dart';
import '../../utils/sales_activity/sales_activity_local_database.dart';
import '../data_providers/rest_api/sales_activity_rest/sales_activity_rest.dart';
import '../data_providers/rest_api/approval_rest/approval_pr_rest.dart';

class ApprovalPoRepository {
  final ApprovalRest approvalRest;

  ApprovalPoRepository({required this.approvalRest});

  Future<Future<Either<CustomException, List<Map<String, dynamic>>>>> getUserData() async {
    return approvalRest.getUserData();
  }


}
