import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../models/incoming_inspection/barcode_coil.dart';

/// Layar detail satu coil.
///
/// Data TIDAK diambil lagi dari server: satu baris v_barcode_coil sudah memuat
/// 48 kolom, jadi objek [coil] dari list dipakai apa adanya.
///
/// Nilai kode (cuaca, t_atap, t_kondisi, Kondisi CRC) ditampilkan mentah
/// karena sudah berupa kata yang terbaca - CERAH, TERTUTUP, KERING, Y/N.
/// Daftar pilihannya sendiri kini berasal dari server, bukan konstanta di app.
class IncomingInspectionDetailScreen extends StatelessWidget {
  final BarcodeCoil coil;

  const IncomingInspectionDetailScreen({super.key, required this.coil});

  static final NumberFormat _number = NumberFormat('#,##0.####', 'id_ID');
  static final NumberFormat _money = NumberFormat('#,##0.00', 'id_ID');
  static final DateFormat _date = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Detail Coil',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.w,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(8.w),
          children: [
            _buildHeaderCard(context),

            /// Bagian inspeksi hanya relevan kalau sudah pernah diinspeksi.
            /// List memang hanya memuat yang sudah, tapi layar ini tetap
            /// dijaga supaya aman kalau dipanggil dari tempat lain.
            if (!coil.isOpenInspection) ...[
              _Section(
                title: 'Data Inspeksi',
                icon: Icons.fact_check_outlined,
                rows: [
                  _Row('No Inspeksi', coil.trxId),
                  _Row('No Surat Jalan', coil.noSj),
                  _Row('No Kendaraan', coil.noKendaraan),
                  _Row(
                    'Tanggal Transaksi',
                    coil.dtTrx == null ? '' : _date.format(coil.dtTrx!),
                  ),
                  _Row('Shift', coil.shiftNum),
                  _Row('Crew', coil.crewId),
                  _Row('Cuaca', coil.cuaca),
                  _Row('Kondisi Atap', coil.tAtap),
                  _Row('Kondisi Terpal', coil.tKondisi),
                  _Row(
                    'Waktu Loading',
                    (coil.startTime == null && coil.endTime == null)
                        ? ''
                        : '${coil.startTime == null ? '-' : _dateTime.format(coil.startTime!)}'
                            '  s/d  '
                            '${coil.endTime == null ? '-' : _dateTime.format(coil.endTime!)}',
                  ),
                  _Row('Storage', coil.storage),
                ],
              ),

              _Section(
                title: 'Hasil Pemeriksaan Fisik',
                icon: Icons.checklist_rtl,
                rows: [
                  _Row('OD', coil.od),
                  _Row('Strapping', coil.strapping),
                  _Row('Surface', coil.surface),
                  _Row(
                    'Berat Label',
                    '${_number.format(coil.wgtLabel)} ${coil.unitMeas}'
                    /// Tandai kalau berat di label berbeda dari data sistem -
                    /// itu justru alasan kolom ini dicatat.
                    '${coil.wgtLabel != coil.wgtNet ? '  (wgt_net: ${_number.format(coil.wgtNet)})' : ''}',
                  ),
                  _Row('Area', coil.area),
                  _Row('Keterangan', coil.remark),
                ],
              ),
            ] else
              _EmptyNotice(
                icon: Icons.pending_actions_outlined,
                message:
                    'Coil ini belum diinspeksi. Buat data inspeksi lewat tombol '
                    'Inspeksi di layar sebelumnya, lalu scan barcode coil.',
              ),

            _Section(
              title: 'Identitas Coil',
              icon: Icons.qr_code_2,
              rows: [
                _Row('No CRC / Coil ID', coil.coilId),
                _Row('Container ID', coil.containerId),
                _Row('Mill ID', coil.millId),
                _Row('Warehouse', coil.whId),
              ],
            ),

            _Section(
              title: 'Packing List & Vendor',
              icon: Icons.receipt_long_outlined,
              rows: [
                _Row('PL ID', coil.plId),
                _Row('PL Item', coil.plItem),
                _Row('Vendor ID', coil.vendorId),
                _Row('Vendor Name', coil.vendorName),
              ],
            ),

            _Section(
              title: 'Spesifikasi Produk',
              icon: Icons.inventory_2_outlined,
              rows: [
                _Row('Prod Code', coil.prodCode),
                _Row('Deskripsi', coil.descr),
                _Row('Thickness', _number.format(coil.thick)),
                _Row('Width', _number.format(coil.width)),
                _Row(
                  'Berat Net',
                  '${_number.format(coil.wgtNet)} ${coil.unitMeas}',
                ),
                _Row(
                  'Berat Gross',
                  '${_number.format(coil.wgtGross)} ${coil.unitMeas}',
                ),
                _Row('Unit Meas', coil.unitMeas),
                _Row('Unit Meas PO', coil.unitMeasPo),
                _Row('Unit Conv', _number.format(coil.unitConv)),
              ],
            ),

            _Section(
              title: 'Purchase Order',
              icon: Icons.shopping_cart_outlined,
              rows: [
                _Row('PO ID', coil.poId),
                _Row('PO Item', coil.poItem),
                _Row('Currency', coil.currId),
                _Row('Curr Rate', _money.format(coil.currRate)),
                _Row('Unit Price', _money.format(coil.unitPrice)),
              ],
            ),

            _Section(
              title: 'Kontrak & Purchase Request',
              icon: Icons.assignment_outlined,
              rows: [
                _Row('Contract ID', coil.contrId),
                _Row('Contract Item', coil.contrItem),
                _Row('PR ID', coil.prId),
                _Row('PR Item', coil.prItem),
                _Row('Department', coil.deptId),
                _Row('Section', coil.sectId),
              ],
            ),

            _Section(
              title: 'Penerimaan Gudang',
              icon: Icons.warehouse_outlined,
              rows: [
                _Row('Tr ID', coil.trId),
                _Row(
                  'Status Terima',
                  coil.isReceived ? 'Sudah diterima (C)' : 'Belum diterima (O)',
                ),
              ],
            ),

            SizedBox(height: 16.w),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            coil.coilId.isEmpty ? '-' : coil.coilId,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.w),
          Text(
            [
              if (coil.prodCode.isNotEmpty) coil.prodCode,
              if (coil.descr.isNotEmpty) coil.descr,
            ].join(' - '),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: 10.w),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.w,
            children: [
              if (coil.trxId.isNotEmpty) _HeaderBadge(label: coil.trxId),
              _HeaderBadge(
                label:
                    coil.isOpenInspection
                        ? 'Inspeksi: Belum'
                        : 'Inspeksi: Sudah',
              ),
              _HeaderBadge(
                label:
                    coil.isReceived ? 'Terima: Sudah' : 'Terima: Belum',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// WIDGET PENDUKUNG
// =============================================================================

/// Sepasang label - nilai. Nilai kosong ditampilkan sebagai '-' supaya baris
/// tetap sejajar dan user tahu kolomnya memang kosong, bukan hilang.
class _Row {
  final String label;
  final String value;

  _Row(this.label, String value) : value = value.trim().isEmpty ? '-' : value;
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_Row> rows;

  const _Section({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.w, 12.w, 8.w),
            child: Row(
              children: [
                Icon(icon, size: 16.w, color: Theme.of(context).primaryColor),
                SizedBox(width: 6.w),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
            child: Column(
              children:
                  rows.map((row) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120.w,
                            child: Text(
                              row.label,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              row.value,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotice extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyNotice({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.w, color: Colors.orange.shade700),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String label;

  const _HeaderBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
