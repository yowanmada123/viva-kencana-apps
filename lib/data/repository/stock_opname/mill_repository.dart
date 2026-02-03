import 'package:dartz/dartz.dart';
import 'package:vivakencanaapp/models/mill.dart';

import '../../../models/errors/custom_exception.dart';
import '../../data_providers/rest_api/stock_opname/mill_rest.dart';

class MillRepository {
  final MillRest millRest;

  MillRepository({required this.millRest});

  Future<Either<CustomException, List<Mill>>> getMill() async {
    return millRest.getMill();
  }
}
