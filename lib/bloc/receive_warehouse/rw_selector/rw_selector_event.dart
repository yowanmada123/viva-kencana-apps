part of 'rw_selector_bloc.dart';

abstract class RwSelectorEvent {
  const RwSelectorEvent();
}

/// Muat daftar mill saat layar dibuka.
class RwSelectorStarted extends RwSelectorEvent {
  const RwSelectorStarted();
}

/// Mill berganti: kosongkan warehouse lalu muat ulang daftarnya.
class RwSelectorMillChanged extends RwSelectorEvent {
  final Mill mill;

  const RwSelectorMillChanged(this.mill);
}
