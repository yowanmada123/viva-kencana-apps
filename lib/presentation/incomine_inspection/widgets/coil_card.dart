import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../models/incoming_inspection/barcode_coil.dart';

/// Kartu ringkas untuk satu baris v_barcode_coil.
///
/// List hanya memuat coil yang SUDAH diinspeksi, jadi kartu dipimpin oleh
/// identitas inspeksinya (nomor inspeksi, surat jalan, tanggal) lalu identitas
/// coil-nya. Sengaja hanya sebagian kolom; sisanya dibuka di layar detail saat
/// kartu ditekan.
class CoilCard extends StatelessWidget {
  final BarcodeCoil coil;
  final VoidCallback onTap;

  const CoilCard({super.key, required this.coil, required this.onTap});

  static final NumberFormat _number = NumberFormat('#,##0.####', 'id_ID');
  static final DateFormat _date = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Card(
      margin: EdgeInsets.only(bottom: 8.w),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Baris atas: nomor inspeksi + tanggal
              Row(
                children: [
                  Icon(Icons.fact_check_outlined, size: 18.w, color: primary),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      coil.trxId.isEmpty ? '-' : coil.trxId,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (coil.dtTrx != null)
                    Text(
                      _date.format(coil.dtTrx!),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),

              SizedBox(height: 8.w),
              Divider(height: 1, color: Colors.grey.shade200),
              SizedBox(height: 8.w),

              /// No CRC - identitas utama coil di layar ini
              _Line(
                icon: Icons.qr_code_2,
                text: coil.coilId.isEmpty ? '-' : coil.coilId,
                bold: true,
              ),

              /// Surat jalan + nomor kendaraan
              _Line(
                icon: Icons.local_shipping_outlined,
                text: [
                  if (coil.noSj.isNotEmpty) 'SJ ${coil.noSj}',
                  if (coil.noKendaraan.isNotEmpty) coil.noKendaraan,
                ].join('  •  '),
              ),

              /// Vendor
              _Line(
                icon: Icons.storefront_outlined,
                text:
                    coil.vendorName.isEmpty
                        ? coil.vendorId
                        : '${coil.vendorId} - ${coil.vendorName}',
              ),

              /// Produk
              _Line(
                icon: Icons.inventory_2_outlined,
                text: [
                  if (coil.prodCode.isNotEmpty) coil.prodCode,
                  if (coil.descr.isNotEmpty) coil.descr,
                ].join(' - '),
              ),

              SizedBox(height: 8.w),

              /// Dimensi, berat, hasil pemeriksaan
              Wrap(
                spacing: 6.w,
                runSpacing: 6.w,
                children: [
                  _Chip(
                    label:
                        '${_number.format(coil.thick)} x ${_number.format(coil.width)}',
                  ),
                  _Chip(
                    label:
                        'Net ${_number.format(coil.wgtNet)} ${coil.unitMeas}',
                  ),
                  if (coil.area.isNotEmpty) _Chip(label: 'Area ${coil.area}'),
                  if (coil.storage.isNotEmpty) _Chip(label: coil.storage),
                  _Chip(
                    label:
                        coil.isReceived ? 'Sudah diterima' : 'Belum diterima',
                    color:
                        coil.isReceived
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                  ),
                ],
              ),

              SizedBox(height: 4.w),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Lihat detail  ›',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;

  const _Line({required this.icon, required this.text, this.bold = false});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.w, color: Colors.grey.shade500),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                color: bold ? Colors.grey.shade900 : Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? color;

  const _Chip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11.sp,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
}
