import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:vivakencanaapp/models/stock_opname/barang_jadi.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../utils/net_utils.dart';

class BarangJadiRest {
  final Dio dio;

  BarangJadiRest(this.dio);

  Future<Either<CustomException, List<BarangJadi>>> getBarangJadiByName({
    required String namaBarang,
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;

      final response = await dio.post(
        'api/kmb/warehouse/getBarangJadi',
        data: {'nama_barang': namaBarang},
      );
      // log('Response body: ${response.data}');

      if (response.statusCode == 200) {
        final List list = response.data['data'];
        return Right(list.map((e) => BarangJadi.fromMap(e)).toList());
      }

      return Left(NetUtils.parseErrorResponse(response: response.data));
    } on DioException catch (e) {
      return Left(NetUtils.parseDioException(e));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }
}
