import 'package:dartz/dartz.dart';
import 'package:vivakencanaapp/models/stock_opname/stock_opname_hdr.dart';

import '../../../models/errors/custom_exception.dart';
import '../../data_providers/rest_api/stock_opname/opname_stock_hdr_rest.dart';

class OpnameStockHdrRepository {
  final OpnameStockHdrRest rest;

  OpnameStockHdrRepository(this.rest);

  Future<Either<CustomException, List<StockOpnameHdr>>> getOpenOpnameHdr({
    required String millId,
    String? whId,
    String? binId,
  }) {
    return rest.getOpenOpnameHdrByMill(
      millId: millId,
      whId: whId,
      binId: binId,
    );
  }
}
