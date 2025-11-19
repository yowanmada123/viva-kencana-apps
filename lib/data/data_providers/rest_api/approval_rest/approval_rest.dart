import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:vivakencanaapp/utils/net_utils.dart';
import '../../../../models/errors/custom_exception.dart';

class ApprovalRest {
  Dio dio;

  ApprovalRest(this.dio);

  Future<Either<CustomException, List<Map<String, dynamic>>>> getUserData() async {
    try {

      dio.options.headers['requiresToken'] = true;

      final response = await dio.get("api/srs/mobile/approval");

      if (response.statusCode == 200) {
        
        final body = response.data;
        
        if (body['status'] == 'success' && body['department'] != null) {
          final List<Map<String, dynamic>> departments =
              List<Map<String, dynamic>>.from(body['department']);
          return Right(departments);
        } else {
          return Left(NetUtils.parseErrorResponse(response: response.data));
        }
      } else {
        return Left(CustomException(message: 'Gagal mengambil data: ${response.statusCode}'));
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