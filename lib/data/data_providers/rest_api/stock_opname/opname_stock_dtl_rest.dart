import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:vivakencanaapp/models/stock_opname/stock_opname_dtl.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../utils/net_utils.dart';

class OpnameStockDtlRest {
  final Dio dio;

  OpnameStockDtlRest(this.dio);

  Future<Either<CustomException, List<StockOpnameDtl>>> getOpnameDetail({
    required String trId,
    required String millId,
    required String whId,
    String? binId,
    String? batchId,
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;

      final response = await dio.post(
        'api/getOpnameDetail',
        data: {
          'tr_id': trId,
          'mill_id': millId,
          'wh_id': whId,
          'bin_id': binId,
          'batch_id': batchId,
        },
      );
      // log(
      //   'Response From ${dio.options.baseUrl}api/getOpnameDetail : $response',
      // );

      if (response.statusCode == 200) {
        final List list = response.data['data']['data'];
        return Right(list.map((e) => StockOpnameDtl.fromMap(e)).toList());
      }

      return Left(NetUtils.parseErrorResponse(response: response.data));
    } on DioException catch (e) {
      log('DIO ERROR STATUS : ${e.response?.statusCode}');
      log('DIO ERROR DATA   : ${e.response?.data}');
      log('DIO ERROR MSG    : ${e.message}');
      return Left(NetUtils.parseDioException(e));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }
}
