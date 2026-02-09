import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:vivakencanaapp/models/errors/custom_exception.dart';
import 'package:vivakencanaapp/models/stock_opname/prod_add.dart';
import 'package:vivakencanaapp/utils/net_utils.dart';

import '../../../../models/stock_opname/prod_tor.dart';

class ProdMasterRest {
  final Dio dio;
  ProdMasterRest(this.dio);

  Future<Either<CustomException, List<ProdAdd>>> getProdAdd() async {
    try {
      dio.options.headers['requiresToken'] = true;
      log('Request to: ${dio.options.baseUrl}api/getListProdAdd');

      final response = await dio.post('api/kmb/warehouse/getListProdAdd');
      log('Response body ADD ID: ${response.data}');
      if (response.statusCode == 200) {
        final List list = response.data['data'];
        return Right(list.map((e) => ProdAdd.fromMap(e)).toList());
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

  Future<Either<CustomException, List<ProdTor>>> getProdTor() async {
    try {
      dio.options.headers['requiresToken'] = true;

      final response = await dio.post('api/kmb/warehouse/getListProdTor');
      log('Response body PROD ID: ${response.data}');
      if (response.statusCode == 200) {
        final List list = response.data['data'];
        return Right(list.map((e) => ProdTor.fromMap(e)).toList());
      }

      return Left(NetUtils.parseErrorResponse(response: response.data));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }
}
