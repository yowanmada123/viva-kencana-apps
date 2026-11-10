import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vivakencanaapp/bloc/driver_activity/delivery_list/delivery_list_bloc.dart';
import 'package:vivakencanaapp/data/repository/driver_activity_repository.dart';
import 'package:vivakencanaapp/models/driver_activity/driver_delivery.dart';
import 'package:vivakencanaapp/presentation/driver_activity/bongkar_muat_screen.dart';
import 'package:vivakencanaapp/utils/strict_location.dart';

class DeliveryListScreen extends StatelessWidget {
  final String? entityId;

  const DeliveryListScreen({super.key, this.entityId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => DeliveryListBloc(
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
  bool _isActionLoading = false;
  String? _selectedBatchTrId;

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

  Future<void> _executeCheckOut(DriverDelivery batch) async {
    setState(() {
      _isActionLoading = true;
    });

    final repo = context.read<DriverActivityRepository>();
    final result = await repo.goCheckOut(id: batch.trId, entity: batch.entity);

    if (!mounted) return;

    setState(() {
      _isActionLoading = false;
    });

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Gagal memproses keberangkatan'),
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
        context.read<DeliveryListBloc>().add(const RefreshDeliveryListEvent());
      },
    );
  }

  Future<void> _executeCheckIn(DriverDelivery batch) async {
    setState(() {
      _isActionLoading = true;
    });

    final repo = context.read<DriverActivityRepository>();
    final result = await repo.goCheckIn(id: batch.trId, entity: batch.entity);

    if (!mounted) return;

    setState(() {
      _isActionLoading = false;
    });

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message ?? 'Gagal memproses kepulangan'),
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
        context.read<DeliveryListBloc>().add(const RefreshDeliveryListEvent());
      },
    );
  }

  void _confirmAction({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                onConfirm();
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(String rawDate) {
    if (rawDate.isEmpty ||
        rawDate.startsWith('1900-01-01') ||
        rawDate == 'null') {
      return '-';
    }
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('HH:mm', 'id_ID').format(parsed);
    } catch (_) {
      try {
        final parts = rawDate.split(' ');
        if (parts.length > 1) {
          final timeParts = parts[1].split(':');
          if (timeParts.length >= 2) {
            return '${timeParts[0]}:${timeParts[1]}';
          }
        }
      } catch (_) {}
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

  void _confirmCheckPoint(DelivHdrItem delivHdr, String entity) {
    _confirmAction(
      title: 'Sampai di Tujuan',
      message:
          'Catat waktu dan titik koordinat GPS saat tiba di tujuan untuk Surat Jalan No. ${delivHdr.delivId}?',
      confirmText: 'Ya, Sampai',
      confirmColor: Colors.blue.shade700,
      onConfirm: () => _executeCheckPoint(delivHdr, entity),
    );
  }

  Future<void> _executeCheckPoint(DelivHdrItem delivHdr, String entity) async {
    _showLoadingDialog('Mencatat koordinat GPS & titik kedatangan...');
    try {
      final position = await StrictLocation.getCurrentPosition();
      if (!mounted) return;

      final repo = context.read<DriverActivityRepository>();
      final result = await repo.checkPointOrder(
        id: delivHdr.delivId,
        entity: entity,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading

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
          context.read<DeliveryListBloc>().add(const RefreshDeliveryListEvent());
        },
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openBongkarMuatScreen(
    DelivHdrItem delivHdr,
    String entity,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BongkarMuatScreen(
          delivHdr: delivHdr,
          entity: entity,
        ),
      ),
    );

    if (result == true && mounted) {
      context.read<DeliveryListBloc>().add(const RefreshDeliveryListEvent());
    }
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
              context.read<DeliveryListBloc>().add(
                const RefreshDeliveryListEvent(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DeliveryListBloc, DeliveryListState>(
        builder: (context, state) {
          if (state is DeliveryListLoading) {
            return const Center(child: CircularProgressIndicator());
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
                        context.read<DeliveryListBloc>().add(
                          const GetDeliveryListEvent(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DeliveryListSuccess) {
            final allBatches = state.allDeliveries;

            if (allBatches.isEmpty) {
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
                          'Tidak ada surat jalan yang perlu dikirim',
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

            // Deduplikasi daftar batch agar aman dari duplikasi data backend
            final List<DriverDelivery> uniqueBatches = [];
            final Set<String> seenKeys = {};
            for (final b in allBatches) {
              final key = '${b.entity.trim()}_${b.trId.trim()}';
              if (b.trId.trim().isNotEmpty && !seenKeys.contains(key)) {
                seenKeys.add(key);
                uniqueBatches.add(b);
              }
            }
            final batches =
                uniqueBatches.isNotEmpty ? uniqueBatches : allBatches;

            // Tentukan batch yang sedang dipilih
            DriverDelivery? selectedBatch;
            if (_selectedBatchTrId != null) {
              for (final b in batches) {
                if (b.trId == _selectedBatchTrId) {
                  selectedBatch = b;
                  break;
                }
              }
            }
            if (selectedBatch == null && batches.isNotEmpty) {
              selectedBatch = batches.first;
              _selectedBatchTrId = selectedBatch.trId;
            }

            final List<DelivHdrItem> displayedSjList =
                selectedBatch?.delivHdrItems ?? [];

            return RefreshIndicator(
              color: primaryColor,
              onRefresh: () async {
                context.read<DeliveryListBloc>().add(
                  const RefreshDeliveryListEvent(),
                );
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                itemCount:
                    2 +
                    (displayedSjList.isEmpty
                        ? 1
                        : displayedSjList.length),
                itemBuilder: (context, index) {
                  // Index 0: Kartu Aksi Batch Paling Atas (Selector Batch, Info, Waktu & Tombol Aksi)
                  if (index == 0) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildTopActionCard(
                        context,
                        batches,
                        primaryColor,
                        selectedBatch!,
                      ),
                    );
                  }

                  // Index 1: Header Daftar Surat Jalan
                  if (index == 1) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _buildSjSectionHeader(
                        selectedBatch!,
                        displayedSjList.length,
                        primaryColor,
                      ),
                    );
                  }

                  // Index 2+: Item Surat Jalan untuk Batch yang Dipilih
                  if (displayedSjList.isEmpty) {
                    return _buildEmptySjCard(
                      selectedBatch?.trId ?? '',
                    );
                  }

                  final sjIndex = index - 2;
                  final delivHdr = displayedSjList[sjIndex];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _buildDelivHdrCard(
                      delivHdr: delivHdr,
                      entity: selectedBatch!.entity,
                      primaryColor: primaryColor,
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTopActionCard(
    BuildContext context,
    List<DriverDelivery> batches,
    Color primaryColor,
    DriverDelivery selected,
  ) {
    final statusColor = _getStatusColor(selected);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector Batch (Opsi Batch)
          batches.length > 1
              ? InkWell(
                onTap:
                    () => _showBatchSelectorBottomSheet(
                      context,
                      batches,
                      selected,
                      primaryColor,
                    ),
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping,
                        size: 16.w,
                        color: primaryColor,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'Batch: ${selected.trId} (${selected.entity})',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 22.w,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
              )
              : Row(
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
                    child: Text(
                      'Batch: ${selected.trId} (${selected.entity})',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

          SizedBox(height: 6.h),

          // Status Badge di bawah No Batch
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                selected.statusText,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // Detail info chip (Nopol, Pabrik, Tujuan)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade200, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 13.w,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Nopol: ${selected.vehicleId.isNotEmpty ? selected.vehicleId : "-"}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Icon(
                      Icons.business_outlined,
                      size: 13.w,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        'Pabrik: ${selected.millName.isNotEmpty ? selected.millName : selected.entity}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          // Status Times (Waktu Berangkat & Waktu Pulang)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color:
                        selected.hasLeft
                            ? Colors.orange.shade50
                            : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color:
                          selected.hasLeft
                              ? Colors.orange.shade300
                              : Colors.grey.shade300,
                      width: 0.6,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktu Berangkat',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _formatDate(selected.dtLeave),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              selected.hasLeft
                                  ? Colors.orange.shade900
                                  : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color:
                        selected.isCompleted
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color:
                          selected.isCompleted
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                      width: 0.6,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktu Pulang',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _formatDate(selected.dtHome),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              selected.isCompleted
                                  ? Colors.green.shade900
                                  : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Two Primary Action Buttons: Berangkat & Pulang
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  icon:
                      _isActionLoading
                          ? SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Icon(Icons.departure_board_rounded, size: 16.w),
                  label: Text(
                    'Berangkat',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed:
                      _isActionLoading
                          ? null
                          : () => _confirmAction(
                            title: 'Konfirmasi Berangkat',
                            message:
                                'Apakah Anda yakin ingin memulai perjalanan (Check Out) untuk Batch ${selected.trId} (${selected.entity})?',
                            confirmText: 'Ya, Berangkat',
                            confirmColor: Colors.orange.shade700,
                            onConfirm: () => _executeCheckOut(selected),
                          ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  icon:
                      _isActionLoading
                          ? SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Icon(Icons.home_rounded, size: 16.w),
                  label: Text(
                    'Pulang',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed:
                      _isActionLoading
                          ? null
                          : () => _confirmAction(
                            title: 'Konfirmasi Pulang',
                            message:
                                'Apakah Anda yakin telah selesai dan kembali (Check In) untuk Batch ${selected.trId} (${selected.entity})?',
                            confirmText: 'Ya, Pulang',
                            confirmColor: Colors.teal.shade700,
                            onConfirm: () => _executeCheckIn(selected),
                          ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBatchSelectorBottomSheet(
    BuildContext context,
    List<DriverDelivery> batches,
    DriverDelivery selected,
    Color primaryColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.layers_outlined,
                      size: 18.w,
                      color: primaryColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Pilih Batch Pengiriman',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: batches.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, idx) {
                      final b = batches[idx];
                      final isSelected = b.trId == selected.trId;
                      final stColor = _getStatusColor(b);

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedBatchTrId = b.trId;
                          });
                          Navigator.pop(sheetContext);
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? primaryColor.withValues(alpha: 0.06)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? primaryColor
                                      : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 18.w,
                                color:
                                    isSelected
                                        ? primaryColor
                                        : Colors.grey.shade400,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Batch: ${b.trId}',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.w,
                                            vertical: 2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: stColor.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          child: Text(
                                            b.statusText,
                                            style: TextStyle(
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.w600,
                                              color: stColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '${b.entity} - ${b.millName.isNotEmpty ? b.millName : "-"} • Nopol: ${b.vehicleId.isNotEmpty ? b.vehicleId : "-"}',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '${b.delivHdrItems.length} Surat Jalan',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
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
                    },
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSjSectionHeader(
    DriverDelivery selected,
    int count,
    Color primaryColor,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 16.w, color: primaryColor),
              SizedBox(width: 6.w),
              Text(
                'Daftar Surat Jalan',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$count SJ',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => _showBatchDetailBottomSheet(selected),
            borderRadius: BorderRadius.circular(6.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14.w,
                    color: Colors.blue.shade700,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Detail Batch',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
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

  Widget _buildEmptySjCard(String trId) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 44.w,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 10.h),
            Text(
              trId.isNotEmpty
                  ? 'Belum ada surat jalan pada muatan batch $trId.'
                  : 'Belum ada surat jalan pada muatan batch ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDelivHdrCard({
    required DelivHdrItem delivHdr,
    required String entity,
    required Color primaryColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200, width: 1),
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
          // Row 1: Deliv ID (Surat Jalan) & Order ID & Tombol Detail
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
                  size: 15.w,
                  color: primaryColor,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No. SJ: ${delivHdr.delivId.isNotEmpty ? delivHdr.delivId : "-"}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (delivHdr.orderId.isNotEmpty)
                      Text(
                        'Order: ${delivHdr.orderId}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              // Tombol Detail Muatan (Memanggil getDetailItem)
              InkWell(
                onTap: () => _showMuatanDetailModal(context, entity, delivHdr),
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 13.w,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Detail',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Divider(height: 16.h, color: Colors.grey.shade100),

          // Receiver & Shipto
          if (delivHdr.receiver.isNotEmpty || delivHdr.shipto.isNotEmpty) ...[
            if (delivHdr.receiver.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 14.w,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      delivHdr.receiver,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            if (delivHdr.shipto.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14.w,
                    color: Colors.red.shade400,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      delivHdr.shipto,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],

          SizedBox(height: 6.h),

          // Date
          Row(
            children: [
              Icon(Icons.access_time, size: 12.w, color: Colors.grey.shade500),
              SizedBox(width: 4.w),
              Text(
                'Tgl Kirim: ${_formatDate(delivHdr.shipDate)}',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
              ),
            ],
          ),

          Divider(height: 16.h, color: Colors.grey.shade100),

          // Action Buttons: Sampai Tujuan & Bongkar Muat
          Row(
            children: [
              // Tombol / Status Sampai Tujuan (checkPointOrder)
              Expanded(
                child: delivHdr.hasArrived
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 7.h,
                          horizontal: 8.w,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14.w,
                              color: Colors.green.shade700,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                'Tiba: ${_formatTime(delivHdr.dtArrive)}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _confirmCheckPoint(delivHdr, entity),
                        icon: Icon(
                          Icons.location_on,
                          size: 13.w,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Sampai Tujuan',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: 7.h,
                            horizontal: 6.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
              ),
              SizedBox(width: 8.w),
              // Tombol / Status Bongkar Muat (dropOrder)
              Expanded(
                child: delivHdr.hasDropped
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 7.h,
                          horizontal: 8.w,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.teal.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14.w,
                              color: Colors.teal.shade700,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                'Bongkar: ${_formatTime(delivHdr.dtDrop)}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _openBongkarMuatScreen(delivHdr, entity),
                        icon: Icon(
                          Icons.inventory_2,
                          size: 13.w,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Bongkar Muat',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade800,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: 7.h,
                            horizontal: 6.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
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

  void _showBatchDetailBottomSheet(DriverDelivery item) {
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
                        'Detail Informasi Batch',
                        style: TextStyle(
                          fontSize: 15.sp,
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
                  _buildDetailRow('No. Batch', item.trId),
                  _buildDetailRow('No. Kendaraan', item.vehicleId),
                  _buildDetailRow('Nama Driver', item.name),
                  _buildDetailRow(
                    'ID Driver',
                    item.idEmployee.isNotEmpty
                        ? item.idEmployee
                        : item.driverId,
                  ),
                  _buildDetailRow(
                    'Entity / Pabrik',
                    '${item.entity} - ${item.millName}',
                  ),
                  _buildDetailRow(
                    'Jumlah Muatan (SJ)',
                    '${item.delivHdrItems.length} Surat Jalan',
                  ),
                  _buildDetailRow('Tujuan Pengiriman', item.destination),
                  _buildDetailRow(
                    'Tanggal Transaksi',
                    _formatDate(item.trDate),
                  ),
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
                  _buildDetailRow(
                    'Waktu Berangkat (Leave)',
                    _formatDate(item.dtLeave),
                  ),
                  _buildDetailRow(
                    'Waktu Tiba (Arrive)',
                    _formatDate(item.dtArrive),
                  ),
                  _buildDetailRow(
                    'Waktu Bongkar (Drop)',
                    _formatDate(item.dtDrop),
                  ),
                  _buildDetailRow(
                    'Waktu Kembali (Home)',
                    _formatDate(item.dtHome),
                  ),
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
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
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
          _errorMessage = failure.message ?? 'Gagal memuat detail item muatan';
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
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
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
            SizedBox(height: 12.h),

            // Header info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                widget.entity,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                'Detail Item Muatan',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'No. SJ: ${widget.delivHdr.delivId}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        if (widget.delivHdr.orderId.isNotEmpty)
                          Text(
                            'No. Order: ${widget.delivHdr.orderId}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        if (widget.delivHdr.receiver.isNotEmpty)
                          Text(
                            'Penerima: ${widget.delivHdr.receiver}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Divider(height: 16.h, color: Colors.grey.shade200),

            // Body
            Expanded(child: _buildBody(primaryColor)),

            // Bottom Summary Bar
            if (!_isLoading && _errorMessage == null && _items.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Item: ${_items.length} Macam',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Total Qty: $_totalQty',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 10.h,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Color primaryColor) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 12.h),
            Text(
              'Memuat item muatan...',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48.w,
                color: Colors.red.shade400,
              ),
              SizedBox(height: 10.h),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800),
              ),
              SizedBox(height: 14.h),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Coba Lagi'),
                onPressed: _loadDetail,
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 52.w,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 10.h),
              Text(
                'Tidak ada data item pada muatan surat jalan ini.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      itemCount: _items.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final item = _items[index];
        final hasPanjang =
            item.panjang.isNotEmpty &&
            item.panjang != '0' &&
            item.panjang != '0.00' &&
            item.panjang != '-';

        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Index badge
              Container(
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // Item Name & Spec
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaBarang.isNotEmpty
                          ? item.namaBarang
                          : 'Barang Jadi Tanpa Nama',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (hasPanjang) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.straighten,
                            size: 12.w,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Panjang: ${item.panjang} m',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              // Qty Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: Colors.green.shade200, width: 0.6),
                ),
                child: Text(
                  '${item.qtyShip} Qty',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
