import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      log('Request to ${http.options.baseUrl}$url (GET)');
      debugPrint('Request to ${http.options.baseUrl}$url (GET)');

      final response = await http.get(url);
      log('Response from getDeliveryList [${response.statusCode}]: ${response.data}');
      debugPrint('====================================');
      debugPrint('[getDeliveryList] STATUS: ${response.statusCode}');
      debugPrint('[getDeliveryList] RESPONSE DATA: ${response.data}');
      debugPrint('====================================');

      if (response.statusCode == 200) {
        final body = response.data;
        dynamic rawData;
        if (body is Map) {
          rawData = body['data'] ?? body['result'];
        } else if (body is List) {
          rawData = body;
        }

        final List listData = rawData is List ? rawData : [];
        final deliveries = listData
            .whereType<Map>()
            .map((item) => DriverDelivery.fromMap(Map<String, dynamic>.from(item)))
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
      debugPrint('====================================');
      debugPrint('[getDeliveryList ERROR] STATUS: $statusCode');
      debugPrint('[getDeliveryList ERROR] DATA: ${e.response?.data}');
      debugPrint('[getDeliveryList ERROR] MSG: ${e.message}');
      debugPrint('====================================');

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
      log('getDeliveryList Exception: $e');
      debugPrint('[getDeliveryList Exception]: $e');
      return Left(CustomException(message: e.toString()));
    } catch (e) {
      log('getDeliveryList Catch: $e');
      debugPrint('[getDeliveryList Catch]: $e');
      return Left(CustomException(message: e.toString()));
    }
  }

  Future<Either<CustomException, List<DriverDeliveryDetailItem>>> getDetailItem({
    required String entity,
    required String id,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      final url = 'api/viva/driver-activity/getDetailItem';
      final queryParams = {
        'entity': entity.trim(),
        'id': id.trim(),
      };
      log('Request to ${http.options.baseUrl}$url (GET) params: $queryParams');
      debugPrint('Request to ${http.options.baseUrl}$url (GET) params: $queryParams');

      final response = await http.get(
        url,
        queryParameters: queryParams,
      );
      log('Response from getDetailItem [${response.statusCode}]: ${response.data}');
      debugPrint('====================================');
      debugPrint('[getDetailItem] STATUS: ${response.statusCode}');
      debugPrint('[getDetailItem] RESPONSE DATA: ${response.data}');
      debugPrint('====================================');

      if (response.statusCode == 200) {
        final body = response.data;
        dynamic rawData;
        if (body is Map) {
          if (body['result'] is String) {
            // E.g. 'entity not set'
            return Left(CustomException(message: body['result']));
          }
          rawData = body['result'] ?? body['data'];
        } else if (body is List) {
          rawData = body;
        }

        final List listData = rawData is List ? rawData : [];
        final items = listData
            .whereType<Map>()
            .map((item) =>
                DriverDeliveryDetailItem.fromMap(Map<String, dynamic>.from(item)))
            .toList();
        return Right(items);
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      log('DIO ERROR STATUS : $statusCode');
      log('DIO ERROR DATA   : ${e.response?.data}');
      log('DIO ERROR MSG    : ${e.message}');
      debugPrint('====================================');
      debugPrint('[getDetailItem ERROR] STATUS: $statusCode');
      debugPrint('[getDetailItem ERROR] DATA: ${e.response?.data}');
      debugPrint('[getDetailItem ERROR] MSG: ${e.message}');
      debugPrint('====================================');

      if (statusCode == 404) {
        return Left(CustomException(
          message:
              'Endpoint getDetailItem tidak ditemukan (404 Not Found) pada server ${http.options.baseUrl}.',
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
      log('getDetailItem Exception: $e');
      debugPrint('[getDetailItem Exception]: $e');
      return Left(CustomException(message: e.toString()));
    } catch (e) {
      log('getDetailItem Catch: $e');
      debugPrint('[getDetailItem Catch]: $e');
      return Left(CustomException(message: e.toString()));
    }
  }

  Future<Either<CustomException, String>> goCheckOut({
    required String id,
    required String entity,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      final url = 'api/viva/driver-activity/goCheckOut';
      final body = {
        'id': id.trim(),
        'entity': entity.trim(),
      };
      log('Request to ${http.options.baseUrl}$url (POST) body: $body');
      debugPrint('Request to ${http.options.baseUrl}$url (POST) body: $body');

      final response = await http.post(url, data: body);
      log('Response from goCheckOut [${response.statusCode}]: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          if (data['status'] == 'error' || data['result'] == 'entity not set') {
            return Left(CustomException(
              message: data['message'] ??
                  'Gagal memproses keberangkatan: ${data['result']}',
            ));
          }
          final msg = data['message'] ??
              'Berhasil konfirmasi keberangkatan (Check Out)';
          return Right(msg.toString());
        }
        return const Right('Berhasil konfirmasi keberangkatan (Check Out)');
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      log('DIO ERROR goCheckOut: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 404) {
        return Left(CustomException(
          message: 'Endpoint goCheckOut tidak ditemukan (404 Not Found).',
        ));
      }
      return Left(NetUtils.parseDioException(e));
    } catch (e) {
      log('goCheckOut Exception: $e');
      return Left(CustomException(message: e.toString()));
    }
  }

  Future<Either<CustomException, String>> goCheckIn({
    required String id,
    required String entity,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      final url = 'api/viva/driver-activity/goCheckIn';
      final body = {
        'id': id.trim(),
        'entity': entity.trim(),
      };
      log('Request to ${http.options.baseUrl}$url (POST) body: $body');
      debugPrint('Request to ${http.options.baseUrl}$url (POST) body: $body');

      final response = await http.post(url, data: body);
      log('Response from goCheckIn [${response.statusCode}]: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          if (data['status'] == 'error' || data['result'] == 'entity not set') {
            return Left(CustomException(
              message:
                  data['message'] ?? 'Gagal memproses kepulangan: ${data['result']}',
            ));
          }
          final msg = data['message'] ??
              'Berhasil konfirmasi kepulangan (Check In)';
          return Right(msg.toString());
        }
        return const Right('Berhasil konfirmasi kepulangan (Check In)');
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      log('DIO ERROR goCheckIn: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 404) {
        return Left(CustomException(
          message: 'Endpoint goCheckIn tidak ditemukan (404 Not Found).',
        ));
      }
      return Left(NetUtils.parseDioException(e));
    } catch (e) {
      log('goCheckIn Exception: $e');
      return Left(CustomException(message: e.toString()));
    }
  }
}
