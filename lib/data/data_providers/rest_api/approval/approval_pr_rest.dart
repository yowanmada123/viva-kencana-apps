import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:vivakencanaapp/models/approval_pr/approval_pr_department.dart';
import 'package:vivakencanaapp/models/approval_pr/approval_pr_fdpi.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../utils/net_utils.dart';

class ApprovalPRRest {
  Dio dio;

  ApprovalPRRest(this.dio);

  Future<Either<CustomException, List<Department>>>
  getPrDepartmentListAndUserData() async {
    try {
      dio.options.headers['requiresToken'] = true;
      log(
        'Request to dios://v2.kencana.org/api/srs/mobile/approval/getUserData (GET)',
      );

      final response = await dio.get(
        "api/srs/mobile/approval/getUserData",
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          receiveDataWhenStatusError: true,
        ),
      );
      log(
        'Response from "dios://v2.kencana.org/api/srs/mobile/approval/getUserData": ${response.toString()}',
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

  Future<Either<CustomException, List<ApprovalPrFSunrise>>> getPRList(
    // {
    // required String departmentId,
    // required String approveStatus,
    // required String startDate,
    // required String endDate,
    // }
  ) async {
    try {
      dio.options.headers['requiresToken'] = true;
      log('Request to dios://api-fpi.kencana.org/api/fpi/prpo/getList (PRST)');

      final body = {
        // "department_id": departmentId, //*required
        // "approve_status": approveStatus, //ex. pending, approved, rejected
        // "start_date": startDate, //ex. 2025-03-01 *required
        // "end_date": endDate, //ex. 2025-03-01 *required
        "tr_type": "PR", //ex. 2025-03-01 *required
      };

      final response = await dio.post(
        "api/srs/mobile/approval/getApprovalList",
        data: body,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final List<ApprovalPrFSunrise> items =
            List<ApprovalPrFSunrise>.from(
              data['data'].map((e) => ApprovalPrFSunrise.fromMap(e)),
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
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;
      log(
        'Request to http://10.65.65.222:8000/api/srs/mobile/approval/submitApprove (PRST)',
      );

      final body = {"pr_id": prId, "approve_type": "approve"};

      final response = await dio.post(
        "api/srs/mobile/approval/submitApprove",
        data: body,
      );

      log(
        'Response from http://10.65.65.222:8000/api/srs/mobile/approval/submitApprove (PRST): $response',
      );

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
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;
      log('Request to dios://api-fpi.kencana.org/api/fpi/prpo/cancel (PRST)');

      final body = {"tr_id": prId, "type_aprv": "reject"};

      final response = await dio.post(
        "api/srs/mobile/approval/submitApprove",
        data: body,
      );

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
