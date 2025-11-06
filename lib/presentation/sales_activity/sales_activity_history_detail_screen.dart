import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../bloc/sales_activity/history_visit/history_visit_detail/sales_activity_history_visit_detail_bloc.dart';
import '../../bloc/sales_activity/history_visit/history_visit_detail/upload_image/sales_activity_history_visit_upload_image_bloc.dart';
import '../../models/sales_activity/history_detail.dart';
import '../../models/sales_activity/history_visit.dart';
import '../widgets/base_primary_button.dart';
import 'sales_activity_history_detail_images_screen.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<SalesActivityHistoryVisitDetailBloc>().add(LoadHistoryDetail(widget.visit.trId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail History Visit',
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
        padding: EdgeInsets.all(16.w),
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.w, left: 4.w),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.visit.trDate)),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withValues(alpha: 0.7)
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: details.length,
                      itemBuilder: (context, index) {
                        final d = details[index];
                        final Color mainColor = d.startEndPoint == 'OS'
                          ? Colors.green.shade400
                          : Colors.red.shade400;
                        final latitude = double.tryParse(d.latitude) ?? -7.250445;
                        final longitude = double.tryParse(d.longitude) ?? 112.768845;
                        final MapController mapController = MapController();
                        Map<String, dynamic> activities = {
                          "product_offer": d.productOffer,
                          "take_order": d.takeOrder,
                          "promo_info": d.promoInfo,
                          "penagihan": d.penagihan,
                          "customer_visit": d.customerVisit,
                          "customer_new": d.customerNew
                        };
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            mapController.move(
                              LatLng(
                                latitude,
                                longitude,
                              ),
                              17.0,
                            );
                          }
                        });
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 4,
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: mainColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.r),
                                      bottomLeft: Radius.circular(12.r),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 216.w,
                                              child: Text(
                                                d.trId,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.sp,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_vert),
                                              onSelected: (value) {
                                                switch (value) {
                                                  case 'show':
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => SalesActivityHistoryDetailImagesScreen(
                                                          historyDetail: d,
                                                        ),
                                                      ),
                                                    );
                                                    break;
                                                  case 'add_image':
                                                    _showAddImageDialog(context, d.seqId, d);
                                                    break;
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'add_image',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.camera_alt, size: 20),
                                                      SizedBox(width: 8),
                                                      Text("Add Image"),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'show',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.add_a_photo, size: 20),
                                                      SizedBox(width: 8),
                                                      Text("Show Images"),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(
                                          DateFormat('hh:mm a').format(DateTime.parse(d.trDate)),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.sp,
                                            color: Theme.of(context).primaryColor
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        SizedBox(height: 8.w),
                                        Text(
                                          "${d.customerName} - ${d.customerCity}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        Text(
                                          d.gpsAddress == "" ? '-' : d.gpsAddress,
                                          style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4.w),
                                        Text(
                                          "Cust. ID: ${d.customerId == "" ? "-" : d.customerId}",
                                          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                        ),
                                        SizedBox(height: 4.w),
                                        Text(
                                          "Cust. Phone: ${d.customerPhone == "" ? "-" : d.customerPhone}",
                                          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                        ),
                                        SizedBox(height: 4.w),
                                        Text(
                                          "Cust. KTP/NPWP: ${d.customerKtpNpwp == "" ? "-" : d.customerKtpNpwp}",
                                          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4.w),
                                        Text(
                                          "Sales ID: ${d.salesId} - ${d.entityId}",
                                          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                        ),
                                        SizedBox(height: 4.w),
                                        Text(
                                          "Vehicle: ${d.salesVehicle}",
                                          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                        ),
                                        SizedBox(height: 4.w),
                                        buildActivities(activities),
                                        SizedBox(height: 4.w),
                                        Text(
                                          "Remark: ${d.remark == "" ? "-" : d.remark}",
                                          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                        ),
                                        SizedBox(height: 12.w),
                                        SizedBox(
                                          height: 150.w,
                                          width: 300.w,
                                          child: FlutterMap(
                                            mapController: mapController,
                                            options: MapOptions(
                                              initialCenter: LatLng(-7.250445, 112.768845),
                                              initialZoom: 10,
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
                                        SizedBox(height: 12.w),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget buildActivities(Map<String, dynamic> data) {
    final activityLabels = {
      "product_offer": "Penawaran Produk",
      "take_order": "Taking Order",
      "promo_info": "Info Program/Hadiah",
      "penagihan": "Penagihan",
      "customer_visit": "Customer Visit/Asistensi",
      "customer_new": "Registrasi Customer Baru",
    };

    final activeActivities = activityLabels.entries
        .where((entry) => data[entry.key] == "Y")
        .map((entry) => entry.value)
        .toList();

    return Text(
      activeActivities.isEmpty
          ? "Activity: -"
          : "Activity: ${activeActivities.join(', ')}",
      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
    );
  }

  void _showAddImageDialog(BuildContext context, String seqId, HistoryDetail detail) {
    File? imageFile;
    final remarkController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Image"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              titlePadding: EdgeInsets.only(top: 20.w),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
              actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (imageFile != null)
                      Column(
                        children: [
                          Image.file(imageFile!, height: 180),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: remarkController,
                            decoration: const InputDecoration(
                              labelText: "Remark",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      )
                    else
                      BasePrimaryButton(
                        label: "Ambil Gambar", 
                        icon: Icons.camera_alt,
                        onPressed: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 75,
                          );
                          if (picked != null) {
                            setState(() {
                              imageFile = File(picked.path);
                            });
                          }
                        },
                      )
                  ],
                ),
              ),
              actions: [
                BlocConsumer<SalesActivityHistoryVisitUploadImageBloc, SalesActivityHistoryVisitUploadImageState>(
                  listener: (context, state) {
                    if (state is UploadImageSuccess) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gambar berhasil diupload'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (state is UploadImageError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text("Batal", style: TextStyle(color: Colors.redAccent)),
                        ),
                        BasePrimaryButton(
                          label: "Submit",
                          onPressed: imageFile == null
                            ? null
                            : () {
                                context.read<SalesActivityHistoryVisitUploadImageBloc>().add(
                                      SubmitUploadImage(
                                        entityId: detail.entityId,
                                        trId: detail.trId,
                                        seqId: seqId,
                                        imageFile: imageFile!,
                                        remark: remarkController.text,
                                      ),
                                    );
                              }
                        ),
                      ],
                    );
                  }
                )
              ],
            );
          },
        );
      },
    );
  }
}