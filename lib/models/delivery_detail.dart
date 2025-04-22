import 'dart:convert';

class DeliveryDetail {
  final String millID;
  final String trType;
  final String delivID;
  final String orderID;
  final String itemNumber;
  final String qtyShip;
  final String tfs;
  final String dtModified;
  final String descr;
  final String stat;
  final String takenFrom;
  final String qtyDepo;
  final String whID;
  final String binID;
  final String batchID;
  final String lengthShip;
  final String qtyKupon;
  final String startLoad;
  final String endLoad;
  final String userLoad;
  DeliveryDetail({
    required this.millID,
    required this.trType,
    required this.delivID,
    required this.orderID,
    required this.itemNumber,
    required this.qtyShip,
    required this.tfs,
    required this.dtModified,
    required this.descr,
    required this.stat,
    required this.takenFrom,
    required this.qtyDepo,
    required this.whID,
    required this.binID,
    required this.batchID,
    required this.lengthShip,
    required this.qtyKupon,
    required this.startLoad,
    required this.endLoad,
    required this.userLoad,
  });

  DeliveryDetail copyWith({
    String? millID,
    String? trType,
    String? delivID,
    String? orderID,
    String? itemNumber,
    String? qtyShip,
    String? tfs,
    String? dtModified,
    String? descr,
    String? stat,
    String? takenFrom,
    String? qtyDepo,
    String? whID,
    String? binID,
    String? batchID,
    String? lengthShip,
    String? qtyKupon,
    String? startLoad,
    String? endLoad,
    String? userLoad,
  }) {
    return DeliveryDetail(
      millID: millID ?? this.millID,
      trType: trType ?? this.trType,
      delivID: delivID ?? this.delivID,
      orderID: orderID ?? this.orderID,
      itemNumber: itemNumber ?? this.itemNumber,
      qtyShip: qtyShip ?? this.qtyShip,
      tfs: tfs ?? this.tfs,
      dtModified: dtModified ?? this.dtModified,
      descr: descr ?? this.descr,
      stat: stat ?? this.stat,
      takenFrom: takenFrom ?? this.takenFrom,
      qtyDepo: qtyDepo ?? this.qtyDepo,
      whID: whID ?? this.whID,
      binID: binID ?? this.binID,
      batchID: batchID ?? this.batchID,
      lengthShip: lengthShip ?? this.lengthShip,
      qtyKupon: qtyKupon ?? this.qtyKupon,
      startLoad: startLoad ?? this.startLoad,
      endLoad: endLoad ?? this.endLoad,
      userLoad: userLoad ?? this.userLoad,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mill_id': millID,
      'tr_type': trType,
      'deliv_id': delivID,
      'order_id': orderID,
      'item_num': itemNumber,
      'qty_ship': qtyShip,
      'tfs': tfs,
      'dt_modified': dtModified,
      'descr': descr,
      'stat': stat,
      'taken_from': takenFrom,
      'qty_depo': qtyDepo,
      'wh_id': whID,
      'bin_id': binID,
      'batch_id': batchID,
      'length_ship': lengthShip,
      'qty_kupon': qtyKupon,
      'start_load': startLoad,
      'end_load': endLoad,
      'user_load': userLoad,
    };
  }

  factory DeliveryDetail.fromMap(Map<String, dynamic> map) {
    return DeliveryDetail(
      millID: map['mill_id'] ?? '',
      trType: map['tr_type'] ?? '',
      delivID: map['deliv_id'] ?? '',
      orderID: map['order_id'] ?? '',
      itemNumber: map['item_num'] ?? '',
      qtyShip: map['qty_ship'] ?? '',
      tfs: map['tfs'] ?? '',
      dtModified: map['dt_modified'] ?? '',
      descr: map['descr'] ?? '',
      stat: map['stat'] ?? '',
      takenFrom: map['taken_from'] ?? '',
      qtyDepo: map['qty_depo'] ?? '',
      whID: map['wh_id'] ?? '',
      binID: map['bin_id'] ?? '',
      batchID: map['batch_id'] ?? '',
      lengthShip: map['length_ship'] ?? '',
      qtyKupon: map['qty_kupon'] ?? '',
      startLoad: map['start_load'] ?? '',
      endLoad: map['end_load'] ?? '',
      userLoad: map['user_load'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DeliveryDetail.fromJson(String source) =>
      DeliveryDetail.fromMap(json.decode(source));

  @override
  String toString() {
    return 'DeliveryDetail(mill_id: $millID, tr_type: $trType, deliv_id: $delivID, order_id: $orderID, item_num: $itemNumber, qty_ship: $qtyShip, tfs: $tfs, dt_modified: $dtModified, descr: $descr, stat: $stat, taken_from: $takenFrom, qty_depo: $qtyDepo, wh_id: $whID, bin_id: $binID, batch_id: $batchID, length_ship: $lengthShip, qty_kupon: $qtyKupon, start_load: $startLoad, end_load: $endLoad, user_load: $userLoad)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeliveryDetail &&
        other.millID == millID &&
        other.trType == trType &&
        other.delivID == delivID &&
        other.orderID == orderID &&
        other.itemNumber == itemNumber &&
        other.qtyShip == qtyShip &&
        other.tfs == tfs &&
        other.dtModified == dtModified &&
        other.descr == descr &&
        other.stat == stat &&
        other.takenFrom == takenFrom &&
        other.qtyDepo == qtyDepo &&
        other.whID == whID &&
        other.binID == binID &&
        other.batchID == batchID &&
        other.lengthShip == lengthShip &&
        other.qtyKupon == qtyKupon &&
        other.startLoad == startLoad &&
        other.endLoad == endLoad &&
        other.userLoad == userLoad;
  }

  @override
  int get hashCode {
    return millID.hashCode ^
        trType.hashCode ^
        delivID.hashCode ^
        orderID.hashCode ^
        itemNumber.hashCode ^
        qtyShip.hashCode ^
        tfs.hashCode ^
        dtModified.hashCode ^
        descr.hashCode ^
        stat.hashCode ^
        takenFrom.hashCode ^
        qtyDepo.hashCode ^
        whID.hashCode ^
        binID.hashCode ^
        batchID.hashCode ^
        lengthShip.hashCode ^
        qtyKupon.hashCode ^
        startLoad.hashCode ^
        endLoad.hashCode ^
        userLoad.hashCode;
  }
}
