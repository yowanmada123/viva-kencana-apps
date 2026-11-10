import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:vivakencanaapp/data/repository/driver_activity_repository.dart';
import 'package:vivakencanaapp/models/driver_activity/driver_delivery.dart';
import 'package:vivakencanaapp/utils/strict_location.dart';

class BongkarMuatScreen extends StatefulWidget {
  final DelivHdrItem delivHdr;
  final String entity;

  const BongkarMuatScreen({
    super.key,
    required this.delivHdr,
    required this.entity,
  });

  @override
  State<BongkarMuatScreen> createState() => _BongkarMuatScreenState();
}

class _BongkarMuatScreenState extends State<BongkarMuatScreen> {
  final ImagePicker _picker = ImagePicker();

  bool _isLoadingItems = true;
  String? _itemsErrorMessage;
  List<DriverDeliveryDetailItem> _items = [];

  File? _selectedImage;
  File? _compressedImage;
  bool _isCompressing = false;
  int _originalSizeBytes = 0;
  int _compressedSizeBytes = 0;

  @override
  void initState() {
    super.initState();
    _fetchDetailItems();
  }

  Future<void> _fetchDetailItems() async {
    setState(() {
      _isLoadingItems = true;
      _itemsErrorMessage = null;
    });

    final repo = context.read<DriverActivityRepository>();
    final result = await repo.getDetailItem(
      entity: widget.entity,
      id: widget.delivHdr.delivId,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoadingItems = false;
          _itemsErrorMessage = failure.message ?? 'Gagal memuat item muatan';
        });
      },
      (data) {
        setState(() {
          _isLoadingItems = false;
          _items = data;
        });
      },
    );
  }

  Future<File?> _compressImageFile(File file) async {
    try {
      final targetPath =
          "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 65,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (result != null) {
        return File(result.path);
      }
    } catch (e) {
      debugPrint('[BongkarMuat] Gagal mengompres gambar: $e');
    }
    return null;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (picked == null) return;

      final originalFile = File(picked.path);
      final origSize = await originalFile.length();

      setState(() {
        _isCompressing = true;
        _selectedImage = originalFile;
        _originalSizeBytes = origSize;
      });

      final compressed = await _compressImageFile(originalFile);
      final finalFile = compressed ?? originalFile;
      final compSize = await finalFile.length();

      if (!mounted) return;

      setState(() {
        _isCompressing = false;
        _compressedImage = finalFile;
        _compressedSizeBytes = compSize;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCompressing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.blue.shade700),
                  ),
                  title: const Text('Ambil Foto (Kamera)'),
                  subtitle: const Text('Gunakan kamera untuk memfoto barang'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_library, color: Colors.green.shade700),
                  ),
                  title: const Text('Pilih dari Galeri'),
                  subtitle: const Text('Pilih foto yang tersimpan di galeri HP'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _compressedImage = null;
      _originalSizeBytes = 0;
      _compressedSizeBytes = 0;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty || rawDate.startsWith('1900-01-01')) {
      return '-';
    }
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          content: Row(
            children: [
              const CircularProgressIndicator(),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleConfirmBongkar() async {
    final hasPhoto = _compressedImage != null || _selectedImage != null;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.inventory_2, color: Colors.orange.shade800, size: 22.w),
            SizedBox(width: 8.w),
            Text(
              'Konfirmasi Bongkar',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin proses bongkar muat untuk Surat Jalan No. ${widget.delivHdr.delivId} sudah selesai?',
              style: TextStyle(fontSize: 12.sp, color: Colors.black87),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: hasPhoto ? Colors.green.shade50 : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: hasPhoto ? Colors.green.shade200 : Colors.amber.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasPhoto ? Icons.check_circle : Icons.info_outline,
                    size: 15.w,
                    color: hasPhoto ? Colors.green.shade700 : Colors.amber.shade800,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      hasPhoto
                          ? 'Foto bukti terlampir (${_formatFileSize(_compressedSizeBytes)})'
                          : 'Tidak melampirkan foto bukti (Opsional)',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: hasPhoto ? Colors.green.shade800 : Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Selesai Bongkar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    _showLoadingDialog('Mencatat lokasi GPS & mengunggah data...');
    try {
      final position = await StrictLocation.getCurrentPosition();

      File? finalUploadFile = _compressedImage ?? _selectedImage;
      if (finalUploadFile != null && _compressedImage == null) {
        final compressed = await _compressImageFile(finalUploadFile);
        if (compressed != null) {
          finalUploadFile = compressed;
        }
      }

      if (!mounted) return;
      final repo = context.read<DriverActivityRepository>();
      final result = await repo.dropOrder(
        id: widget.delivHdr.delivId,
        entity: widget.entity,
        latitude: position.latitude,
        longitude: position.longitude,
        imageFile: finalUploadFile,
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading dialog

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message ?? 'Gagal memproses bongkar muat'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        (successMsg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMsg),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bongkar Muat',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'No. SJ: ${widget.delivHdr.delivId}',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _handleConfirmBongkar,
            icon: Icon(Icons.check_circle_outline, size: 18.w, color: Colors.white),
            label: Text(
              'Konfirmasi Selesai Bongkar',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDetailItems,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card 1: Informasi Surat Jalan & Pengiriman
              _buildDeliveryInfoCard(primaryColor),

              SizedBox(height: 14.h),

              // Card 2: Foto Bukti Bongkar Muat (Opsional)
              _buildPhotoUploadCard(primaryColor),

              SizedBox(height: 14.h),

              // Card 3: Daftar Item Muatan
              _buildItemsCard(primaryColor),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryInfoCard(Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 16.w,
                  color: primaryColor,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No. SJ: ${widget.delivHdr.delivId}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (widget.delivHdr.orderId.isNotEmpty)
                      Text(
                        'Order: ${widget.delivHdr.orderId}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  widget.entity,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 18.h, color: Colors.grey.shade200),
          if (widget.delivHdr.receiver.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.storefront_outlined,
              iconColor: Colors.grey.shade700,
              label: 'Penerima / Toko',
              value: widget.delivHdr.receiver,
            ),
            SizedBox(height: 8.h),
          ],
          if (widget.delivHdr.shipto.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              iconColor: Colors.red.shade400,
              label: 'Alamat Pengiriman',
              value: widget.delivHdr.shipto,
            ),
            SizedBox(height: 8.h),
          ],
          if (widget.delivHdr.shipDate.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              iconColor: Colors.grey.shade600,
              label: 'Tanggal Kirim',
              value: _formatDate(widget.delivHdr.shipDate),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.w, color: iconColor),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadCard(Color primaryColor) {
    final imageFile = _compressedImage ?? _selectedImage;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt_outlined, size: 16.w, color: primaryColor),
              SizedBox(width: 6.w),
              Text(
                'Foto Bukti Bongkar Muat',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'Opsional',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Ambil foto barang atau lokasi saat bongkar muat dilakukan.',
            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 12.h),

          if (_isCompressing) ...[
            Container(
              padding: EdgeInsets.all(20.h),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 10.h),
                  Text(
                    'Mengompres ukuran gambar...',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ] else if (imageFile != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.file(
                    imageFile,
                    width: double.infinity,
                    height: 200.h,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: InkWell(
                      onTap: _clearImage,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 16.w),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 14.w, color: Colors.green.shade700),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          'Ukuran Terkompresi: ${_formatFileSize(_compressedSizeBytes)} '
                          '(${_formatFileSize(_originalSizeBytes)})',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _showImageSourcePicker,
                  icon: Icon(Icons.refresh, size: 14.w, color: primaryColor),
                  label: Text(
                    'Ganti',
                    style: TextStyle(fontSize: 11.sp, color: primaryColor),
                  ),
                ),
              ],
            ),
          ] else ...[
            InkWell(
              onTap: _showImageSourcePicker,
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFBFB),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        size: 26.w,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Ketuk untuk Ambil Foto atau Pilih Gambar',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Kamera atau Galeri (Otomatis dikompres)',
                      style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsCard(Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 16.w, color: primaryColor),
              SizedBox(width: 6.w),
              Text(
                'Daftar Item Muatan',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (!_isLoadingItems && _items.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${_items.length} item',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          Divider(height: 18.h, color: Colors.grey.shade200),
          if (_isLoadingItems)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (_itemsErrorMessage != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 30.w, color: Colors.red.shade400),
                    SizedBox(height: 6.h),
                    Text(
                      _itemsErrorMessage!,
                      style: TextStyle(fontSize: 11.sp, color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    ElevatedButton.icon(
                      onPressed: _fetchDetailItems,
                      icon: const Icon(Icons.refresh, size: 14),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  'Tidak ada item yang ditemukan pada muatan ini.',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, __) => Divider(height: 12.h, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 2.h),
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        Icons.check_box_outlined,
                        size: 14.w,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.namaBarang.isNotEmpty ? item.namaBarang : '-',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Text(
                                'Qty: ${item.qtyShip} pcs',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              if (item.panjang.isNotEmpty && item.panjang != '0') ...[
                                SizedBox(width: 8.w),
                                Text(
                                  '•  Panjang: ${item.panjang} m',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

