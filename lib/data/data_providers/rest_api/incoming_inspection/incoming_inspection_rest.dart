import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../models/incoming_inspection/barcode_coil.dart';
import '../../../../models/incoming_inspection/coil_scan_result.dart';
import '../../../../models/incoming_inspection/inspection_form.dart';
import '../../../../models/incoming_inspection/inspection_option.dart';
import '../../../../models/incoming_inspection/vendor.dart';
import '../../../../utils/net_utils.dart';

/// Data provider fitur Incoming Inspection (database fg_inv).
///
/// Semua endpoint ada di host android.kencana.org (androidKencanaClient) dan
/// butuh token, ditangani IncomingInspectionController di sisi Laravel.
///
///   POST api/getVendorIncoming   cari vendor untuk filter list
///   POST api/getBarcodeCoil      riwayat inspeksi pada rentang tanggal
///   POST api/getCoilByBarcode    cari coil dari hasil scan
///   GET  api/getInspectionOption isi dropdown form header
///   POST api/submitInspection    simpan 1 hdr + n dtl
class IncomingInspectionRest {
  final Dio dio;

  IncomingInspectionRest(this.dio);

  /// Cari vendor berdasarkan nama ATAU kode, dipakai sambil user mengetik.
  Future<Either<CustomException, List<Vendor>>> getVendors({
    required String keyword,
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;

      log(
        'Request to ${dio.options.baseUrl}api/getVendorIncoming (POST) '
        'keyword: $keyword',
      );

      final response = await dio.post(
        'api/getVendorIncoming',
        data: {'keyword': keyword},
      );

      if (response.statusCode == 200) {
        final list = _extractList(response.data);
        return Right(list.map((e) => Vendor.fromMap(e)).toList());
      }

      return Left(NetUtils.parseErrorResponse(response: response.data));
    } on DioException catch (e) {
      return Left(_logDio(e));
    } on Exception catch (e) {
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  /// Ambil riwayat inspeksi dari view v_barcode_coil.
  ///
  /// Server hanya mengembalikan coil yang dt_trx-nya TIDAK null dan masuk
  /// rentang tanggal, jadi hasilnya adalah coil yang sudah diinspeksi.
  /// [vendorId] opsional: kosong berarti semua vendor.
  Future<Either<CustomException, List<BarcodeCoil>>> getBarcodeCoils({
    String? vendorId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;

      final body = {
        'vendor_id': (vendorId == null || vendorId.isEmpty) ? null : vendorId,
        'start_date': startDate,
        'end_date': endDate,
      };

      log('Request to ${dio.options.baseUrl}api/getBarcodeCoil (POST) body: $body');

      final response = await dio.post('api/getBarcodeCoil', data: body);

      if (response.statusCode == 200) {
        final list = _extractList(response.data);
        return Right(list.map((e) => BarcodeCoil.fromMap(e)).toList());
      }

      return Left(NetUtils.parseErrorResponse(response: response.data));
    } on DioException catch (e) {
      return Left(_logDio(e));
    } on Exception catch (e) {
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  /// Cari coil dari isi barcode hasil scan.
  ///
  /// Isi barcode boleh coil id mentah maupun string JSON - server yang
  /// mengurai. Coil yang TIDAK terdaftar tetap balasan sukses dengan
  /// found: false dan stat 'G', bukan error. Yang jadi error (HTTP 409) hanya
  /// coil yang sudah pernah diinspeksi, dan pesannya sudah menyebut nomor
  /// inspeksi sebelumnya sehingga bisa langsung ditampilkan ke user.
  Future<Either<CustomException, CoilScanResult>> getCoilByBarcode({
    required String barcode,
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;

      log(
        'Request to ${dio.options.baseUrl}api/getCoilByBarcode (POST) '
        'barcode: $barcode',
      );

      final response = await dio.post(
        'api/getCoilByBarcode',
        data: {'barcode': barcode},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data is Map) {
          return Right(
            CoilScanResult.fromMap(Map<String, dynamic>.from(data)),
          );
        }

        return Left(
          CustomException(message: 'Respons scan tidak sesuai bentuk'),
        );
      }

      return Left(NetUtils.parseErrorResponse(response: response.data));
    } on DioException catch (e) {
      return Left(_logDio(e));
    } on Exception catch (e) {
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  /// Ambil semua isi dropdown form header dalam satu panggilan.
  /// [millId] opsional untuk membatasi crew dan shift pada satu mill.
  Future<Either<CustomException, InspectionOption>> getInspectionOption({
    String? millId,
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;

      log('Request to ${dio.options.baseUrl}api/getInspectionOption (GET)');

      final response = await dio.get(
        'api/getInspectionOption',
        queryParameters: {
          if (millId != null && millId.isNotEmpty) 'mill_id': millId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data is Map) {
          return Right(
            InspectionOption.fromMap(Map<String, dynamic>.from(data)),
          );
        }

        return Left(
          CustomException(message: 'Respons opsi inspeksi tidak sesuai bentuk'),
        );
      }

      return Left(NetUtils.parseErrorResponse(response: response.data));
    } on DioException catch (e) {
      return Left(_logDio(e));
    } on Exception catch (e) {
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  /// Simpan satu inspection_hdr beserta seluruh inspection_dtl-nya.
  /// Mengembalikan trx_id hasil generate server, mis. IN26090002.
  Future<Either<CustomException, String>> submitInspection({
    required InspectionForm form,
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;

      final body = form.toMap();
      log('Request to ${dio.options.baseUrl}api/submitInspection (POST)');
      log('Payload body: $body');

      final response = await dio.post('api/submitInspection', data: body);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final trxId =
            data is Map ? (data['trx_id']?.toString() ?? '') : data.toString();
        return Right(trxId);
      }

      return Left(NetUtils.parseErrorResponse(response: response.data));
    } on DioException catch (e) {
      return Left(_logDio(e));
    } on Exception catch (e) {
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  /// Respons di project ini tidak seragam: ada yang `data: [...]` dan ada yang
  /// `data: { data: [...] }`. Helper ini menerima kedua bentuk.
  List<Map<String, dynamic>> _extractList(dynamic body) {
    final data = body is Map ? body['data'] : body;

    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return const [];
  }

  CustomException _logDio(DioException e) {
    log('DIO ERROR STATUS : ${e.response?.statusCode}');
    log('DIO ERROR DATA   : ${e.response?.data}');
    log('DIO ERROR MSG    : ${e.message}');
    return NetUtils.parseDioException(e);
  }
}
