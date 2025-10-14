import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:vivakencanaapp/utils/interceptors/dio_request_token_interceptor.dart';

import '../../data/data_providers/rest_api/sales_activity_rest/sales_activity_rest.dart';
import '../../environment.dart';
import '../../models/sales_activity/submit_data.dart';
import 'sales_activity_local_database.dart';

class SalesActivitySyncService {
  final SalesActivityRest api = SalesActivityRest(Dio(Environment.dioBaseOptions)..interceptors.addAll([DioRequestTokenInterceptor()]));

  Future<void> syncPendingActivities() async {
    await Future.delayed(const Duration(seconds: 3));
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    final db = SalesActivityLocalDatabase.instance;
    final pending = await db.getPendingActivities();

    for (final item in pending) {
      final formData = SalesActivityFormData.fromJson(item['data']);

      final result = await api.submitSalesActivity(formData: formData);
      result.fold(
        (failure) => print("Sync failed: ${failure.message}"),
        (success) async {
          await db.deleteActivity(item['id']);
        },
      );
    }
  }
}