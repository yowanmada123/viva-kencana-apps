import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../bloc/sales_activity/history_visit/history_visit_detail/sales_activity_history_visit_detail_bloc.dart';
import '../../models/sales_activity/history_visit.dart';

class SalesActivityHistoryDetailScreen extends StatefulWidget {
  final HistoryVisit visit;
  const SalesActivityHistoryDetailScreen({
    super.key,
    required this.visit,
  });

  @override
  State<SalesActivityHistoryDetailScreen> createState() =>
      _SalesActivityHistoryDetailScreenState();
}

class _SalesActivityHistoryDetailScreenState extends State<SalesActivityHistoryDetailScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    context.read<SalesActivityHistoryVisitDetailBloc>().add(
          LoadHistoryDetail(widget.visit.trId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail - ${widget.visit.trId}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.w,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<SalesActivityHistoryVisitDetailBloc, SalesActivityHistoryVisitDetailState>(
          builder: (context, state) {
            if (state is HistoryDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HistoryDetailFailure) {
              return Center(
                child: Text(
                  "Gagal memuat detail: ${state.exception}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is HistoryDetailLoaded) {
              final details = state.details;
              if (details.isEmpty) {
                return const Center(child: Text("Tidak ada riwayat detail"));
              }

              return ListView.builder(
                itemCount: details.length,
                itemBuilder: (context, index) {
                  final d = details[index];
                  final latitude = double.tryParse(d.latitude) ?? 0.0;
                  final longitude = double.tryParse(d.longitude) ?? 0.0;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _mapController.move(
                        LatLng(
                          latitude,
                          longitude,
                        ),
                        17.0,
                      );
                    }
                  });
                  return buildHistoryCard(
                    entityId: d.entityId,
                    customerName: d.customerName,
                    customerCity: d.customerCity,
                    salesVehicle: d.salesVehicle,
                    gpsAddress: d.gpsAddress,
                    isCheckin: d.startEndPoint == 'OS',
                    latitude: latitude,
                    longitude: longitude,
                    trDate: d.trDate,
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Card buildHistoryCard({
    required String entityId,
    required String customerName,
    required String customerCity,
    required String salesVehicle,
    required String gpsAddress,
    required bool isCheckin,
    required double latitude,
    required double longitude,
    required String trDate,
  }) {
    final Color mainColor = isCheckin
        ? Colors.green.shade400.withOpacity(0.8)
        : Colors.red.shade400.withOpacity(0.8);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 260.w,
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                bottomLeft: Radius.circular(12.r),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$entityId - $customerName - $customerCity",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(trDate)),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: 150.w,
                  width: 280.w,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(latitude, longitude),
                      initialZoom: 12,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName:
                            'com.example.vivakencanaapp',
                      ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                latitude,
                                longitude,
                              ),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Vehicle: $salesVehicle",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  gpsAddress,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}