abstract class VendorEvent {}

/// Dikirim setiap kali ketikan user berubah (sudah di-debounce di widget).
class SearchVendor extends VendorEvent {
  final String keyword;

  SearchVendor(this.keyword);
}

/// Mengosongkan hasil pencarian, dipakai saat filter vendor di-reset.
class ClearVendor extends VendorEvent {}
