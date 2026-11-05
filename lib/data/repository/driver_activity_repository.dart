import 'package:dartz/dartz.dart';
import 'package:vivakencanaapp/data/data_providers/rest_api/driver_activity/driver_activity_rest.dart';
import 'package:vivakencanaapp/models/driver_activity/driver_delivery.dart';
import 'package:vivakencanaapp/models/errors/custom_exception.dart';

class DriverActivityRepository {
  final DriverActivityRest driverActivityRest;

  DriverActivityRepository({required this.driverActivityRest});

  Future<Either<CustomException, List<DriverDelivery>>> getDeliveryList() async {
    return await driverActivityRest.getDeliveryList();
  }
}

