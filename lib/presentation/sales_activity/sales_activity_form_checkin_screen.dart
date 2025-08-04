import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vivakencanaapp/presentation/sales_activity/sales_activity_form_screen.dart';

import '../../bloc/sales_activity/checkin/sales_activity_form_checkin_bloc.dart';

class SalesActivityFormCheckInScreen extends StatefulWidget {
  const SalesActivityFormCheckInScreen({Key? key}) : super(key: key);

  @override
  State<SalesActivityFormCheckInScreen> createState() => _SalesActivityFormCheckInScreenState();
}

class _SalesActivityFormCheckInScreenState extends State<SalesActivityFormCheckInScreen> {
  final _picker = ImagePicker();
  final _odometerController = TextEditingController();

  Future<void> _getImageFromCamera() async {
    final status = await Permission.camera.status;

    if (status.isGranted || await Permission.camera.request().isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path.toString());
        context.read<SalesActivityFormCheckInBloc>().add(SetImageEvent(imageFile));
      }
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Akses kamera ditolak permanen. Buka pengaturan untuk mengaktifkan.'),
          action: SnackBarAction(label: 'Buka', onPressed: () => openAppSettings()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akses kamera diperlukan untuk mengambil foto.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesActivityFormCheckInBloc, SalesActivityFormCheckInState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.isCheckedIn
                  ? (state.isCheckedOut ? 'Trip Selesai' : 'Checkout Form')
                  : 'Checkin Form',
            ),
          ),
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
                        image: state.imageCheckIn != null
                            ? DecorationImage(image: FileImage(state.imageCheckIn!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: state.imageCheckIn == null
                          ? const Center(child: Icon(Icons.camera_alt, color: Colors.grey, size: 40))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _odometerController,
                    decoration: const InputDecoration(labelText: 'Odometer'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<SalesActivityFormCheckInBloc>().add(SetLocationEvent()),
                    icon: const Icon(Icons.location_on),
                    label: const Text("Get Location"),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(
                              -7.245953,
                              112.7371463,
                            ),
                            initialZoom: 17.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                              userAgentPackageName: 'com.example.vivakencanaapp',
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
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(state.address),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Back"),
                      ),
                      BlocListener<SalesActivityFormCheckInBloc, SalesActivityFormCheckInState>(
                        listenWhen: (previous, current) {
                          return previous.isCheckedIn != current.isCheckedIn ||
                                previous.isCheckedOut != current.isCheckedOut;
                        },
                        listener: (context, state) {
                          if (state.isCheckedIn && !state.isCheckedOut) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Check In berhasil!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Future.delayed(const Duration(milliseconds: 300), () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const SalesActivityFormScreen(),
                                ),
                              );
                            });
                          } else if (state.isCheckedOut) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Checkout berhasil!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                        child: ElevatedButton(
                          onPressed: () {
                            if (!state.isCheckedIn) {
                              context.read<SalesActivityFormCheckInBloc>().add(SetCheckInEvent());
                            } else if (!state.isCheckedOut) {
                              context.read<SalesActivityFormCheckInBloc>().add(SetCheckOutEvent());
                            }
                          },
                          child: Text(
                            !state.isCheckedIn
                                ? "Check In"
                                : (state.isCheckedOut ? "Selesai" : "Check Out"),
                          ),
                        ),
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