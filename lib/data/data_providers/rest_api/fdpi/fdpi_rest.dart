import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../models/fdpi/city.dart';
import '../../../../models/fdpi/house.dart';
import '../../../../models/fdpi/province.dart';
import '../../../../models/fdpi/residence.dart';
import '../../../../utils/net_utils.dart';

class FdpiRest {
  Dio http;

  FdpiRest(this.http);

  Future<Either<CustomException, List<Province>>> getProvinces() async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/fpi/master/getProvince (POST)',
      );
      final response = await http.post("api/fpi/master/getProvince");
      if (response.statusCode == 200) {
        log('Response body: ${response.data}');
        final body = response.data;
        final province = List<Province>.from(
          body['data'].map((e) {
            return Province.fromMap(e);
          }),
        );
        return Right(province);
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

  Future<Either<CustomException, List<City>>> getCities(String id) async {
    try {
      http.options.headers['requiresToken'] = true;
      log('Request to https://v2.kencana.org/api/fpi/master/getCity (POST)');
      final body = {"id_province": id};
      final response = await http.post("api/fpi/master/getCity", data: body);
      if (response.statusCode == 200) {
        log('Response body: ${response.data}');
        final body = response.data;
        final cities = List<City>.from(
          body['data'].map((e) {
            return City.fromMap(e);
          }),
        );
        return Right(cities);
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

  Future<Either<CustomException, List<Residence>>> getResidences(
    String? idProv,
    String? idCity,
    String? status,
  ) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/fpi/cluster/getCluster (POST)',
      );
      final body = {
        "id_site": "",
        "category": "",
        "id_province": idProv ?? "",
        "id_prov_city": idCity ?? "",
        "status": status ?? "Aktif",
      };
      final response = await http.post(
        "api/fpi/cluster/getCluster",
        data: body,
      );
      if (response.statusCode == 200) {
        log('Response body: ${response.data}');
        final body = response.data;
        final residence = List<Residence>.from(
          body['data'].map((e) {
            return Residence.fromMap(e);
          }),
        );
        return Right(residence);
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

  Future<Either<CustomException, List<House>>> getHouses(
    String? idCluster,
  ) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/fpi/houseUnit/getKoordinat (POST)',
      );
      final body = {"id_site": idCluster};
      final response = await http.post(
        "api/fpi/houseUnit/getKoordinat",
        data: body,
      );
      if (response.statusCode == 200) {
        log('Response body: ${response.data}');
        final body = response.data;
        final houses = List<House>.from(
          body['data'].map((e) {
            return House.fromMap(e);
          }),
        );
        return Right(houses);
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
