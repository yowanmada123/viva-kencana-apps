import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../models/errors/custom_exception.dart';
import '../../models/sales_activity/customer_detail.dart';
import '../../models/sales_activity/customer_info.dart';
import '../../models/sales_activity/history_detail.dart';
import '../../models/sales_activity/history_visit.dart';
import '../../models/sales_activity/sales_info.dart';
import '../../models/sales_activity/submit_data.dart';
import '../../utils/sales_activity/sales_activity_local_database.dart';
import '../data_providers/rest_api/sales_activity_rest/sales_activity_rest.dart';

class SalesActivityRepository {
  final SalesActivityRest salesActivityRest;

  SalesActivityRepository({required this.salesActivityRest});

  Future<Either<CustomException, SalesInfo>> getSalesInfo({
    String deliveryID = '',
  }) async {
    return salesActivityRest.getSalesInfo();
  }

  Future<Either<CustomException, List<String>>> getProvinces() async {
    return salesActivityRest.getProvinces();
  }

  Future<Either<CustomException, List<String>>> getCities({
    required String province,
  }) async {
    return salesActivityRest.getCities(province: province);
  }

  Future<Either<CustomException, List<String>>> getDistricts({
    required String city,
  }) async {
    return salesActivityRest.getDistrict(city: city);
  }

  Future<Either<CustomException, List<String>>> getVillages({
    required String district,
  }) async {
    return salesActivityRest.getVillage(district: district);
  }

  Future<Either<CustomException, List<CustomerInfo>>> getCustomers({
    required String entityId,
    required String keyword,
  }) async {
    return salesActivityRest.getCustomer(entityId: entityId, keyword: keyword);
  }

  Future<Either<CustomException, String>> submitSalesCheckIn({
    required SalesActivityFormData formData,
  }) async {
    return salesActivityRest.submitSalesCheckIn(formData: formData);
  }

  Future<Either<CustomException, String>> submitSalesActivity({
    required SalesActivityFormData formData,
  }) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      await SalesActivityLocalDatabase.instance.insertActivity(formData);
      return Right("Data disimpan offline. Akan dikirim ketika online.");
    }

    final isReallyOffline = await _checkRealConnection();
    if (isReallyOffline) {
      await SalesActivityLocalDatabase.instance.insertActivity(formData);
      return Right("Koneksi tidak stabil. Data disimpan offline sementara.");
    }

    return salesActivityRest.submitSalesActivity(formData: formData);
  }

  Future<Either<CustomException, CustomerDetail>> getCustomerDetail({
    required String entityId,
    required String customerId,
  }) async {
    return salesActivityRest.getCustomerDetail(entityId: entityId, customerId: customerId);
  }

  Future<Either<CustomException, List<HistoryVisit>>> getHistoryVisit({
    required String startDate,
    required String endDate,
  }) async {
    return salesActivityRest.getHistoryVisit(startDate: startDate, endDate: endDate);
  }

  Future<Either<CustomException, List<HistoryDetail>>> getHistoryDetail({
    required String activityId,
  }) async {
    return salesActivityRest.getHistoryDetail(activityId: activityId);
  }

  Future<Either<CustomException, String>> submitImagesDetail({
    required String entityId,
    required String trId,
    required String seqId,
    required String remark,
    required String image,
  }) async {
    return salesActivityRest.submitImagesDetail(entityId: entityId, trId: trId, seqId: seqId, remark: remark, image: image);
  }

  Future<bool> _checkRealConnection() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      final response = await Dio().get(
        'https://www.google.com',
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );

      return response.statusCode != 200;
    } catch (_) {
      return true;
    }
  }
}
