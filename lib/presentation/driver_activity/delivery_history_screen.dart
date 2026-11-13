import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vivakencanaapp/bloc/driver_activity/delivery_history/delivery_history_bloc.dart';
import 'package:vivakencanaapp/data/repository/driver_activity_repository.dart';
import 'package:vivakencanaapp/models/driver_activity/driver_delivery.dart';

class DeliveryHistoryScreen extends StatelessWidget {
  final String? entityId;

  const DeliveryHistoryScreen({super.key, this.entityId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliveryHistoryBloc(
        driverActivityRepository: context.read<DriverActivityRepository>(),
      )..add(const GetDeliveryHistoryEvent()),
      child: const _DeliveryHistoryView(),
    );
  }
}

class _DeliveryHistoryView extends StatefulWidget {
  const _DeliveryHistoryView();

  @override
  State<_DeliveryHistoryView> createState() => _DeliveryHistoryViewState();
}

class _DeliveryHistoryViewState extends State<_DeliveryHistoryView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateTime(String rawDate) {
    if (rawDate.isEmpty ||
        rawDate.startsWith('1900-01-01') ||
        rawDate == 'null') {
      return '-';
    }
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(parsed);
    } catch (_) {
      try {
        final parts = rawDate.split(' ');
        if (parts.length > 1) {
          final timeParts = parts[1].split(':');
          if (timeParts.length >= 2) {
            return '${parts[0]} ${timeParts[0]}:${timeParts[1]}';
          }
        }
      } catch (_) {}
      return rawDate;
    }
  }

  String? _calculateDuration(String dtLeave, String dtHome) {
    if (dtLeave.isEmpty ||
        dtLeave.startsWith('1900-01-01') ||
        dtHome.isEmpty ||
        dtHome.startsWith('1900-01-01')) {
      return null;
    }
    try {
      final start = DateTime.parse(dtLeave);
      final end = DateTime.parse(dtHome);
      final diff = end.difference(start);
      if (diff.isNegative) return null;

      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      if (hours > 0) {
        return '$hours jam $minutes menit';
      }
      return '$minutes menit';
    } catch (_) {
      return null;
    }
  }

  void _showMuatanDetailModal(
    BuildContext context,
    String entity,
    DelivHdrItem delivHdr,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return _MuatanDetailBottomSheet(
          entity: entity,
          delivHdr: delivHdr,
          repository: context.read<DriverActivityRepository>(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Delivery History',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () {
              context
                  .read<DeliveryHistoryBloc>()
                  .add(const RefreshDeliveryHistoryEvent());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
          // Search Bar
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari no. batch, nopol, atau tujuan...',
                hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, size: 20.w, color: Colors.grey.shade500),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 18.w, color: Colors.grey.shade500),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),

          // Content List
          Expanded(
            child: BlocBuilder<DeliveryHistoryBloc, DeliveryHistoryState>(
              builder: (context, state) {
                if (state is DeliveryHistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DeliveryHistoryFailure) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.w,
                            color: Colors.red.shade400,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            state.message,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton.icon(
                            onPressed: () {
                              context
                                  .read<DeliveryHistoryBloc>()
                                  .add(const RefreshDeliveryHistoryEvent());
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is DeliveryHistorySuccess) {
                  final allDeliveries = state.deliveries;
                  final filtered = _searchQuery.isEmpty
                      ? allDeliveries
                      : allDeliveries.where((item) {
                          final trId = item.trId.toLowerCase();
                          final vhc = item.vehicleId.toLowerCase();
                          final dest = item.destination.toLowerCase();
                          final mill = item.millName.toLowerCase();
                          final entity = item.entity.toLowerCase();
                          return trId.contains(_searchQuery) ||
                              vhc.contains(_searchQuery) ||
                              dest.contains(_searchQuery) ||
                              mill.contains(_searchQuery) ||
                              entity.contains(_searchQuery);
                        }).toList();

                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<DeliveryHistoryBloc>()
                            .add(const RefreshDeliveryHistoryEvent());
                      },
                      color: primaryColor,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 80.h),
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.history,
                                    size: 48.w,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Belum ada riwayat pengiriman'
                                      : 'Tidak ada riwayat yang cocok dengan pencarian',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Riwayat pengiriman yang telah selesai akan tampil di sini.',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                if (_searchQuery.isNotEmpty)
                                  TextButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                    icon: const Icon(Icons.clear, size: 16),
                                    label: const Text('Reset Pencarian'),
                                  )
                                else
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      context
                                          .read<DeliveryHistoryBloc>()
                                          .add(const RefreshDeliveryHistoryEvent());
                                    },
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('Refresh Data'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<DeliveryHistoryBloc>()
                          .add(const RefreshDeliveryHistoryEvent());
                    },
                    color: primaryColor,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(14.w),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final batch = filtered[index];
                        return _buildHistoryBatchCard(batch, primaryColor);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildHistoryBatchCard(DriverDelivery batch, Color primaryColor) {
    final duration = _calculateDuration(batch.dtLeave, batch.dtHome);

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
          // Header Card: Batch ID, Entity, Status
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_shipping,
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
                        'Batch: ${batch.trId.isNotEmpty ? batch.trId : "-"}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (batch.destination.isNotEmpty)
                        Text(
                          batch.destination,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    batch.entity,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Text(
                    'Selesai',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // Detail Info: Nopol, Pabrik, Tgl Transaksi
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 6.h),
            child: Row(
              children: [
                Icon(Icons.directions_car_outlined, size: 14.w, color: Colors.grey.shade600),
                SizedBox(width: 4.w),
                Text(
                  batch.vehicleId.isNotEmpty ? batch.vehicleId : '-',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 14.w),
                Icon(Icons.business_outlined, size: 14.w, color: Colors.grey.shade600),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    batch.millName.isNotEmpty ? batch.millName : batch.entity,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Info Waktu Berangkat (dt_leave) dan Pulang (dt_home)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Berangkat (dt_leave)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.departure_board,
                                size: 14.w,
                                color: Colors.orange.shade800,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Berangkat',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    _formatDateTime(batch.dtLeave),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 28.h,
                        width: 1,
                        color: Colors.grey.shade200,
                      ),
                      SizedBox(width: 8.w),
                      // Pulang (dt_home)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.home_outlined,
                                size: 14.w,
                                color: Colors.teal.shade700,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pulang',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    _formatDateTime(batch.dtHome),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (duration != null) ...[
                    Divider(height: 14.h, color: Colors.grey.shade200),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer_outlined, size: 13.w, color: Colors.indigo.shade700),
                        SizedBox(width: 4.w),
                        Text(
                          'Total Durasi Perjalanan: $duration',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Surat Jalan Expansion / Preview
          if (batch.delivHdrItems.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 12.h),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.receipt_long,
                    size: 16.w,
                    color: primaryColor,
                  ),
                  title: Text(
                    '${batch.delivHdrItems.length} Surat Jalan',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  subtitle: Text(
                    'Ketuk untuk melihat rincian muatan surat jalan',
                    style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade500),
                  ),
                  children: batch.delivHdrItems.map((delivHdr) {
                    return Container(
                      margin: EdgeInsets.only(top: 8.h),
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBFBFB),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'No. SJ: ${delivHdr.delivId}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () => _showMuatanDetailModal(
                                  context,
                                  batch.entity,
                                  delivHdr,
                                ),
                                borderRadius: BorderRadius.circular(6.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 12.w,
                                        color: primaryColor,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Detail Item',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (delivHdr.receiver.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.storefront, size: 12.w, color: Colors.grey.shade600),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    delivHdr.receiver,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (delivHdr.shipto.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 12.w, color: Colors.red.shade400),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    delivHdr.shipto,
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              if (delivHdr.hasArrived) ...[
                                Icon(Icons.check_circle, size: 11.w, color: Colors.green.shade700),
                                SizedBox(width: 3.w),
                                Text(
                                  'Tiba: ${_formatDateTime(delivHdr.dtArrive)}',
                                  style: TextStyle(fontSize: 9.sp, color: Colors.green.shade800),
                                ),
                                SizedBox(width: 8.w),
                              ],
                              if (delivHdr.hasDropped) ...[
                                Icon(Icons.check_circle, size: 11.w, color: Colors.teal.shade700),
                                SizedBox(width: 3.w),
                                Text(
                                  'Bongkar: ${_formatDateTime(delivHdr.dtDrop)}',
                                  style: TextStyle(fontSize: 9.sp, color: Colors.teal.shade800),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ] else ...[
            SizedBox(height: 6.h),
          ],
        ],
      ),
    );
  }
}

class _MuatanDetailBottomSheet extends StatefulWidget {
  final String entity;
  final DelivHdrItem delivHdr;
  final DriverActivityRepository repository;

  const _MuatanDetailBottomSheet({
    required this.entity,
    required this.delivHdr,
    required this.repository,
  });

  @override
  State<_MuatanDetailBottomSheet> createState() =>
      _MuatanDetailBottomSheetState();
}

class _MuatanDetailBottomSheetState extends State<_MuatanDetailBottomSheet> {
  bool _isLoading = true;
  String? _errorMessage;
  List<DriverDeliveryDetailItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await widget.repository.getDetailItem(
      entity: widget.entity,
      id: widget.delivHdr.delivId,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message ?? 'Gagal memuat detail muatan';
        });
      },
      (data) {
        setState(() {
          _isLoading = false;
          _items = data;
        });
      },
    );
  }

  num get _totalQty {
    return _items.fold(0, (sum, item) => sum + item.qtyShip);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 12.h),
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
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
                          'Detail Muatan Surat Jalan',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'No. SJ: ${widget.delivHdr.delivId}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20.w, color: Colors.grey.shade600),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 40.w, color: Colors.red.shade400),
                                SizedBox(height: 10.h),
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                      fontSize: 12.sp, color: Colors.red.shade700),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12.h),
                                ElevatedButton.icon(
                                  onPressed: _loadDetail,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _items.isEmpty
                          ? Center(
                              child: Text(
                                'Tidak ada item yang ditemukan.',
                                style: TextStyle(
                                    fontSize: 12.sp, color: Colors.grey.shade600),
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.all(16.w),
                              itemCount: _items.length,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 14.h, color: Colors.grey.shade100),
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(6.w),
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
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.namaBarang.isNotEmpty
                                                ? item.namaBarang
                                                : '-',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 3.h),
                                          Row(
                                            children: [
                                              Text(
                                                'Qty: ${item.qtyShip} pcs',
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.green.shade800,
                                                ),
                                              ),
                                              if (item.panjang.isNotEmpty &&
                                                  item.panjang != '0') ...[
                                                SizedBox(width: 8.w),
                                                Text(
                                                  '•  Panjang: ${item.panjang} m',
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
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
            ),
            if (!_isLoading && _items.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Muatan (${_items.length} item)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '$_totalQty pcs',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

