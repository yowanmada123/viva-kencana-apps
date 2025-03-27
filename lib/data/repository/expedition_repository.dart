import 'package:dartz/dartz.dart';

import '../../models/errors/custom_exception.dart';
import '../../models/vehicle.dart';
import '../data_providers/rest_api/expedition_rest/expedition_rest.dart';

class ExpeditionRepository {
  final ExpeditionRest expeditionRest;

  ExpeditionRepository({required this.expeditionRest});

  Future<Either<CustomException, List<Vehicle>>> getVehicles({
    required String userId,
  }) async {
    return expeditionRest.getVehicles(userId: userId);
  }

  Future<Either<CustomException, void>> updateVehicleStatus({
    required String vehicleID,
    required String status,
  }) async {
    return expeditionRest.updateVehicleStatus(
      vehicleID: vehicleID,
      status: status,
    );
  }
}
