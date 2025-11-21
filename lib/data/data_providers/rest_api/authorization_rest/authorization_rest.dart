import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../models/menu.dart';
import '../../../../utils/net_utils.dart';

class AuthorizationRest {
  Dio dio;

  AuthorizationRest(this.dio);

  Future<Either<CustomException, List<Menu>>> getMenus({
    entityId,
    applId,
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;
      final data = {"entity_id": entityId, "appl_id": applId};
      final response = await dio.post("api/mobile/getMenu", data: data);
      log('Request to https://v3.kencana.org/api/mobile/getMenu (Post)');
      if (response.statusCode == 200) {
        final body = response.data;
        log(
          'Response "https://v3.kencana.org/api/mobile/getMenu (Post)" : ${body.toString()}',
        );
        final menu = List<Menu>.from(
          body['data'].map((e) {
            return Menu.fromMap(e);
          }),
        );
        return Right(menu);
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

  Future<Either<CustomException, Map<String, String>>> getConv({
    entityId,
    applId,
  }) async {
    try {
      dio.options.headers['requiresToken'] = true;

      final data = {"entity_id": entityId, "appl_id": applId};
      final response = await dio.post("api/mobile/getEnvConf", data: data);

      if (response.statusCode == 200) {
        final body = response.data;

        Map<String, String> result = {};

        for (var item in body['data']) {
          result[item['var_id']] = item['var_value'];
        }

        return Right(result);
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
