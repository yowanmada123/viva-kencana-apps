import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:vivakencanaapp/models/mill.dart';
import '../../../../models/errors/custom_exception.dart';
import '../../../../utils/net_utils.dart';

class MillRest {
  Dio dio;

  MillRest(this.dio);

  Future<Either<CustomException, List<Mill>>> getMill() async {
    try {
      dio.options.headers['requiresToken'] = true;
      // final body = {'batch_id': deliveryID};
      log('Request to ${dio.options.baseUrl}api/kmb/master/mill (POST)');
      final response = await dio.post("api/kmb/master/mill", data: {});
      if (response.statusCode == 200) {
        log('Response body: ${response.data}');
        final body = response.data;
        final mill = List<Mill>.from(
          body['data'].map((e) {
            // body['data']['mills'].map((e) {
            return Mill.fromMap(e);
          }),
        );
        return Right(mill);
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      return Left(NetUtils.parseDioException(e));
    } on Exception catch (e) {
      if (e is DioException) {
        return Left(NetUtils.parseDioException(e));
      }
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }
}
