import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/repository/entity_repository.dart';
import '../../../models/entity.dart';
import '../../../utils/strict_location.dart';

part 'entity_event.dart';
part 'entity_state.dart';

class EntityBloc extends Bloc<EntityEvent, EntityState> {
  final EntityRepository entityRepository;

  EntityBloc({required this.entityRepository}) : super(EntityInitial()) {
    on<LoadEntity>(_loadEntity);
  }

  void _loadEntity(LoadEntity event, Emitter<EntityState> emit) async {
    emit(EntityLoading());
    StrictLocation.checkLocationRequirements();

    final res = await entityRepository.getEntities();

    res.fold(
      (exception) {
        emit(EntityFailure(exception));
      },
      (entities) {
        emit(EntityLoaded(entities: entities));
      },
    );
  }
}
