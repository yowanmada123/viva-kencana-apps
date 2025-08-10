import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../models/sales_activity/checkin_info.dart';
import '../../../../models/sales_activity/customer_detail.dart';
import '../../../../models/sales_activity/customer_info.dart';
import '../../../../models/sales_activity/sales_info.dart';
import '../../../../models/sales_activity/submit_data.dart';
import '../../../../utils/net_utils.dart';

class SalesActivityRest {
  Dio http;

  SalesActivityRest(this.http);

  Future<Either<CustomException, SalesInfo>> getSalesInfo() async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/kmb/sales/CustomerVisit/getSalesData (GET)',
      );
      final response = await http.get(
        "api/kmb/sales/CustomerVisit/getSalesData",
      );
      if (response.statusCode == 200) {
        final body = response.data;
        final salesInfo = SalesInfo.fromMap(body);
        return Right(salesInfo);
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

  Future<Either<CustomException, List<String>>> getProvinces() async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/kmb/sales/CustomerVisit/getProvinceMobile (GET)',
      );
      final response = await http.get(
        "api/kmb/sales/CustomerVisit/getProvinceMobile",
      );
      if (response.statusCode == 200) {
        final body = response.data;

        List<String> provinceList =
            (body['province'] as List)
                .map((item) => item['province'] as String)
                .toList();

        return Right(provinceList);
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

  Future<Either<CustomException, List<String>>> getCities({
    required String province,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/kmb/sales/CustomerVisit/provinceOnChange (GET)',
      );
      final response = await http.get(
        "api/kmb/sales/CustomerVisit/provinceOnChange",
        data: {"province": province},
      );
      if (response.statusCode == 200) {
        final body = response.data;

        List<String> cityList =
            (body['city'] as List)
                .map((item) => item['city'] as String)
                .toList();

        return Right(cityList);
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

  Future<Either<CustomException, List<String>>> getDistrict({
    required String city,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/kmb/sales/CustomerVisit/cityOnChange (GET)',
      );
      final response = await http.get(
        "api/kmb/sales/CustomerVisit/cityOnChange",
        data: {"city": city},
      );
      if (response.statusCode == 200) {
        final body = response.data;

        List<String> districtList =
            (body['district'] as List)
                .map((item) => item['districts'] as String)
                .toList();

        return Right(districtList);
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

  Future<Either<CustomException, List<String>>> getVillage({
    required String district,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/kmb/sales/CustomerVisit/districtOnChange (GET)',
      );
      final response = await http.get(
        "api/kmb/sales/CustomerVisit/districtOnChange",
        data: {"district": district},
      );
      if (response.statusCode == 200) {
        final body = response.data;

        List<String> villageList =
            (body['village'] as List)
                .map((item) => item['vilage'] as String)
                .toList();

        return Right(villageList);
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

  Future<Either<CustomException, List<CustomerInfo>>> getCustomer({
    required String searchQuery,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/kmb/sales/CustomerVisit/getCustomerById (GET)',
      );
      final response = await http.post(
        "api/kmb/sales/CustomerVisit/getCustomerById",
        data: {"id": searchQuery},
      );
      if (response.statusCode == 200) {
        final body = response.data;

        final List<CustomerInfo> customers =
            (body['result'] as List)
                .map((item) => CustomerInfo.fromMap(item))
                .toList();

        return Right(customers);
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

  Future<Either<CustomException, String>> submitSalesCheckIn({
    required SalesActivityFormData formData,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/kmb/sales/CustomerVisit/getActivityData (POST)',
      );
      log("formData: $formData");
      final response = await http.post(
        "api/kmb/sales/CustomerVisit/storeActivityData",
        data: formData.toMap(),
      );
      if (response.statusCode == 200) {
        final body = response.data;

        return Right(body['message']);
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

  Future<Either<CustomException, String>> submitSalesActivity({
    required SalesActivityFormData formData,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/kmb/sales/CustomerVisit/submitData (POST)',
      );
      final response = await http.post(
        "api/kmb/sales/CustomerVisit/submitData",
        data: formData.toMap(),
      );
      if (response.statusCode == 200) {
        final body = response.data;

        return Right(body['message']);
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

  Future<Either<CustomException, CustomerDetail>> getCustomerDetail({
    required String customerId,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/kmb/sales/CustomerVisit/getCustomer (POST)',
      );
      final response = await http.post(
        "api/kmb/sales/CustomerVisit/getCustomer",
        data: {"customer_id": customerId},
      );
      if (response.statusCode == 200) {
        final body = response.data;

        return Right(CustomerDetail.fromMap(body['customer']));
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

  Future<Either<CustomException, CheckinInfo>> getCheckinInfo() async {
    try {
      http.options.headers['requiresToken'] = true;

      log(
        'Request to https://v2.kencana.org/api/kmb/sales/CustomerVisit/checkTodayStartCheckpoint (GET)',
      );

      final response = await http.get(
        "api/kmb/sales/CustomerVisit/checkTodayStartCheckpoint",
      );

      if (response.statusCode == 200) {
        final body = response.data;

        return Right(CheckinInfo.fromMap(body));
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
