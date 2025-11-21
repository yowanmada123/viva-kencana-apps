import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:vivakencanaapp/models/approval_pr/approval_pr.dart';
import 'package:vivakencanaapp/models/approval_pr/approval_pr_department.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../utils/net_utils.dart';

class ApprovalPRRest {
  Dio http;

  ApprovalPRRest(this.http);

  Future<Either<CustomException, List<Department>>>
  getPrDepartmentListAndUserData() async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/srs/mobile/approval/getUserData (GET)',
      );

      final response = await http.get(
        "api/srs/mobile/approval/getUserData",
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          receiveDataWhenStatusError: true,
        ),
      );
      log(
        'Response from "https://v2.kencana.org/api/srs/mobile/approval/getUserData": ${response.toString()}',
      );
      if (response.statusCode == 200) {
        final data = response.data;

        final List<Department> items =
            List<Department>.from(
              data['department'].map((e) => Department.fromMap(e)),
            ).toList();

        return Right(items);
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      return Left(NetUtils.parseDioException(e));
    } on Exception catch (e) {
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  Future<Either<CustomException, List<ApprovalPR>>> getPRList({
    required String departmentId,
    required String approveStatus,
    required String startDate,
    required String endDate,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log('Request to https://api-fpi.kencana.org/api/fpi/prpo/getList (PRST)');

      final body = {
        "department_id": departmentId, //*required
        "approve_status": approveStatus, //ex. pending, approved, rejected
        "start_date": startDate, //ex. 2025-03-01 *required
        "end_date": endDate, //ex. 2025-03-01 *required
      };

      final response = await http.post(
        "api/srs/mobile/approval/getApprovalList",
        data: body,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final List<ApprovalPR> items =
            List<ApprovalPR>.from(
              data['data'].map((e) => ApprovalPR.fromMap(e)),
            ).toList();

        return Right(items);
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      return Left(NetUtils.parseDioException(e));
    } on Exception catch (e) {
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  Future<Either<CustomException, String>> approvalPR({
    required String prId, // prId
    required String typeAprv, // Approve1 atau Approve2
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log('Request to https://api-fpi.kencana.org/api/fpi/prpo/approve (PRST)');

      final body = {"tr_id": prId, "tr_type": "PR", "type_aprv": typeAprv};

      final response = await http.post("api/fpi/prpo/approve", data: body);

      if (response.statusCode == 200) {
        return Right("Successfully approved");
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      return Left(NetUtils.parseDioException(e));
    } on Exception catch (e) {
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  Future<Either<CustomException, String>> rejectPR({
    required String prId, // prId
    required String typeAprv, // Approve1 atau Approve2
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log('Request to https://api-fpi.kencana.org/api/fpi/prpo/cancel (PRST)');

      final body = {"tr_id": prId, "tr_type": "PR", "type_aprv": typeAprv};

      final response = await http.post("api/fpi/prpo/cancel", data: body);

      if (response.statusCode == 200) {
        return Right("Successfully rejected");
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      return Left(NetUtils.parseDioException(e));
    } on Exception catch (e) {
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }
}
