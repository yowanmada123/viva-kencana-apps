abstract class OpnameStockHdrEvent {}

class LoadOpnameStockHdr extends OpnameStockHdrEvent {
  final String millId;

  LoadOpnameStockHdr({required this.millId});
}
