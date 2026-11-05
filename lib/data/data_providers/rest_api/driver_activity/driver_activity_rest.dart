import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:vivakencanaapp/models/driver_activity/driver_delivery.dart';
import 'package:vivakencanaapp/models/errors/custom_exception.dart';
import 'package:vivakencanaapp/utils/net_utils.dart';

class DriverActivityRest {
  final Dio http;

  DriverActivityRest(this.http);

  Future<Either<CustomException, List<DriverDelivery>>> getDeliveryList() async {
    try {
      http.options.headers['requiresToken'] = true;
      final url = 'api/viva/driver-activity/getDeliveryList';
      log('Request to ${http.options.baseUrl}$url (POST)');

      final response = await http.post(url);
      log('Response from getDeliveryList: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = response.data;
        final dynamic rawData = body['data'];
        final List listData = rawData is List ? rawData : [];
        final deliveries = listData
            .map((item) => DriverDelivery.fromMap(item as Map<String, dynamic>))
            .toList();
        return Right(deliveries);
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      log('DIO ERROR STATUS : $statusCode');
      log('DIO ERROR DATA   : ${e.response?.data}');
      log('DIO ERROR MSG    : ${e.message}');

      if (statusCode == 404) {
        return Left(CustomException(
          message:
              'Endpoint tidak ditemukan (404 Not Found) pada server ${http.options.baseUrl}.\n'
              'Pastikan perubahan route sudah di-pull dan route cache di-clear di server.',
        ));
      } else if (statusCode == 401) {
        return Left(CustomException(
          message: 'Sesi login telah berakhir (401 Unauthorized). Silakan login ulang.',
        ));
      } else if (statusCode == 500) {
        String serverMsg = '';
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          serverMsg = ': ${e.response?.data['message']}';
        }
        return Left(CustomException(
          message: 'Terjadi kesalahan pada server (500)$serverMsg',
        ));
      }

      return Left(NetUtils.parseDioException(e));
    } on Exception catch (e) {
      return Left(CustomException(message: e.toString()));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }
}
