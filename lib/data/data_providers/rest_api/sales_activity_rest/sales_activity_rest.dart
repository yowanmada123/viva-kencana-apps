import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../models/sales_activity/customer_detail.dart';
import '../../../../models/sales_activity/customer_info.dart';
import '../../../../models/sales_activity/history_detail.dart';
import '../../../../models/sales_activity/history_visit.dart';
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
        'Request to https://v2.kencana.org/api/viva/sales_activity/CustomerVisit/getUserData (GET)',
      );
      final response = await http.get(
        "api/viva/sales_activity/CustomerVisit/getUserData",
      );
      if (response.statusCode == 200) {
        final body = response.data;
        final salesInfo = SalesInfo.fromMap(body['data']);
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
    required String entityId,
    required String keyword,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/viva/sales_activity/CustomerVisit/getCustomerById (GET)',
      );
      final response = await http.post(
        "api/viva/sales_activity/CustomerVisit/getCustomerById",
        data: {"entity_id": entityId, "customer_id": keyword},
      );
      if (response.statusCode == 200) {
        final body = response.data;

        final List<CustomerInfo> customers =
            (body['data'] as List)
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

  Future<Either<CustomException, CustomerDetail>> getCustomerDetail({
    required String entityId,
    required String customerId,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/viva/sales_activity/CustomerVisit/getCustomer (POST)',
      );

      final response = await http.post(
        "api/viva/sales_activity/CustomerVisit/getCustomer",
        data: {"entity_id": entityId, "customer_id": customerId},
      );
      if (response.statusCode == 200) {
        final body = response.data;

        return Right(CustomerDetail.fromMap(body['data']));
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
        'Request to https://v2.kencana.org/api/viva/sales_activity/CustomerVisit/submitCheckpointActivity (POST)',
      );
      final response = await http.post(
        "api/viva/sales_activity/CustomerVisit/submitCheckpointActivity",
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
        'Request to https://v2.kencana.org/api/viva/sales_activity/CustomerVisit/submitCustomerActivity (POST)',
      );
      print(['name: ${formData.customerName}, ktp: ${ formData.customerKtpNpwp}, phone: ${formData.customerPhone}, email: ${formData.customerEmail}, address: ${formData.customerAddress}, province: ${formData.customerProvince}, city: ${formData.customerCity}, district: ${formData.customerDistrict}, village: ${formData.customerVillage}']);
      final response = await http.post(
        "api/viva/sales_activity/CustomerVisit/submitCustomerActivity",
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

  Future<Either<CustomException, List<HistoryVisit>>> getHistoryVisit({
    String? startDate,
    String? endDate,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/viva/sales_activity/CustomerVisit/getActivityData (POST)',
      );
      final body = {
        'start_date': startDate ?? '',
        'end_date': endDate ?? '',
      };
      final response = await http.post(
        "api/viva/sales_activity/CustomerVisit/getActivityData",
        data: body,
      );
      if (response.statusCode == 200) {
        final body = response.data;

        final List<HistoryVisit> histories =
            (body['data'] as List)
                .map((item) => HistoryVisit.fromMap(item))
                .toList();

        return Right(histories);
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

  Future<Either<CustomException, List<HistoryDetail>>> getHistoryDetail({
    required String activityId,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/viva/sales_activity/CustomerVisit/getActivityDetail (POST)',
      );
      final body = {
        'id': activityId,
      };
      final response = await http.post(
        "api/viva/sales_activity/CustomerVisit/getActivityDetail",
        data: body,
      );
      if (response.statusCode == 200) {
        final body = response.data;
        final List<HistoryDetail> detail =
            (body['data'] as List)
                .map((item) => HistoryDetail.fromMap(item))
                .toList();

        return Right(detail);
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
