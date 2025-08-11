import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/sales_activity/checkin/sales_activity_form_checkin_bloc.dart';
import '../../models/sales_activity/submit_data.dart';
import '../../utils/strict_location.dart';
import '../widgets/base_danger_button.dart';
import '../widgets/base_dropdown_button.dart';
import '../widgets/base_primary_button.dart';
import 'sales_activity_form_screen.dart';

class SalesActivityFormCheckInScreen extends StatefulWidget {
  final String salesId;
  final String officeId;
  const SalesActivityFormCheckInScreen({
    Key? key,
    required this.salesId,
    required this.officeId,
  }) : super(key: key);

  @override
  State<SalesActivityFormCheckInScreen> createState() =>
      _SalesActivityFormCheckInScreenState();
}

class _SalesActivityFormCheckInScreenState
    extends State<SalesActivityFormCheckInScreen> {
  final _picker = ImagePicker();
  final _odometerController = TextEditingController();
  final MapController _mapController = MapController();

  String? selectedSalesmanVehicle;
  String imagePath = '';

  String? _extractOdometerFromText(String text) {
    final regex = RegExp(r'\b\d{4,7}\b');
    final match = regex.firstMatch(text);
    return match?.group(0);
  }

  Future<void> _getImageFromCamera() async {
    final status = await Permission.camera.status;

    if (status.isGranted || await Permission.camera.request().isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
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
          SetImageEvent(imageFile),
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

  @override
  void initState() {
    StrictLocation.checkLocationRequirements();
    context.read<SalesActivityFormCheckInBloc>().add(LoadCheckinStatus());
    context.read<SalesActivityFormCheckInBloc>().add(LoadCurrentLocation());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      SalesActivityFormCheckInBloc,
      SalesActivityFormCheckInState
    >(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text("Sales Form")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Image"),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _getImageFromCamera,
                    child: Container(
                      height: 350,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                        image:
                            state.imageCheckIn != null
                                ? DecorationImage(
                                  image: FileImage(state.imageCheckIn!),
                                  fit: BoxFit.cover,
                                )
                                : null,
                      ),
                      child:
                          state.imageCheckIn == null
                              ? const Center(
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _odometerController..text = state.odometer,
                    decoration: const InputDecoration(labelText: 'Odometer'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BlocBuilder<
                      SalesActivityFormCheckInBloc,
                      SalesActivityFormCheckInState
                    >(
                      builder: (context, state) {
                        if (state is CurrentLocationLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          if (state.position != null) {
                            _mapController.move(
                              LatLng(
                                state.position!.latitude,
                                state.position!.longitude,
                              ),
                              17.0,
                            );
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
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: BasePrimaryButton(
                      onPressed:
                          () => context.read<SalesActivityFormCheckInBloc>().add(
                            SetLocationEvent(),
                          ),
                      label: "Get Location",
                      icon: Icons.location_on,
                    ),
                  ),
                  BaseDropdownButton(
                    label: "Salesman Vehicle",
                    items: {
                      "Y": "Company Car",
                      "N": "Private Car",
                      "M": "Private Motorcycle",
                      "L": "Online Transport",
                    },
                    value: selectedSalesmanVehicle,
                    onChanged: (val) {
                      setState(() {
                        selectedSalesmanVehicle = val;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BaseDangerButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        label: 'Back',
                        // width: double.infinity,
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Berhasil!"),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => SalesActivityFormScreen(
                                          salesId: widget.salesId,
                                          officeId: widget.salesId,
                                        ),
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
                          if (state is CheckinLoading) {
                            return Center(child: CircularProgressIndicator());
                          } else if (state is CheckinLoaded) {
                            final isLoading = state is CheckinLoading;
                            final isCheckedIn = state.isCheckedIn;

                            return Expanded(
                              child: BasePrimaryButton(
                                isLoading: isLoading,
                                label: isCheckedIn ? "Checkout" : "Checkin",
                                onPressed:
                                    isLoading
                                        ? null
                                        : () {
                                          final blocState =
                                              context
                                                  .read<
                                                    SalesActivityFormCheckInBloc
                                                  >()
                                                  .state;

                                          if (blocState.address == '' ||
                                              _odometerController
                                                  .text
                                                  .isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Mohon isi odometer dan pastikan alamat tersedia.",
                                                ),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                            return;
                                          }
                                          if (selectedSalesmanVehicle == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Mohon pilih jenis transportasi anda.",
                                                ),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                            return;
                                          }

                                          final formData =
                                              SalesActivityFormData(
                                                checkboxCar:
                                                    selectedSalesmanVehicle,
                                                latitude:
                                                    blocState
                                                        .position!
                                                        .latitude,
                                                longitude:
                                                    blocState
                                                        .position!
                                                        .longitude,
                                                remark: "Tes Remark",
                                                image: imagePath,
                                                speedoKmModel:
                                                    _odometerController.text,
                                                checkpoint:
                                                    blocState.isCheckedIn
                                                        ? "OE"
                                                        : "OS",
                                                salesid: widget.salesId,
                                                officeid: widget.officeId,
                                              );

                                          context
                                              .read<
                                                SalesActivityFormCheckInBloc
                                              >()
                                              .add(
                                                SubmitSalesActivityCheckInForm(
                                                  formData,
                                                ),
                                              );
                                        },
                              ),
                            );
                          } else if (state is CheckinError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Terjadi kesalahan mohon coba lagi.",
                                ),
                              ),
                            );
                          }
                          return SizedBox();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
