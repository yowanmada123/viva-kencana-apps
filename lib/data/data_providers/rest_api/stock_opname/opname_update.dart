import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:vivakencanaapp/models/errors/custom_exception.dart';
import 'package:vivakencanaapp/utils/net_utils.dart';

class OpnameRest {
  final Dio dio;
  OpnameRest(this.dio);

  Future<Either<CustomException, Map<String, dynamic>>> submitOpnameUpdate({
    required Map<String, dynamic> payload,
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;
      // log('Req URL: ${dio.options.baseUrl}api/updateOpnameItemByScan');
      log('Payload body: $payload');

      final response = await dio.post(
        'api/updateOpnameItemByScan',
        data: payload,
      );
      // log('response body: $response');

      if (response.statusCode == 200) {
        return Right(response.data['data']);
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
