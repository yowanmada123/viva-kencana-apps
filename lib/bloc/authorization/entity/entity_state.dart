part of 'entity_bloc.dart';

sealed class EntityState extends Equatable {
  const EntityState();

  @override
  List<Object> get props => [];
}

final class EntityInitial extends EntityState {}

class EntityLoading extends EntityState {}

class EntityLoaded extends EntityState {
  final List<Entity> entities;

  const EntityLoaded({required this.entities});

  @override
  List<Object> get props => [entities];
}

class EntityFailure extends EntityState {
  final Exception exception;

  const EntityFailure(this.exception);

  @override
  List<Object> get props => [exception];
}
