import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../models/vehicle.dart';
import '../../../../utils/net_utils.dart';

class ExpeditionRest {
  Dio http;

  ExpeditionRest(this.http);

  Future<Either<CustomException, List<Vehicle>>> getVehicles({
    required String userId,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      final body = {'user_id': userId};
      log(
        'Request to https://v2.kencana.org/api/viva/exp_vhc/getExpVhclogin (POST)',
      );
      final response = await http.post(
        "api/viva/exp_vhc/getExpVhc",
        data: body,
      );
      if (response.statusCode == 200) {
        log('Response body: ${response.data}');
        final body = response.data;
        final vehicles = List<Vehicle>.from(
          body['data'].map((e) {
            return Vehicle.fromMap(e);
          }),
        );
        return Right(vehicles);
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on Exception catch (e) {
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  Future<Either<CustomException, void>> updateVehicleStatus({
    required String vehicleID,
    required String status,
  }) async {
    try {
      final body = {
        'vehicle_id': vehicleID,
        'to_avail': status,
        'to_stat': 'Y',
      };
      log(
        'Request to https://v2.kencana.org/api/viva/exp_vhc/deleteActivateExpVhc (POST)',
      );
      final response = await http.post(
        "api/viva/exp_vhc/deleteActivateExpVhc",
        data: body,
      );
      if (response.statusCode == 200) {
        log('Response body: ${response.data}');
        return const Right(null);
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on Exception catch (e) {
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }
}
