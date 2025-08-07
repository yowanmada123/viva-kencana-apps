import 'package:dartz/dartz.dart';

import '../../models/errors/custom_exception.dart';
import '../../models/sales_activity/checkin_info.dart';
import '../../models/sales_activity/customer_detail.dart';
import '../../models/sales_activity/customer_info.dart';
import '../../models/sales_activity/sales_info.dart';
import '../../models/sales_activity/submit_data.dart';
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
    required String searchQuery,
  }) async {
    return salesActivityRest.getCustomer(searchQuery: searchQuery);
  }

  Future<Either<CustomException, String>> submitSalesActivity({
    required SalesActivityFormData formData,
  }) async {
    return salesActivityRest.submitSalesActivity(formData: formData);
  }

  Future<Either<CustomException, CustomerDetail>> getCustomerDetail({
    required String customerId,
  }) async {
    return salesActivityRest.getCustomerDetail(customerId: customerId);
  }

  Future<Either<CustomException, CheckinInfo>> getCheckinInfo() async {
    return salesActivityRest.getCheckinInfo();
  }
}
