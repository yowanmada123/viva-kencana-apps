import 'dart:io';

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

  Future<Either<CustomException, List<DriverDeliveryDetailItem>>> getDetailItem({
    required String entity,
    required String id,
  }) async {
    return await driverActivityRest.getDetailItem(entity: entity, id: id);
  }

  Future<Either<CustomException, String>> goCheckOut({
    required String id,
    required String entity,
  }) async {
    return await driverActivityRest.goCheckOut(id: id, entity: entity);
  }

  Future<Either<CustomException, String>> goCheckIn({
    required String id,
    required String entity,
  }) async {
    return await driverActivityRest.goCheckIn(id: id, entity: entity);
  }

  Future<Either<CustomException, String>> checkPointOrder({
    required String id,
    required String entity,
    required double latitude,
    required double longitude,
  }) async {
    return await driverActivityRest.checkPointOrder(
      id: id,
      entity: entity,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<Either<CustomException, String>> dropOrder({
    required String id,
    required String entity,
    required double latitude,
    required double longitude,
    File? imageFile,
  }) async {
    return await driverActivityRest.dropOrder(
      id: id,
      entity: entity,
      latitude: latitude,
      longitude: longitude,
      imageFile: imageFile,
    );
  }
}
