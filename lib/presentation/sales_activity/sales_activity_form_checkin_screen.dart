import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart' as image;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/sales_activity/checkin/sales_activity_form_checkin_bloc.dart';
import '../../models/sales_activity/sales_info.dart';
import '../../models/sales_activity/submit_data.dart' as model;
import '../../utils/image_to_base_64_converter.dart';
import '../../utils/strict_location.dart';
import '../widgets/base_danger_button.dart';
import '../widgets/base_dropdown_button.dart';
import '../widgets/base_primary_button.dart';
import 'sales_activity_dashboard_screen.dart';

class SalesActivityFormCheckInScreen extends StatefulWidget {
  final SalesInfo sales;
  final bool isCheckIn;
  const SalesActivityFormCheckInScreen({
    Key? key,
    required this.sales,
    this.isCheckIn = false,
  }) : super(key: key);

  @override
  State<SalesActivityFormCheckInScreen> createState() =>
      _SalesActivityFormCheckInScreenState();
}

class _SalesActivityFormCheckInScreenState
    extends State<SalesActivityFormCheckInScreen> {
  final _picker = image.ImagePicker();
  final MapController _mapController = MapController();

  final _odometerController = TextEditingController();
  final remarkController = TextEditingController();

  String? selectedSalesVehicle;
  String imagePath = '';

  dynamic salesVehicle = {
    "Company Car": "Company Car",
    "Private Car": "Private Car",
    "Private Motorcycle": "Private Motorcycle",
    "Online Transport": "Online Transport",
  };

  String? _extractOdometerFromText(String text) {
    final regex = RegExp(r'\b\d{4,7}\b');
    final match = regex.firstMatch(text);
    return match?.group(0);
  }

  Future<void> _getImageFromCamera() async {
    final status = await Permission.camera.status;

    if (status.isGranted || await Permission.camera.request().isGranted) {
      final pickedFile = await _picker.pickImage(source: image.ImageSource.camera);
      if (pickedFile != null) {
        imagePath = pickedFile.path.toString();
        final imageFile = File(pickedFile.path.toString());
        final inputImage = InputImage.fromFile(imageFile);
        final textRecognizer = TextRecognizer(
          script: TextRecognitionScript.latin,
        );
        final RecognizedText recognizedText = await textRecognizer.processImage(
          inputImage,
        );
        final String? odometerValue = _extractOdometerFromText(
          recognizedText.text,
        );

        textRecognizer.close();
        context.read<SalesActivityFormCheckInBloc>().add(
          AddImageEvent(model.ImageItem(file: imageFile.path)),
        );

        if (odometerValue != null) {
          context.read<SalesActivityFormCheckInBloc>().add(
            SetOdometerEvent(odometerValue),
          );
        }
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

  Future<File?> compressImage(File file) async {
    final targetPath = "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
    );

    return result != null ? File(result.path) : null;
  }

  Future<List<model.ImageItem>> prepareImagesForSubmission(
    List<model.ImageItem> images,
  ) async {
    return await Future.wait(
      images.map((img) async {
        File originalFile = File(img.file);
        File? compressed = await compressImage(originalFile);
        final fileToEncode = compressed ?? originalFile;
        final url = await imageToDataUri(fileToEncode);
        return model.ImageItem(file: url, remark: img.remark);
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    StrictLocation.checkLocationRequirements();
    context.read<SalesActivityFormCheckInBloc>().add(LoadCurrentLocation());
    _odometerController.text = context.read<SalesActivityFormCheckInBloc>().state.odometer;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      SalesActivityFormCheckInBloc,
      SalesActivityFormCheckInState
    >(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isCheckIn ? 'Checkin Form' : 'Checkout Form',
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
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.w, horizontal: 16.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 200.w,
                      child: BlocBuilder<
                        SalesActivityFormCheckInBloc,
                        SalesActivityFormCheckInState
                      >(
                        builder: (context, state) {
                          if (state is CurrentLocationLoading) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            if (state.position != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  _mapController.move(
                                    LatLng(
                                      state.position!.latitude,
                                      state.position!.longitude,
                                    ),
                                    17.0,
                                  );
                                }
                              });
                            }
                            return FlutterMap(
                              mapController: _mapController,
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
                                if (state.position != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(
                                          state.position!.latitude,
                                          state.position!.longitude,
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
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(state.address!),
                    SizedBox(
                      width: double.infinity,
                      child: BasePrimaryButton(
                        onPressed: () async {
                          final position = await StrictLocation.getCurrentPosition();
                          if(position.isMocked){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Perangkat terdeteksi menggunakan lokasi palsu"), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          context.read<SalesActivityFormCheckInBloc>().add(
                            SetLocationEvent(),
                          );
                        },
                        label: "Get Location",
                        icon: Icons.location_on,
                      ),
                    ),
                    const Text("Image"),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180.w,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.images.length + 1,
                        separatorBuilder: (_, __) => SizedBox(width: 8.w),
                        itemBuilder: (context, index) {
                          if (index == state.images.length) {
                            return GestureDetector(
                              onTap: _getImageFromCamera,
                              child: Container(
                                width: 150.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8.w),
                                ),
                                child: Center(
                                  child: Icon(Icons.add_a_photo, size: 40.w, color: Colors.grey),
                                ),
                              ),
                            );
                          } else {
                            final img = state.images[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(img.file),
                                    width: 150.w,
                                    height: 140.w,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 4.w),
                                SizedBox(
                                  width: 150.w,
                                  child: TextField(
                                    onChanged: (value) {
                                      context.read<SalesActivityFormCheckInBloc>().add(
                                            UpdateRemarkEvent(index, value),
                                          );
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Photo Remark",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6.w),
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                                    ),
                                  ),
                                )
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    BlocListener<SalesActivityFormCheckInBloc, SalesActivityFormCheckInState>(
                      listenWhen: (previous, current) => previous.odometer != current.odometer,
                      listener: (context, state) {
                        _odometerController.text = state.odometer;
                      },
                      child: TextFormField(
                        controller: _odometerController,
                        decoration: const InputDecoration(labelText: 'Odometer'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    TextFormField(
                      controller: remarkController,
                      decoration: const InputDecoration(labelText: 'Remark'),
                      keyboardType: TextInputType.text,
                    ),
                    BaseDropdownButton(
                      label: "Sales Vehicle",
                      items: salesVehicle,
                      value: selectedSalesVehicle,
                      onChanged: (val) {
                        setState(() {
                          selectedSalesVehicle = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BlocBuilder<SalesActivityFormCheckInBloc, SalesActivityFormCheckInState>(
                          builder: (context, state) {
                            final isLoading = state is SalesActivityFormCheckInLoading;
                            return Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: BaseDangerButton(
                                  onPressed: isLoading ? null : () => Navigator.pop(context),
                                  label: 'Back',
                                ),
                              ),
                            );
                          },
                        ),
            
                        SizedBox(width: 16),
            
                        BlocConsumer<
                          SalesActivityFormCheckInBloc,
                          SalesActivityFormCheckInState
                        >(
                          listenWhen:
                              (previous, current) =>
                                  current is SalesActivityFormCheckInSuccess ||
                                  current is SalesActivityFormCheckInError,
                          listener: (context, state) {
                            if (state is SalesActivityFormCheckInSuccess) {
                              final bool isCheckIn = widget.isCheckIn;
                              final String message = isCheckIn
                                  ? "Berhasil melakukan checkin!"
                                  : "Berhasil melakukan checkout!";
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              context.read<SalesActivityFormCheckInBloc>().add(LoadSalesData());
            
                              Future.delayed(
                                const Duration(milliseconds: 200),
                                () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => SalesActivityDashboardScreen(sales: widget.sales),
                                    ),
                                  );
                                },
                              );
                            } else if (state is SalesActivityFormCheckInError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Checkout gagal: ${state.message}",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            final isLoading = state is SalesActivityFormCheckInLoading;
          
                            return Expanded(
                              child: BasePrimaryButton(
                                isLoading: isLoading,
                                label: widget.isCheckIn ? "Checkin" : "Checkout",
                                onPressed:
                                    isLoading
                                        ? null
                                        : () async {
                                          final blocState =
                                              context
                                                  .read<
                                                    SalesActivityFormCheckInBloc
                                                  >()
                                                  .state;
          
                                          if (blocState.address == '') {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Mohon pastikan alamat tersedia.",
                                                ),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                            return;
                                          }
                                          final List<model.ImageItem> modelImages = await prepareImagesForSubmission(blocState.images);
                                          final formData =
                                              model.SalesActivityFormData(
                                                checkboxCar:
                                                    selectedSalesVehicle,
                                                latitude:
                                                    blocState
                                                        .position!
                                                        .latitude,
                                                longitude:
                                                    blocState
                                                        .position!
                                                        .longitude,
                                                remark: remarkController.text,
                                                images: modelImages,
                                                speedoKmModel:
                                                    _odometerController.text,
                                                checkpoint:
                                                    widget.isCheckIn
                                                        ? "OS"
                                                        : "OE",
                                                salesid: widget.sales.salesId,
                                                officeid: widget.sales.officeId,
                                              );

                                          context.read<SalesActivityFormCheckInBloc>().add(SubmitSalesActivityCheckInForm(formData));
                                        },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
