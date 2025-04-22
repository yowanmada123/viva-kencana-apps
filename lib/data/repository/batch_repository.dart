import 'package:dartz/dartz.dart';
import 'package:vivakencanaapp/models/batch.dart';
import 'package:vivakencanaapp/models/delivery_detail.dart';

import '../../models/errors/custom_exception.dart';
import '../data_providers/rest_api/batch_rest/batch_rest.dart';

class BatchRepository {
  final BatchRest batchRest;

  BatchRepository({required this.batchRest});

  Future<Either<CustomException, Batch>> getBatch({
    required String deliveryID,
  }) async {
    return batchRest.getBatch(deliveryID: deliveryID);
  }

  Future<Either<CustomException, List<DeliveryDetail>>> getDeliveryDetail({
    required String batchID,
    required String companyID,
    required String millID,
    required String whID,
  }) async {
    return batchRest.getDeliveryDetail(
      batchID: batchID,
      companyID: companyID,
      millID: millID,
      whID: whID,
    );
  }

  Future<Either<CustomException, List<DeliveryDetail>>> confirmLoad({
    required String batchID,
    required String companyID,
    required String millID,
    required String whID,
  }) async {
    return batchRest.confirmLoad(
      batchID: batchID,
      companyID: companyID,
      millID: millID,
      whID: whID,
    );
  }

  Future<Either<CustomException, List<DeliveryDetail>>> cancelLoad({
    required String batchID,
    required String delivID,
    required String companyID,
    required String millID,
    required String whID,
    required String itemNum,
  }) async {
    return batchRest.cancelLoad(
      batchID: batchID,
      delivID: delivID,
      companyID: companyID,
      millID: millID,
      whID: whID,
      itemNum: itemNum,
    );
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
