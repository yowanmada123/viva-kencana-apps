import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:vivakencanaapp/models/stock_opname/stock_opname_hdr.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../utils/net_utils.dart';

class OpnameStockHdrRest {
  final Dio dio;

  OpnameStockHdrRest(this.dio);

  Future<Either<CustomException, List<StockOpnameHdr>>> getOpenOpnameHdrByMill({
    required String millId,
    String? whId,
    String? binId,
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;
      log(
        'Request to ${dio.options.baseUrl}api/getOpenOpnameHdrByMillAndPeriod (POST)',
      );

      final response = await dio.post(
        'api/getOpenOpnameHdrByMillAndPeriod',
        data: {'mill_id': millId, 'wh_id': whId, 'bin_id': binId},
      );
      log(
        'Response From ${dio.options.baseUrl}api/getOpenOpnameHdrByMillAndPeriod : $response',
      );

      if (response.statusCode == 200) {
        final List list = response.data['data']['data'];
        return Right(list.map((e) => StockOpnameHdr.fromMap(e)).toList());
      }

      return Left(NetUtils.parseErrorResponse(response: response.data));
    } on DioException catch (e) {
      return Left(NetUtils.parseDioException(e));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }
}
