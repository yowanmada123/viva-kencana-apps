import 'package:dartz/dartz.dart';

import '../../models/errors/custom_exception.dart';
import '../../models/receive_warehouse/receive_warehouse.dart';
import '../data_providers/rest_api/receive_warehouse/receive_warehouse_rest.dart';

class ReceiveWarehouseRepository {
  final ReceiveWarehouseRest receiveWarehouseRest;

  ReceiveWarehouseRepository({required this.receiveWarehouseRest});

  Future<Either<CustomException, RwOption>> getOption() {
    return receiveWarehouseRest.getOption();
  }

  Future<Either<CustomException, List<RwWarehouse>>> getWarehouses({
    required String millId,
  }) {
    return receiveWarehouseRest.getWarehouses(millId: millId);
  }

  Future<Either<CustomException, RwScanResult>> getByTrId({
    required String trId,
    required RwSelection selection,
  }) {
    return receiveWarehouseRest.getByTrId(
      trId: trId,
      millId: selection.mill.millID,
      whId: selection.warehouse.whId,
    );
  }

  Future<Either<CustomException, RwReceived>> submit({
    required String trId,
    required RwSelection selection,
  }) {
    return receiveWarehouseRest.submit(
      trId: trId,
      millId: selection.mill.millID,
      whId: selection.warehouse.whId,
      shift: selection.shift,
    );
  }
}
