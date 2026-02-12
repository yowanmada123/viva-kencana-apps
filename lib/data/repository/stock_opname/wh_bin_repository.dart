import 'package:vivakencanaapp/data/data_providers/rest_api/stock_opname/bin_rest.dart';
import 'package:vivakencanaapp/models/stock_opname/warehouse_bin.dart';

class WHBinRepository {
  final WHBinRest binRepository;
  WHBinRepository(this.binRepository);

  Future<List<WHBin>> getBins({required String millId, required String whId}) {
    return binRepository.fetchBins(millId: millId, whId: whId);
  }
}
