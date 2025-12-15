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

  Future<Either<CustomException, List<ApprovalPrFSunrise>>> getPRList({
    required String entityId,
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;
      log(
        'Request to ${dio.options.baseUrl}/api/$entityId/mobile/approval/getApprovalList (PRST)',
      );

      final body = {"tr_type": "PR"};

      final response = await dio.post(
        "api/$entityId/mobile/approval/getApprovalList",
        data: body,
      );

      log(
        "Full URL: ${dio.options.baseUrl}api/$entityId/mobile/approval/getApprovalList: $response",
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
    required String entityId,
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;
      log(prId);
      log(
        'Request to ${dio.options.baseUrl}/api/$entityId/mobile/approval/submitApprove (PRST)',
      );

      final body = {"id": prId, "approve_type": "approve"};

      final response = await dio.post(
        "api/$entityId/mobile/approval/submitApprove",
        data: body,
      );

      log(
        'Response Approve From: ${dio.options.baseUrl}/api/$entityId/mobile/approval/submitApprove (PRST): $response',
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
    required String entityId,
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;
      log(
        'Request to ${dio.options.baseUrl}/api/$entityId/mobile/approval/submitApprove (PRST)',
      );

      final body = {"id": prId, "approve_type": "reject"};

      final response = await dio.post(
        "api/$entityId/mobile/approval/submitApprove",
        data: body,
      );

      log(
        'Response Reject from ${dio.options.baseUrl}/api/$entityId/mobile/approval/submitApprove (PRST): $response',
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
