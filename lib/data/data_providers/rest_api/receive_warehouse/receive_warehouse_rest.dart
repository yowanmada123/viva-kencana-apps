import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../models/receive_warehouse/receive_warehouse.dart';
import '../../../../utils/net_utils.dart';

/// Data provider fitur Receive Warehouse KKA (database KEPUH).
///
/// Semua endpoint ada di host android.kencana.org (androidKencanaClient) dan
/// butuh token, ditangani ReceiveWarehouseController di sisi Laravel.
///
///   POST api/getRwOption     daftar mill
///   POST api/getRwWarehouse  daftar warehouse milik mill
///   POST api/getRwByTrId     cari tr_id hasil scan + cek tujuan
///   POST api/submitRw        terima semua baris satu kiriman (TI -> TR)
///
/// Error 4xx dari server (tujuan salah, sudah diterima, tidak ditemukan)
/// membawa pesan siap tampil di field `message`, yang diteruskan apa adanya
/// lewat NetUtils.parseDioException.
class ReceiveWarehouseRest {
  final Dio dio;

  ReceiveWarehouseRest(this.dio);

  Future<Either<CustomException, RwOption>> getOption() {
    return _post('api/getRwOption', const {}, (res) {
      return RwOption.fromMap(Map<String, dynamic>.from(res['data'] as Map));
    });
  }

  Future<Either<CustomException, List<RwWarehouse>>> getWarehouses({
    required String millId,
  }) {
    return _post('api/getRwWarehouse', {'mill_id': millId}, (res) {
      return _asList(res['data']).map(RwWarehouse.fromMap).toList();
    });
  }

  Future<Either<CustomException, RwScanResult>> getByTrId({
    required String trId,
    required String millId,
    required String whId,
  }) {
    return _post(
      'api/getRwByTrId',
      {'tr_id': trId, 'mill_id': millId, 'wh_id': whId},
      (res) => RwScanResult.fromMap(
        Map<String, dynamic>.from(res['data'] as Map),
      ),
    );
  }

  Future<Either<CustomException, RwReceived>> submit({
    required String trId,
    required String millId,
    required String whId,
    required String shift,
  }) {
    return _post(
      'api/submitRw',
      {'tr_id': trId, 'mill_id': millId, 'wh_id': whId, 'shift': shift},
      RwReceived.fromResponse,
    );
  }

  Future<Either<CustomException, T>> _post<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map res) parse,
  ) async {
    try {
      dio.options.headers['requiresToken'] = true;

      log('Request to ${dio.options.baseUrl}$path (POST) body: $body');

      final response = await dio.post(path, data: body);

      log('Response from $path: ${response.data}');

      final res = response.data;
      if (response.statusCode == 200 && res is Map) {
        return Right(parse(res));
      }

      return Left(
        CustomException(
          message: res is Map ? res['message']?.toString() : 'Respons tidak valid',
        ),
      );
    } on DioException catch (e) {
      log('DIO ERROR $path ${e.response?.statusCode}: ${e.response?.data}');
      return Left(NetUtils.parseDioException(e));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  /// List bisa langsung di data atau dibungkus data.data - keduanya diterima.
  List<Map<String, dynamic>> _asList(dynamic data) {
    final list = data is Map ? data['data'] : data;
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
