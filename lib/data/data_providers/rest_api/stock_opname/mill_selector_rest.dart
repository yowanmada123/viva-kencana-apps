import 'package:dio/dio.dart';
import 'package:vivakencanaapp/models/mill.dart';
import 'dart:developer';

class MillSelectorRest {
  final Dio dio;

  MillSelectorRest(this.dio);

  /// STEP 1
  /// POST /api/menu/group
  Future<String> getGroupUser() async {
    final response = await dio.post(
      "/api/menu/group",
      data: {"entity_id": "KMB", "appl_id": "WAREHOUSE WEB"},
    );

    log("GROUP RESPONSE: ${response.data}");

    if (response.data['status_code'] == 200) {
      return response.data['data']; // DEVELOPMENT
    }

    throw Exception(response.data['message']);
  }

  /// STEP 2
  /// POST /api/menu/env_conf
  Future<String?> getEnvOfficeId(String groupId) async {
    final response = await dio.post(
      "/api/menu/env_conf",
      data: {
        "entity_id": "KMB",
        "appl_id": "WAREHOUSE WEB",
        "groupid": groupId,
        "var_id": "OFFICEID",
      },
    );

    log("ENV CONF RESPONSE: ${response.data}");

    if (response.data['status_code'] == 200) {
      return response.data['data']; // KMJ atau KMJ,KMW
    }

    throw Exception(response.data['message']);
  }

  /// STEP 3
  /// POST /api/kmb/master/mill
  Future<List<Mill>> getMill() async {
    final response = await dio.post("/api/kmb/master/mill", data: {});

    log("MILL RESPONSE: ${response.data}");

    if (response.data['status_code'] == 200) {
      final List data = response.data['data'];

      return data.map((e) => Mill.fromMap(e)).toList();
    }

    throw Exception(response.data['message']);
  }
}
