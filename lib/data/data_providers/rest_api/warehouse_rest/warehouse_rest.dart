import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../models/batch.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../models/warehouse.dart';
import '../../../../utils/net_utils.dart';

class WarehouseRest {
  Dio http;

  WarehouseRest(this.http);

  Future<Either<CustomException, List<Warehouse>>> getWarehouse({
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
      if (response.statusCode == 200) {
        log('Response body: ${response.data}');
        final body = response.data;
        final warehouse = List<Warehouse>.from(
          body['data']['warehouses'].map((e) {
            return Warehouse.fromMap(e);
          }),
        );
        return Right(warehouse);
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

  // Future<Either<CustomException, Batch>> getBatch({
  //   required String deliveryID,
  // }) async {
  //   try {
  //     http.options.headers['requiresToken'] = true;
  //     final body = {'batch_id': deliveryID};
  //     log(
  //       'Request to https://v2.kencana.org/api/viva/confirm_muat/getDataWh (POST)',
  //     );
  //     final response = await http.post(
  //       "api/viva/confirm_muat/getDataWh",
  //       data: body,
  //     );
  //     if (response.statusCode == 200) {
  //       log('Response body: ${response.data}');
  //       final body = response.data;
  //       final batch = Batch.fromMap(body);
  //       // final warehouse = List<Warehouse>.from(
  //       //   body['data'].map((e) {
  //       //     return Warehouse.fromMap(e);
  //       //   }),
  //       // );
  //       return Right(batch);
  //     } else {
  //       return Left(NetUtils.parseErrorResponse(response: response.data));
  //     }
  //   } on Exception catch (e) {
  //     return Future.value(Left(CustomException(message: e.toString())));
  //   } catch (e) {
  //     return Left(CustomException(message: e.toString()));
  //   }
  // }
}
