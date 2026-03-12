import 'dart:developer';

import 'package:vivakencanaapp/data/data_providers/rest_api/stock_opname/mill_selector_rest.dart';
import 'package:vivakencanaapp/models/mill.dart';

class MillSelectorRepository {
  final MillSelectorRest millSelectorRest;

  MillSelectorRepository({required this.millSelectorRest});

  Future<List<Mill>> getAvailableMill() async {
    final groupId = await millSelectorRest.getGroupUser();

    final officeIdString = await millSelectorRest.getEnvOfficeId(groupId);

    /// jika env_conf null → UI akan fallback ke MillBloc
    if (officeIdString == null || officeIdString.isEmpty) {
      log("ENV_CONF null → trigger fallback ke MillBloc");
      return [];
    }

    final officeIds = officeIdString.split(',').map((e) => e.trim()).toList();

    final mills = await millSelectorRest.getMill();

    final filtered =
        mills.where((mill) => officeIds.contains(mill.millID)).toList();

    return filtered;
  }
}
