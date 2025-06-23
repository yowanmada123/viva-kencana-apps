import 'package:dartz/dartz.dart';

import '../../models/entity.dart';
import '../../models/errors/custom_exception.dart';
import '../data_providers/rest_api/entity_rest/entity_rest.dart';

class EntityRepository {
  final EntityRest entityRest;

  EntityRepository({required this.entityRest});

  Future<Either<CustomException, List<Entity>>> getEntities() async {
    return entityRest.getEntities();
  }
}