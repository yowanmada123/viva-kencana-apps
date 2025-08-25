import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../models/entity.dart';
import '../../../../models/errors/custom_exception.dart';
import '../../../../utils/net_utils.dart';

class EntityRest {
  Dio dio;

  EntityRest(this.dio);

  Future<Either<CustomException, List<Entity>>> getEntities() async {
    try {
      dio.options.headers['requiresToken'] = true;

      log('Request to https://v2.kencana.org/api/mobile/getEntity (POST)');
      final response = await dio.post("api/mobile/getEntity");

      if (response.statusCode == 200) {
        final body = response.data;
        final entities = List<Entity>.from(
          body['data'].map((e) {
            return Entity.fromMap(e);
          }),
        );

        return Right(entities);
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      return Left(NetUtils.parseDioException(e));
    } on Exception catch (e) {
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }
}
