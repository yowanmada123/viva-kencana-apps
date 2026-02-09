import 'package:dartz/dartz.dart';
import 'package:vivakencanaapp/models/errors/custom_exception.dart';

import '../../data_providers/rest_api/stock_opname/opname_update.dart';

class OpnameRepository {
  final OpnameRest rest;
  OpnameRepository(this.rest);

  Future<Either<CustomException, Map<String, dynamic>>> submitOpnameUpdate({
    required Map<String, dynamic> payload,
  }) {
    return rest.submitOpnameUpdate(payload: payload);
  }
}
