part of 'entity_bloc.dart';

sealed class EntityEvent extends Equatable {
  const EntityEvent();

  @override
  List<Object> get props => [];
}

class LoadEntity extends EntityEvent {}
