import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../models/batch.dart';
import '../../../../models/delivery_detail.dart';
import '../../../../models/errors/custom_exception.dart';
import '../../../../utils/net_utils.dart';

class BatchRest {
  Dio http;

  BatchRest(this.http);

  Future<Either<CustomException, List<DeliveryDetail>>> getDeliveryDetail({
    required String batchID,
    required String companyID,
    required String millID,
    required String whID,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      final body = {
        'batch_id': batchID,
        "company_id": companyID,
        "mill_id": millID,
        "wh_id": whID,
      };
      log(
        'Request to https://v2.kencana.org/api/viva/confirm_muat/getDelivDtl (POST)',
      );
      final response = await http.post(
        "api/viva/confirm_muat/getDelivDtl",
        data: body,
      );
      if (response.statusCode == 200) {
        // log('Response body: ${response.data}');
        final body = response.data;
        final deliveryDetail = List<DeliveryDetail>.from(
          body['data'].map((e) {
            return DeliveryDetail.fromMap(e);
          }),
        );
        return Right(deliveryDetail);
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      return Left(NetUtils.parseDioException(e));
    } on Exception catch (e) {
      if (e is DioException) {
        return Left(NetUtils.parseDioException(e));
      }
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  Future<Either<CustomException, Batch>> getBatch({
    required String deliveryID,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      final body = {'batch_id': deliveryID};
      log(
        'Request to https://v2.kencana.org/api/viva/confirm_muat/getDataWh (POST)',
      );
      final response = await http.post(
        "api/viva/confirm_muat/getDataWh",
        data: body,
      );

      log(
        'Response From: https://v2.kencana.org/api/viva/confirm_muat/getDataWh (POST): $response',
      );

      log("Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        // log('Response body: ${response.data}');
        final body = response.data;
        final batch = Batch.fromMap(body['data']);
        log("A");

        // final warehouse = List<Warehouse>.from(
        //   body['data'].map((e) {
        //     return Warehouse.fromMap(e);
        //   }),
        // );
        return Right(batch);
      } else {
        log("Error Executed");
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      return Left(NetUtils.parseDioException(e));
    } on Exception catch (e) {
      if (e is DioException) {
        return Left(NetUtils.parseDioException(e));
      }
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  Future<Either<CustomException, List<DeliveryDetail>>> confirmLoad({
    required String batchID,
    required String companyID,
    required String millID,
    required String whID,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      final body = {
        'batch_id': batchID,
        "company_id": companyID,
        "mill_id": millID,
        "wh_id": whID,
      };
      log(
        'Request to https://v2.kencana.org/api/viva/confirm_muat/confirmLoad (POST)',
      );
      final response = await http.post(
        "api/viva/confirm_muat/confirmLoad",
        data: body,
      );

      log(
        'Response From: https://v2.kencana.org/api/viva/confirm_muat/confirmLoad (POST): $response',
      );
      if (response.statusCode == 200) {
        // log('Response body: ${response.data}');
        final body = response.data;
        final deliveryDetail = List<DeliveryDetail>.from(
          body['data'].map((e) {
            return DeliveryDetail.fromMap(e);
          }),
        );
        return Right(deliveryDetail);
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on Exception catch (e) {
      if (e is DioException) {
        return Left(NetUtils.parseDioException(e));
      }
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  Future<Either<CustomException, List<DeliveryDetail>>> cancelLoad({
    required String batchID,
    required String companyID,
    required String millID,
    required String whID,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      final body = {
        'batch_id': batchID,
        "company_id": companyID,
        "mill_id": millID,
        "wh_id": whID,
      };
      log(
        'Request to https://v2.kencana.org/api/viva/confirm_muat/cancelLoad (POST)',
      );
      final response = await http.post(
        "api/viva/confirm_muat/cancelLoad",
        data: body,
      );
      if (response.statusCode == 200) {
        // log('Response body: ${response.data}');
        final body = response.data;
        final deliveryDetail = List<DeliveryDetail>.from(
          body['data'].map((e) {
            return DeliveryDetail.fromMap(e);
          }),
        );
        return Right(deliveryDetail);
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on Exception catch (e) {
      if (e is DioException) {
        return Left(NetUtils.parseDioException(e));
      }
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }
}
