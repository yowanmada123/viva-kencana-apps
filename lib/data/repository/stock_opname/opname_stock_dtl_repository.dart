import 'package:dartz/dartz.dart';
import 'package:vivakencanaapp/models/stock_opname/stock_opname_dtl.dart';

import '../../../models/errors/custom_exception.dart';
import '../../data_providers/rest_api/stock_opname/opname_stock_dtl_rest.dart';

class OpnameStockDtlRepository {
  final OpnameStockDtlRest rest;

  OpnameStockDtlRepository(this.rest);

  Future<Either<CustomException, List<StockOpnameDtl>>> getOpnameDetail({
    required String trId,
    required String millId,
    required String whId,
    String? binId,
    String? batchId,
  }) {
    return rest.getOpnameDetail(
      trId: trId,
      millId: millId,
      whId: whId,
      binId: binId,
      batchId: batchId,
    );
  }
}
