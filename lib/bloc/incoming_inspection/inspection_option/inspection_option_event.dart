abstract class InspectionOptionEvent {}

/// Muat isi dropdown form header. [millId] opsional untuk membatasi crew dan
/// shift pada satu mill; saat form dibuka biasanya belum ada coil yang discan
/// sehingga mill belum diketahui, jadi dikirim tanpa parameter.
class LoadInspectionOption extends InspectionOptionEvent {
  final String? millId;

  LoadInspectionOption({this.millId});
}
