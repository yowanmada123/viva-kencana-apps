import 'package:dartz/dartz.dart';

import '../../../models/errors/custom_exception.dart';
import '../../../models/stock_opname/prod_add.dart';
import '../../../models/stock_opname/prod_tor.dart';
import '../../data_providers/rest_api/stock_opname/master_prod_rest.dart';

class ProdMasterRepository {
  final ProdMasterRest rest;
  ProdMasterRepository(this.rest);

  Future<Either<CustomException, List<ProdAdd>>> getProdAdd() {
    return rest.getProdAdd();
  }

  Future<Either<CustomException, List<ProdTor>>> getProdTor() {
    return rest.getProdTor();
  }
}
