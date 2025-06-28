import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/repository/authorization_repository.dart';
import '../../../models/menu.dart';

part 'access_menu_event.dart';
part 'access_menu_state.dart';

class AccessMenuBloc extends Bloc<AccessMenuEvent, AccessMenuState> {
  final AuthorizationRepository authorizationRepository;

  AccessMenuBloc(this.authorizationRepository)
    : super(AccessMenuInitial()) {
    on<LoadAccessMenu>(_onLoadAccessMenu);
  }

  Future<void> _onLoadAccessMenu(
    LoadAccessMenu event,
    Emitter<AccessMenuState> emit,
  ) async {
    emit(AccessMenuLoading());

    final result = await authorizationRepository.getMenu(
      event.entityId,
      event.applId,
    );

    result.fold(
      (error) => emit(
        AccessMenuLoadFailure(errorMessage: error.message!, exception: error),
      ),
      (data) {
        return emit(AccessMenuLoadSuccess(menus: data));
      },
    );
  }
}
