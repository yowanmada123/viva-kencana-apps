import 'package:dartz/dartz.dart';

import '../../models/errors/custom_exception.dart';
import '../../models/warehouse.dart';
import '../data_providers/rest_api/warehouse_rest/warehouse_rest.dart';

class WarehouseRepository {
  final WarehouseRest warehouseRest;

  WarehouseRepository({required this.warehouseRest});

  Future<Either<CustomException, List<Warehouse>>> getWarehouse({
    required String deliveryID,
  }) async {
    return warehouseRest.getWarehouse(deliveryID: deliveryID);
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
