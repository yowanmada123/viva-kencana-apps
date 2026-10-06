import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/barcode_candidates.dart';

/// Dialog pemilihan No CRC dari hasil scan.
///
/// Muncul untuk SEMUA hasil scan, termasuk yang isinya teks polos dan hanya
/// punya satu pilihan. Alasannya: pembacaan barcode bisa meleset, dan
/// menampilkan apa yang terbaca sebelum menembak database memberi kesempatan
/// petugas membatalkan tanpa merusak data.
///
/// Mengembalikan nilai yang dipilih, atau null kalau dibatalkan.
class ScanCandidateDialog extends StatelessWidget {
  final ScanPayload payload;

  /// Simbologi yang terbaca, mis. "code39" atau "qrcode".
  final String format;

  const ScanCandidateDialog({
    super.key,
    required this.payload,
    required this.format,
  });

  static Future<String?> show(
    BuildContext context, {
    required ScanPayload payload,
    required String format,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => ScanCandidateDialog(payload: payload, format: format),
    );
  }

  String get _formatLabel {
    switch (format.toLowerCase()) {
      case 'qrcode':
        return 'QR Code';
      case 'code39':
        return 'Code 39';
      case 'code93':
        return 'Code 93';
      case 'code128':
        return 'Code 128';
      case 'datamatrix':
        return 'Data Matrix';
      case 'ean13':
        return 'EAN-13';
      case 'ean8':
        return 'EAN-8';
      case 'itf':
        return 'ITF';
      case 'codabar':
        return 'Codabar';
      default:
        return format;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      titlePadding: EdgeInsets.fromLTRB(20.w, 18.w, 20.w, 8.w),
      contentPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.w),
      actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.w),

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            payload.isSingle ? 'Hasil Scan' : 'Pilih No CRC',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.w),
          Wrap(
            spacing: 6.w,
            runSpacing: 4.w,
            children: [
              _Tag(label: _formatLabel, color: primary),
              _Tag(label: payload.kindLabel, color: Colors.grey.shade600),
            ],
          ),
        ],
      ),

      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!payload.isSingle) ...[
              Text(
                'Hasil scan berisi beberapa nilai. Pilih yang merupakan '
                'No CRC, lalu akan dicek ke data coil.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 10.w),
            ],

            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: payload.candidates.length,
                separatorBuilder: (_, __) => SizedBox(height: 6.w),
                itemBuilder: (context, index) {
                  final item = payload.candidates[index];

                  return _CandidateButton(
                    candidate: item,
                    primary: primary,
                    onTap: () => Navigator.pop(context, item.value),
                  );
                },
              ),
            ),

            /// Teks mentah tetap ditampilkan untuk hasil yang bukan teks polos,
            /// supaya petugas bisa melihat isi aslinya kalau pilihan yang ada
            /// terasa tidak masuk akal.
            if (payload.kind != ScanPayloadKind.text) ...[
              SizedBox(height: 10.w),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  payload.raw,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Satu pilihan berbentuk tombol. Untuk hasil JSON, nama key ditampilkan di
/// atas nilainya supaya petugas tahu nilai itu berasal dari mana.
class _CandidateButton extends StatelessWidget {
  final ScanCandidate candidate;
  final Color primary;
  final VoidCallback onTap;

  const _CandidateButton({
    required this.candidate,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = candidate.likely;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.w),
        decoration: BoxDecoration(
          color: highlight ? primary.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: highlight ? primary : Colors.grey.shade300,
            width: highlight ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (candidate.label != null) ...[
                    Text(
                      candidate.label!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 2.w),
                  ],
                  Text(
                    candidate.value,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18.w, color: primary),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
