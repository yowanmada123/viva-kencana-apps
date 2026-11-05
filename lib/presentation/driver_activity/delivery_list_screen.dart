import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vivakencanaapp/bloc/driver_activity/delivery_list/delivery_list_bloc.dart';
import 'package:vivakencanaapp/data/repository/driver_activity_repository.dart';
import 'package:vivakencanaapp/models/driver_activity/driver_delivery.dart';

class DeliveryListScreen extends StatelessWidget {
  final String? entityId;

  const DeliveryListScreen({super.key, this.entityId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliveryListBloc(
        driverActivityRepository: context.read<DriverActivityRepository>(),
      )..add(const GetDeliveryListEvent()),
      child: const _DeliveryListView(),
    );
  }
}

class _DeliveryListView extends StatefulWidget {
  const _DeliveryListView();

  @override
  State<_DeliveryListView> createState() => _DeliveryListViewState();
}

class _DeliveryListViewState extends State<_DeliveryListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Color _getStatusColor(DriverDelivery item) {
    if (item.isCompleted) return Colors.teal;
    if (item.hasDropped) return Colors.green;
    if (item.hasArrived) return Colors.indigo;
    if (item.hasLeft) return Colors.orange;
    return Colors.blue;
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
          'Delivery List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Muat Ulang',
            onPressed: () {
              context
                  .read<DeliveryListBloc>()
                  .add(const RefreshDeliveryListEvent());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Summary Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      context
                          .read<DeliveryListBloc>()
                          .add(FilterDeliveryListEvent(value));
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari No. Surat Jalan / Nopol / Tujuan...',
                      hintStyle: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: primaryColor,
                        size: 20.w,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                size: 18.w,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                context
                                    .read<DeliveryListBloc>()
                                    .add(const FilterDeliveryListEvent(''));
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content List
          Expanded(
            child: BlocBuilder<DeliveryListBloc, DeliveryListState>(
              builder: (context, state) {
                if (state is DeliveryListLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is DeliveryListFailure) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 54.w,
                            color: Colors.red.shade400,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                            onPressed: () {
                              context
                                  .read<DeliveryListBloc>()
                                  .add(const GetDeliveryListEvent());
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is DeliveryListSuccess) {
                  final list = state.filteredDeliveries;

                  if (list.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.all(32.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                size: 64.w,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                state.searchQuery.isNotEmpty
                                    ? 'Tidak ada hasil untuk "${state.searchQuery}"'
                                    : 'Tidak ada surat jalan yang perlu dikirim',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'Tarik ke bawah untuk memuat ulang data.',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: primaryColor,
                    onRefresh: () async {
                      context
                          .read<DeliveryListBloc>()
                          .add(const RefreshDeliveryListEvent());
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return _buildDeliveryCard(item, primaryColor);
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
    );
  }

  Widget _buildDeliveryCard(DriverDelivery item, Color primaryColor) {
    final statusColor = _getStatusColor(item);

    return InkWell(
      onTap: () => _showDetailBottomSheet(item),
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Surat Jalan & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 16.w,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          item.trId,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    item.statusText,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            Divider(height: 18.h, color: Colors.grey.shade200),

            // Vehicle & Mill Info
            Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 15.w,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 6.w),
                Text(
                  item.vehicleId.isNotEmpty ? item.vehicleId : '-',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 14.w),
                Icon(
                  Icons.business_outlined,
                  size: 15.w,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    item.millName.isNotEmpty ? item.millName : item.entity,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Destination
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 15.w,
                  color: Colors.red.shade400,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    item.destination.isNotEmpty
                        ? item.destination
                        : 'Tujuan belum ditentukan',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Date & Driver
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13.w,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _formatDate(item.trDate),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14.w,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      item.name.isNotEmpty ? item.name : item.driverId,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailBottomSheet(DriverDelivery item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detail Pengiriman',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.shade200),
                  _buildDetailRow('No. Surat Jalan', item.trId),
                  _buildDetailRow('No. Kendaraan', item.vehicleId),
                  _buildDetailRow('Nama Driver', item.name),
                  _buildDetailRow('ID Driver', item.idEmployee),
                  _buildDetailRow('Entity / Pabrik', '${item.entity} - ${item.millName}'),
                  _buildDetailRow('Tujuan', item.destination),
                  _buildDetailRow('Tanggal Surat Jalan', _formatDate(item.trDate)),
                  Divider(color: Colors.grey.shade200),
                  Text(
                    'Riwayat Status Waktu',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildDetailRow('Waktu Berangkat (Leave)', _formatDate(item.dtLeave)),
                  _buildDetailRow('Waktu Tiba (Arrive)', _formatDate(item.dtArrive)),
                  _buildDetailRow('Waktu Bongkar (Drop)', _formatDate(item.dtDrop)),
                  _buildDetailRow('Waktu Kembali (Home)', _formatDate(item.dtHome)),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

