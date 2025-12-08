import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/sales_activity/sales_activity_form_bloc.dart';
import '../../models/sales_activity/customer_info.dart';
import '../../models/sales_activity/submit_data.dart' as model;
import '../widgets/base_danger_button.dart';
import '../widgets/base_dropdown_search.dart';
import '../widgets/base_primary_button.dart';

class SalesActivityHistoryUpdateScreen extends StatefulWidget {
  final String entityId;
  final List<model.ImageItem> apiImages;

  const SalesActivityHistoryUpdateScreen({
    super.key,
    required this.entityId,
    this.apiImages = const [],
  });

  @override
  State<SalesActivityHistoryUpdateScreen> createState() => _SalesActivityHistoryUpdateScreenState();
}

class _SalesActivityHistoryUpdateScreenState extends State<SalesActivityHistoryUpdateScreen> {
  final _picker = ImagePicker();
  Timer? _debounce;

  List<CustomerInfo> customerList = [];
  CustomerInfo? selectedCustomerInfo;

  final custIdController = TextEditingController();
  final nameController = TextEditingController();
  final ktpController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final provinceController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final villageController = TextEditingController();

  List<model.ImageItem> newImages = [];

  String? imagePath;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _getImageFromCamera() async {
    final status = await Permission.camera.status;

    if (status.isGranted || await Permission.camera.request().isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        imagePath = pickedFile.path.toString();
        final imageFile = File(pickedFile.path);

        final inputImage = InputImage.fromFile(imageFile);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        textRecognizer.close();

        final String? odometerValue = _extractOdometerFromText(recognizedText.text);
      
        context.read<SalesActivityFormBloc>().add(
          AddImageEvent(model.ImageItem(file: imageFile.path)),
        );

        if (odometerValue != null) {
          context.read<SalesActivityFormBloc>().add(SetOdometerEvent(odometerValue));
        }

        setState(() {
          newImages.add(model.ImageItem(file: imageFile.path));
        });
      }
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Akses kamera ditolak permanen. Buka pengaturan untuk mengaktifkan.',
          ),
          action: SnackBarAction(
            label: 'Buka',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akses kamera diperlukan untuk mengambil foto.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _extractOdometerFromText(String text) {
    final regex = RegExp(r'\b\d{4,6}\b');
    final match = regex.firstMatch(text);
    return match?.group(0);
  }

  Future<File?> compressImage(File file) async {
    final targetPath = "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
    );
    return result != null ? File(result.path) : null;
  }

  @override
  void initState() {
    log('Access to lib/presentation/sales_activity/sales_activity_history_update_screen.dart');
    super.initState();
     }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Visit',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocListener<SalesActivityFormBloc, SalesActivityFormState>(
              listenWhen: (previous, current) => current is CustomerDetailLoadSuccess,
              listener: (context, state) {
                if (state is CustomerDetailLoadSuccess) {
                  final detail = state.customerDetail;
                  setState(() {
                    custIdController.text = detail.customerId;
                    nameController.text = detail.namaCustomer;
                    ktpController.text = detail.npwp;
                    phoneController.text = detail.telepon;
                    emailController.text = detail.email;
                    addressController.text = detail.alamat;
                    provinceController.text = detail.propinsi;
                    cityController.text = detail.realCity;
                    districtController.text = detail.district;
                    villageController.text = detail.vilage;
                  });
                }
              },
              child: BlocListener<SalesActivityFormBloc, SalesActivityFormState>(
                listenWhen: (previous, current) => current is CustomerSearchSuccess,
                listener: (context, state) {
                  if (state is CustomerSearchSuccess) {
                    setState(() => customerList = state.customers);
                  }
                },
                child: BaseDropdownSearch<CustomerInfo>(
                  label: "Customer",
                  items: customerList,
                  getLabel: (customer) => customer.namaCustomer,
                  selectedValue: selectedCustomerInfo,
                  onChanged: (val) {
                    setState(() => selectedCustomerInfo = val);
                    if (val != null) {
                      context.read<SalesActivityFormBloc>().add(
                        FetchCustomerDetail(widget.entityId, val.customerId),
                      );
                    }
                  },
                  onSearchChanged: (query) {
                    if (_debounce?.isActive ?? false) _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      if (query.isNotEmpty) {
                        context.read<SalesActivityFormBloc>().add(
                          SearchCustomerData(widget.entityId, query),
                        );
                      }
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16.w),

          
            const Text("Images"),
            SizedBox(height: 8.w),
            SizedBox(
              height: 180.w,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.apiImages.length + newImages.length + 1,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final totalApi = widget.apiImages.length;
                
                  if (index == totalApi + newImages.length) {
                    return GestureDetector(
                      onTap: _getImageFromCamera,
                      child: Container(
                        width: 150.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const Center(
                          child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                
                  if (index < totalApi) {
                    final img = widget.apiImages[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.network(
                                img.file,
                                width: 150.w,
                                height: 140.w,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "API",
                                  style: TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.w),
                        SizedBox(
                          width: 150.w,
                          child: TextField(
                            readOnly: true,
                            controller: TextEditingController(text: img.remark),
                            decoration: InputDecoration(
                              hintText: "Photo Remark",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                
                  final img = newImages[index - totalApi];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.file(
                              File(img.file),
                              width: 150.w,
                              height: 140.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  newImages.removeAt(index - totalApi);
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black54,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 150.w,
                        child: TextField(
                          onChanged: (value) {
                            context.read<SalesActivityFormBloc>().add(
                              UpdateRemarkEvent(index - totalApi, value),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: "Photo Remark",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            SizedBox(height: 24.w),

            Row(
              children: [
                Expanded(
                  child: BaseDangerButton(
                    label: "Cancel",
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: BasePrimaryButton(
                    label: "Update",
                    onPressed: () {
                      // context.read<SalesActivityFormBloc>().add(
                      //   UpdateVisitEvent(
                      //     selectedCustomerInfo,
                      //     [...widget.apiImages, ...newImages],
                      //   ),
                      // );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
