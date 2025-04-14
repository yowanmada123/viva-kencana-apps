import 'package:dartz/dartz.dart';
import 'package:dio/src/dio.dart';
import 'package:vivakencanaapp/models/batch.dart';

import '../../models/errors/custom_exception.dart';
import '../data_providers/rest_api/batch_rest/batch_rest.dart';

class BatchRepository {
  final BatchRest batchRest;

  BatchRepository({required this.batchRest});

  Future<Either<CustomException, Batch>> getWarehouse({
    required String deliveryID,
  }) async {
    return batchRest.getBatch(deliveryID: deliveryID);
  }

  // Future<Either<CustomException, void>> updateVehicleStatus({
  //   required String vehicleID,
  //   required String status,
  // }) async {
  //   return warehouseRest.updateVehicleStatus(
  //     vehicleID: vehicleID,
  //     status: status,
  //   );
  // }
}
