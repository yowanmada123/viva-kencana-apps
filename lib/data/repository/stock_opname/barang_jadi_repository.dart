import 'package:dartz/dartz.dart';
import 'package:vivakencanaapp/data/data_providers/rest_api/stock_opname/barang_jadi_rest.dart';
import 'package:vivakencanaapp/models/stock_opname/barang_jadi.dart';

import '../../../models/errors/custom_exception.dart';

class BarangJadiRepository {
  final BarangJadiRest rest;

  BarangJadiRepository(this.rest);

  Future<Either<CustomException, List<BarangJadi>>> searchBarangJadi({
    required String namaBarang,
  }) {
    return rest.getBarangJadiByName(namaBarang: namaBarang);
  }
}
