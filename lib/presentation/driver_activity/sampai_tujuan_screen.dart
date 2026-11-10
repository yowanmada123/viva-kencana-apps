import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:vivakencanaapp/data/repository/driver_activity_repository.dart';
import 'package:vivakencanaapp/models/driver_activity/driver_delivery.dart';
import 'package:vivakencanaapp/utils/strict_location.dart';

class SampaiTujuanScreen extends StatefulWidget {
  final DelivHdrItem delivHdr;
  final String entity;

  const SampaiTujuanScreen({
    super.key,
    required this.delivHdr,
    required this.entity,
  });

  @override
  State<SampaiTujuanScreen> createState() => _SampaiTujuanScreenState();
}

class _SampaiTujuanScreenState extends State<SampaiTujuanScreen> {
  final MapController _mapController = MapController();

  bool _isLoadingLocation = true;
  String? _locationError;
  Position? _currentPosition;
  String? _geocodedAddress;
  bool _isLoadingAddress = false;

  // Default coordinate (Surabaya / Jatim) if GPS is pending
  static const LatLng _defaultCenter = LatLng(-7.250445, 112.768845);

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final position = await StrictLocation.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      _mapController.move(
        LatLng(position.latitude, position.longitude),
        16.0,
      );

      _reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
        _locationError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _reverseGeocode(double latitude, double longitude) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.postalCode,
        ].where((e) => e != null && e.trim().isNotEmpty).toList();

        final formatted = parts.join(', ');
        if (!mounted) return;
        setState(() {
          _geocodedAddress = formatted.isNotEmpty ? formatted : null;
          _isLoadingAddress = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('[SampaiTujuan] Geocoding error: $e');
    }

    if (!mounted) return;
    setState(() {
      _isLoadingAddress = false;
    });
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

  Future<void> _handleConfirmArrival() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Titik koordinat GPS belum tersedia. Silakan muat ulang lokasi.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final pos = _currentPosition!;

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
            Icon(Icons.location_on, color: Colors.blue.shade700, size: 22.w),
            SizedBox(width: 8.w),
            Text(
              'Konfirmasi Sampai',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catat waktu dan lokasi tiba di tujuan untuk Surat Jalan No. ${widget.delivHdr.delivId}?',
              style: TextStyle(fontSize: 12.sp, color: Colors.black87),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.my_location, size: 13.w, color: Colors.blue.shade700),
                      SizedBox(width: 4.w),
                      Text(
                        'Koordinat: ${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  if (_geocodedAddress != null && _geocodedAddress!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      _geocodedAddress!,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.blue.shade800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Sampai di Tujuan'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    _showLoadingDialog('Menyimpan data kedatangan...');
    try {
      final repo = context.read<DriverActivityRepository>();
      final result = await repo.checkPointOrder(
        id: widget.delivHdr.delivId,
        entity: widget.entity,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading dialog

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message ?? 'Gagal mencatat kedatangan'),
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
    final currentLatLng = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : _defaultCenter;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sampai di Tujuan',
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
            onPressed: _isLoadingLocation ? null : _handleConfirmArrival,
            icon: Icon(Icons.location_on, size: 18.w, color: Colors.white),
            label: Text(
              'Konfirmasi Sampai di Tujuan',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade400,
              elevation: 2,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card 1: Informasi Surat Jalan & Pengiriman
            _buildDeliveryInfoCard(primaryColor),

            SizedBox(height: 14.h),

            // Card 2: Peta Lokasi Saat Ini (OpenStreetMap)
            _buildMapCard(currentLatLng, primaryColor),

            SizedBox(height: 14.h),

            // Card 3: Info Alamat & Koordinat GPS Sekarang
            _buildLocationInfoCard(primaryColor),

            SizedBox(height: 20.h),
          ],
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
              label: 'Alamat Tujuan Pengiriman (SJ)',
              value: widget.delivHdr.shipto,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapCard(LatLng centerLatLng, Color primaryColor) {
    return Container(
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
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
            child: Row(
              children: [
                Icon(Icons.map_outlined, size: 16.w, color: primaryColor),
                SizedBox(width: 6.w),
                Text(
                  'Peta Lokasi Sekarang',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (_isLoadingLocation)
                  SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  InkWell(
                    onTap: _fetchCurrentLocation,
                    borderRadius: BorderRadius.circular(6.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      child: Row(
                        children: [
                          Icon(Icons.refresh, size: 13.w, color: primaryColor),
                          SizedBox(width: 2.w),
                          Text(
                            'Refresh',
                            style: TextStyle(fontSize: 10.sp, color: primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
            child: SizedBox(
              height: 250.h,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: centerLatLng,
                      initialZoom: 16.0,
                      maxZoom: 18.0,
                      minZoom: 4.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.vivakencanaapp',
                      ),
                      if (_currentPosition != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                              width: 45.w,
                              height: 45.w,
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade700,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.person_pin_circle,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (_isLoadingLocation)
                    Container(
                      color: Colors.white.withValues(alpha: 0.6),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  Positioned(
                    bottom: 12.h,
                    right: 12.w,
                    child: FloatingActionButton.small(
                      heroTag: 'recenter_gps',
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      elevation: 3,
                      onPressed: () {
                        if (_currentPosition != null) {
                          _mapController.move(
                            LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            16.0,
                          );
                        } else {
                          _fetchCurrentLocation();
                        }
                      },
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfoCard(Color primaryColor) {
    final pos = _currentPosition;

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
              Icon(Icons.pin_drop_outlined, size: 16.w, color: Colors.blue.shade700),
              SizedBox(width: 6.w),
              Text(
                'Data Koordinat & Alamat GPS',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Divider(height: 18.h, color: Colors.grey.shade200),
          if (_locationError != null) ...[
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 18.w, color: Colors.red.shade700),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _locationError!,
                      style: TextStyle(fontSize: 11.sp, color: Colors.red.shade900),
                    ),
                  ),
                  TextButton(
                    onPressed: _fetchCurrentLocation,
                    child: const Text('Ulangi'),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latitude',
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          pos != null ? pos.latitude.toStringAsFixed(6) : '-',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Longitude',
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          pos != null ? pos.longitude.toStringAsFixed(6) : '-',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.place, size: 16.w, color: Colors.red.shade600),
                SizedBox(width: 6.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alamat GPS Sekarang:',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      if (_isLoadingAddress)
                        Row(
                          children: [
                            SizedBox(
                              width: 10.w,
                              height: 10.w,
                              child: const CircularProgressIndicator(strokeWidth: 1.5),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Mencari alamat lokasi...',
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                            ),
                          ],
                        )
                      else
                        Text(
                          _geocodedAddress ?? 'Alamat tidak ditemukan (koordinat tetap tercatat)',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: _geocodedAddress != null ? Colors.black87 : Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
}

