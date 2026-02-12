import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:vivakencanaapp/models/stock_opname/warehouse_bin.dart';

class WHBinRest {
  final Dio dio;

  WHBinRest(this.dio);

  Future<List<WHBin>> fetchBins({
    required String millId,
    required String whId,
  }) async {
    log('payload : $millId & $whId');
    final res = await dio.post(
      'api/listWHBinKMB',
      queryParameters: {'mill_id': millId, 'wh_id': whId},
    );
    log('Reseponse listWHBinKMB : $res');

    final List data = res.data['data'];
    return data.map((e) => WHBin.fromMap(e)).toList();
  }
}
