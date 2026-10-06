import 'dart:convert';

import 'barcode_coil.dart';

/// Payload `POST api/submitInspection`: satu inspection_hdr beserta
/// baris-baris inspection_dtl-nya.
///
/// Kolom yang TIDAK dikirim aplikasi karena diisi server:
///   trx_id       nomor inspeksi, format IN + YYMM + 4 digit (IN26090001)
///   stat         hdr selalu 'O'; dtl 'O' bila coil ada di v_barcode_coil,
///                'G' bila tidak - server yang menentukan per baris
///   dt_created   timestamp server
///   dt_modifield timestamp server (ejaan mengikuti kolom aslinya)
class InspectionForm {
  /// Boleh kosong. Server akan menurunkannya dari crew yang dipilih, berguna
  /// saat semua item ternyata coil asing yang tidak membawa mill_id.
  final String millId;

  final String noSj;
  final String noKendaraan;
  final DateTime dtTrx;
  final String crewId;
  final String shiftNum;
  final String cuaca;
  final String tAtap;
  final String tKondisi;
  final DateTime startTime;
  final DateTime endTime;
  final String storage;
  final String userId;

  final List<InspectionDetailForm> details;

  InspectionForm({
    this.millId = '',
    required this.noSj,
    required this.noKendaraan,
    required this.dtTrx,
    required this.crewId,
    required this.shiftNum,
    required this.cuaca,
    required this.tAtap,
    required this.tKondisi,
    required this.startTime,
    required this.endTime,
    required this.storage,
    required this.userId,
    required this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      if (millId.isNotEmpty) 'mill_id': millId,
      'no_sj': noSj,
      'no_kendaraan': noKendaraan,
      'dt_trx': _dateOnly(dtTrx),
      'crew_id': crewId,
      'shift_num': shiftNum,
      'cuaca': cuaca,
      't_atap': tAtap,
      't_kondisi': tKondisi,
      'start_time': _timeOnly(startTime),
      'end_time': _timeOnly(endTime),
      'storage': storage,
      'user_id': userId,
      'details': details.map((e) => e.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  static String _dateOnly(DateTime value) {
    final yyyy = value.year.toString().padLeft(4, '0');
    final mm = value.month.toString().padLeft(2, '0');
    final dd = value.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  /// Server menggabungkan jam ini dengan dt_trx menjadi datetime2, jadi cukup
  /// kirim HH:mm saja.
  static String _timeOnly(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

/// Satu baris inspection_dtl, hasil satu kali scan barcode.
///
/// Tabel di layar menampilkan: No CRC ([coilId]), Area ([area]),
/// Kondisi CRC, dan Keterangan ([remark]).
///
/// Kondisi CRC bukan satu nilai, melainkan TIGA penilaian Y/N yang masing
/// masing punya kolomnya sendiri di inspection_dtl: [od], [strapping], dan
/// [surface] (semuanya varchar(1)).
class InspectionDetailForm {
  /// No CRC = v_barcode_coil.coil_id
  final String coilId;

  /// Kondisi CRC - 'Y' atau 'N' untuk tiap aspek.
  final String od;
  final String strapping;
  final String surface;

  /// Berat menurut label fisik pada coil. Nilai awalnya diisi dari
  /// v_barcode_coil.wgt_net, lalu boleh diubah petugas kalau angka di label
  /// berbeda. null berarti tidak diisi - dibedakan dari 0.
  final double? wgtLabel;

  final String area;
  final String remark;

  /// Status dari server saat scan: 'O' terdaftar, 'G' tidak terdaftar.
  /// Hanya untuk ditampilkan - server menghitung ulang saat menyimpan.
  final String stat;

  /// Data coil dari view, null kalau coil tidak terdaftar. Dipakai untuk
  /// menampilkan nama produk di baris tabel, tidak dikirim ke server.
  final BarcodeCoil? coil;

  InspectionDetailForm({
    required this.coilId,
    this.od = '',
    this.strapping = '',
    this.surface = '',
    this.wgtLabel,
    this.area = '',
    this.remark = '',
    this.stat = 'O',
    this.coil,
  });

  InspectionDetailForm copyWith({
    String? coilId,
    String? od,
    String? strapping,
    String? surface,
    double? wgtLabel,
    String? area,
    String? remark,
    String? stat,
    BarcodeCoil? coil,
  }) {
    return InspectionDetailForm(
      coilId: coilId ?? this.coilId,
      od: od ?? this.od,
      strapping: strapping ?? this.strapping,
      surface: surface ?? this.surface,
      wgtLabel: wgtLabel ?? this.wgtLabel,
      area: area ?? this.area,
      remark: remark ?? this.remark,
      stat: stat ?? this.stat,
      coil: coil ?? this.coil,
    );
  }

  /// Coil tidak terdaftar di v_barcode_coil - tetap boleh disimpan, tapi
  /// ditandai di layar supaya user sadar.
  bool get isUnregistered => stat.toUpperCase() == 'G';

  /// Lengkap kalau ketiga penilaian Kondisi CRC sudah dipilih.
  bool get isComplete =>
      od.isNotEmpty && strapping.isNotEmpty && surface.isNotEmpty;

  String get productLabel {
    final coil = this.coil;
    if (coil == null) return 'Tidak terdaftar';

    return [
      if (coil.prodCode.isNotEmpty) coil.prodCode,
      if (coil.descr.isNotEmpty) coil.descr,
    ].join(' - ');
  }

  Map<String, dynamic> toMap() {
    return {
      'coil_id': coilId,
      'od': od,
      'strapping': strapping,
      'surface': surface,
      'wgt_label': wgtLabel,
      'area': area,
      'remark': remark,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is InspectionDetailForm && other.coilId == coilId;

  @override
  int get hashCode => coilId.hashCode;
}
