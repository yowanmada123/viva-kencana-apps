import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vivakencanaapp/presentation/sales_activity/sales_activity_form_checkin_screen.dart';
import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/logout/logout_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../bloc/sales_activity/sales_activity_form_bloc.dart';
import '../../data/repository/auth_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/errors/custom_exception.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/base_pop_up.dart';

class SalesActivityFormScreen extends StatefulWidget {
  const SalesActivityFormScreen({super.key});

  @override
  State<SalesActivityFormScreen> createState() => _SalesActivityFormScreenState();
}

class _SalesActivityFormScreenState extends State<SalesActivityFormScreen> {
  String customerType = 'Existing Customer';
  String? selectedCustomer;
  String? selectedVehicle;
  String? selectedProvince;
  String? selectedCity;
  String? selectedDistrict;
  String? selectedVillage;
  int currentStep = 0;
  double progress = 1;
  final nameController = TextEditingController();
  final ktpController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final provinceController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final villageController = TextEditingController();

  final pageController = PageController(initialPage: 0);

  final dummyCustomers = [
    {
      'id': '1',
      'name': 'Budi Santoso',
      'ktp': '1234567890123456',
      'phone': '081234567890',
      'email': 'budi@email.com',
      'address': 'Jl. Merdeka No.1',
      'province': 'Jawa Timur',
      'city': 'Surabaya',
      'district': 'Bubutan',
      'village': 'Bubutan',
    },
    {
      'id': '2',
      'name': 'Sari Dewi',
      'ktp': '9876543210987654',
      'phone': '081987654321',
      'email': 'sari@email.com',
      'address': 'Jl. Asia Afrika No.2',
      'province': 'Jawa Tengah',
      'city': 'Semarang',
      'district': 'Tembalang',
      'village': 'Bulusan',
    },
  ];

  Map<String, String> customerData = {};

  void _onCustomerSelected(String? id) {
    final customer = dummyCustomers.firstWhere(
      (e) => e['id'] == id,
      orElse: () => {},
    );
    setState(() {
      selectedCustomer = id;
      customerData = Map<String, String>.from(customer);

      nameController.text = customer['name'] ?? '';
      ktpController.text = customer['ktp'] ?? '';
      phoneController.text = customer['phone'] ?? '';
      emailController.text = customer['email'] ?? '';
      addressController.text = customer['address'] ?? '';
      // provinceController.text = customer['province'] ?? '';
      // cityController.text = customer['city'] ?? '';
      // districtController.text = customer['district'] ?? '';
      // villageController.text = customer['village'] ?? '';
      selectedProvince = customer['province'];
      selectedCity = customer['city'];
      selectedDistrict = customer['district'];
      selectedVillage = customer['village'];

    });
  }

  void resetCustomerForm() {
    nameController.clear();
    ktpController.clear();
    phoneController.clear();
    emailController.clear();
    addressController.clear();
    selectedProvince = null;
    selectedCity = null;
    selectedDistrict = null;
    selectedVillage = null;
  }


  @override
  void dispose() {
    nameController.dispose();
    ktpController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    provinceController.dispose();
    cityController.dispose();
    districtController.dispose();
    villageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BasePopUpDialog(
          noText: "Kembali",
          yesText: "Lanjutkan",
          autoPopOnPressed: false,
          onNoPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const SalesActivityFormCheckInScreen(),
              ),
            );
          },
          onYesPressed: () {},
          question: "Ingin Sudahi Trip?",
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isExisting = customerType == 'Existing Customer';

    final authRepository = context.read<AuthRepository>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (pageController.page != 0) {
          pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
        }
      },
      child: SafeArea(
        maintainBottomViewPadding: true,
        top: false,
        child: BlocProvider(
          create: (context) => LogoutBloc(authRepository),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xff1E4694),
              iconTheme: const IconThemeData(color: Colors.white),
              // leading: IconButton(
              //   icon: Icon(Icons.menu, color: Color(0xffffffff)),
              //   onPressed: () => print("Menu"),
              // ),
              title: Text(
                'SALES ACTIVITY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18.w,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(5),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Color(0xffA4C8FF),
                        Colors.grey.shade300,
                        Colors.grey.shade300,
                      ],
                      stops: [0, progress / 2, progress / 2, 1],
                    ),
                  ),
                  child: const SizedBox(height: 5),
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  // child: Icon(Icons.logout, color: Colors.white),
                  child: BlocConsumer<LogoutBloc, LogoutState>(
                    listener: (context, state) {
                      if (state is LogoutSuccess) {
                        BlocProvider.of<AuthenticationBloc>(
                          context,
                        ).add(SetAuthenticationStatus(isAuthenticated: false));
                      } else if (state is LogoutFailure) {
                        if (state.exception is UnauthorizedException) {
                          context.read<AuthenticationBloc>().add(
                            SetAuthenticationStatus(isAuthenticated: false),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Unknown error, please contact admin",
                              ),
                            ),
                          );
                        }
                      }
                    },
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: () {
                          showDialog<bool>(
                            context: context,
                            builder: (BuildContext childContext) {
                              return BasePopUpDialog(
                                noText: "Tidak",
                                yesText: "Ya",
                                onNoPressed: () {},
                                onYesPressed: () {
                                  if (state is! LogoutLoading) {
                                    context.read<LogoutBloc>().add(
                                      LogoutPressed(),
                                    );
                                  }
                                },
                                question:
                                    "Apakah Anda yakin ingin keluar dari aplikasi?",
                              );
                            },
                          );
                        },
                        child: Icon(Icons.logout, color: Colors.white),
                      );
                    },
                  ),
                ),
              ],
            ),
            body: BlocConsumer<SalesActivityFormBloc, SalesActivityFormState>(
              listener: (context, state) {
                if (state is SalesActivityFormError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Telah terjadi kesalahan. Silakan coba lagi!",
                      ),
                      duration: Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Color.fromARGB(255, 243, 78, 78),
                    ),
                  );
                }
              },
              builder: (context, state) {
                return PageView(
                  controller: pageController,
                  onPageChanged:
                      (value) => setState(() => progress = value + 1),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.all(16.0),
                      child: BlocBuilder<
                        SalesActivityFormBloc,
                        SalesActivityFormState
                      >(
                        builder: (context, loanFormState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Customer Type
                              DropdownButtonFormField<String>(
                                value: customerType,
                                decoration: const InputDecoration(
                                  labelText: 'Customer Type',
                                ),
                                items:
                                    ['Existing Customer', 'New Customer']
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    customerType = value!;
                                    customerData.clear();
                                    selectedCustomer = null;

                                    if (customerType == 'New Customer') {
                                      resetCustomerForm();
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 6),

                              if (isExisting) ...[
                                DropdownButtonFormField<String>(
                                  value: selectedCustomer,
                                  decoration: const InputDecoration(
                                    labelText: 'Find Customer',
                                  ),
                                  items:
                                      dummyCustomers
                                          .map(
                                            (customer) => DropdownMenuItem(
                                              value: customer['id'],
                                              child: Text(customer['name']!),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: _onCustomerSelected,
                                ),
                              ],

                              buildTextField(
                                label: "Customer Name",
                                controller: nameController,
                                isReadOnly: isExisting,
                              ),
                              buildTextField(
                                label: "KTP/NPWP",
                                controller: ktpController,
                                isReadOnly: isExisting,
                              ),
                              buildTextField(
                                label: "Phone",
                                controller: phoneController,
                                isReadOnly: isExisting,
                              ),
                              buildTextField(
                                label: "Email",
                                controller: emailController,
                                isReadOnly: isExisting,
                              ),
                              buildTextField(
                                label: "Address",
                                controller: addressController,
                                isReadOnly: isExisting,
                              ),
                              buildDropdownField(
                                label: "Province",
                                items: ['Jawa Tengah', 'Jawa Timur'],
                                value: selectedProvince,
                                isDisabled: isExisting,
                                onChanged: (val) => setState(() => selectedProvince = val),
                              ),
                              buildDropdownField(
                                label: "City",
                                items: ['Semarang', 'Surabaya'],
                                value: selectedCity,
                                isDisabled: isExisting,
                                onChanged: (val) {
                                  setState(() {
                                    selectedCity = val;
                                  });
                                },
                              ),
                              buildDropdownField(
                                label: "District",
                                items: ['Tembalang', 'Bubutan'],
                                value: selectedDistrict,
                                isDisabled: isExisting,
                                onChanged: (val) {
                                  setState(() {
                                    selectedDistrict = val;
                                  });
                                },
                              ),
                              buildDropdownField(
                                label: "Village",
                                items: ['Bulusan', 'Bubutan'],
                                value: selectedVillage,
                                isDisabled: isExisting,
                                onChanged: (val) {
                                  setState(() {
                                    selectedVillage = val;
                                  });
                                },
                              ),

                              if (!isExisting) ...[
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: "Kind of Business",
                                  ),
                                  items:
                                      ['Retail', 'Distributor', 'Wholesale']
                                          .map(
                                            (item) => DropdownMenuItem(
                                              value: item,
                                              child: Text(item),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (_) {},
                                ),

                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: "Business Status",
                                  ),
                                  items:
                                      ['Active', 'Inactive']
                                          .map(
                                            (item) => DropdownMenuItem(
                                              value: item,
                                              child: Text(item),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (_) {},
                                ),

                                // Business Type
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: "Business Type",
                                  ),
                                  items:
                                      ['Toko', 'Pabrik', 'Kantor']
                                          .map(
                                            (item) => DropdownMenuItem(
                                              value: item,
                                              child: Text(item),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (_) {},
                                ),

                                // Tax Type
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: "Tax Type",
                                  ),
                                  items:
                                      ['PKP', 'Non-PKP']
                                          .map(
                                            (item) => DropdownMenuItem(
                                              value: item,
                                              child: Text(item),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (_) {},
                                ),

                                // Office Type
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: "Office Type",
                                  ),
                                  items:
                                      ['Cabang', 'Pusat']
                                          .map(
                                            (item) => DropdownMenuItem(
                                              value: item,
                                              child: Text(item),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (_) {},
                                ),

                                // Ownership
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: "Ownership",
                                  ),
                                  items:
                                      ['Milik Sendiri', 'Sewa']
                                          .map(
                                            (item) => DropdownMenuItem(
                                              value: item,
                                              child: Text(item),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (_) {},
                                ),

                                // Customer Type
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: "Customer Type",
                                  ),
                                  items:
                                      ['Grosir', 'Eceran']
                                          .map(
                                            (item) => DropdownMenuItem(
                                              value: item,
                                              child: Text(item),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (_) {},
                                ),
                              ],

                              // Salesman Vehicle (Tetap ditampilkan)
                              DropdownButtonFormField<String>(
                                value: selectedVehicle,
                                decoration: const InputDecoration(
                                  labelText: 'Salesman Vehicle',
                                ),
                                items:
                                    ['Private car', 'Office car']
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedVehicle = value;
                                  });
                                },
                              ),

                              SizedBox(height: 12),

                              // Next Button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xff1C3FAA),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (!isExisting &&
                                          nameController.text.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Nama Customer wajib diisi",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        curve: Curves.linear,
                                      );
                                    },
                                    child: const Text("Next"),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    _SalesActivityFormSecondStep(
                      onBackFunction: () {
                        pageController.previousPage(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.linear,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isReadOnly,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      readOnly: isReadOnly,
      controller: controller,
    );
  }

  Widget buildDropdownField({
    required String label,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
    bool isDisabled = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items:
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      onChanged: isDisabled ? null : onChanged,
    );
  }
}

class _SalesActivityFormSecondStep extends StatefulWidget {
  final Function onBackFunction;
  const _SalesActivityFormSecondStep({required this.onBackFunction});

  @override
  State<_SalesActivityFormSecondStep> createState() =>
      _SalesActivityFormSecondStepState();
}

class _SalesActivityFormSecondStepState
    extends State<_SalesActivityFormSecondStep> {
  final _kasbonController = TextEditingController();
  String? selectedOfficePoint;
  String? selectedUserPoint;

  final ImagePicker _picker = ImagePicker();
  Future<void> _getImageFromCamera() async {
    final status = await Permission.camera.status;

    if (status.isGranted || await Permission.camera.request().isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        context.read<SalesActivityFormBloc>().add(AddImageEvent(imageFile));
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
  void dispose() {
    _kasbonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocBuilder<SalesActivityFormBloc, SalesActivityFormState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.w),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final activities = [
                      'Registrasi Customer Baru',
                      'Penawaran Produk',
                      'Taking Order',
                      'Info Program/Hadiah',
                      'Penagihan',
                      'Customer Visit/Assistensi',
                    ];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Activity",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children:
                              activities.map((activity) {
                                final isChecked = state.selectedActivities
                                    .contains(activity);

                                return CheckboxListTile(
                                  value: isChecked,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    activity,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  onChanged: (_) {
                                    context.read<SalesActivityFormBloc>().add(
                                      ToggleActivityEvent(activity),
                                    );
                                  },
                                );
                              }).toList(),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Images"),
                    SizedBox(height: 8.w),
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.images.length + 1,
                        separatorBuilder: (_, __) => SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index == state.images.length) {
                            return GestureDetector(
                              onTap: _getImageFromCamera,
                              child: Container(
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                ),
                              ),
                            );
                          } else {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                state.images[index],
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.w),
                child: ElevatedButton.icon(
                  onPressed: () => context.read<SalesActivityFormBloc>().add(SetLocationEvent()),
                  icon: const Icon(Icons.location_on),
                  label: const Text("Get Location"),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.w),
                child: Column(
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
              ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.w),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         children: const [
              //           Text(
              //             "Office",
              //             style: TextStyle(fontWeight: FontWeight.bold),
              //           ),
              //           SizedBox(width: 4),
              //           Text(
              //             "(Office location as default point)",
              //             style: TextStyle(
              //               color: Colors.red,
              //               fontSize: 12,
              //               fontStyle: FontStyle.italic,
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 8.w),
              //       RadioListTile<String>(
              //         value: 'start',
              //         groupValue: state.officeOption,
              //         title: const Text('Start Point From Office'),
              //         onChanged: (value) {
              //           context.read<SalesActivityFormBloc>().add(
              //             SetOfficeOption(value!),
              //           );
              //         },
              //       ),
              //       RadioListTile<String>(
              //         value: 'end',
              //         groupValue: state.officeOption,
              //         title: const Text('End Point in Office'),
              //         onChanged: (value) {
              //           context.read<SalesActivityFormBloc>().add(
              //             SetOfficeOption(value!),
              //           );
              //         },
              //       ),
              //     ],
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.w),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         children: const [
              //           Text(
              //             "User",
              //             style: TextStyle(fontWeight: FontWeight.bold),
              //           ),
              //           SizedBox(width: 4),
              //           Text(
              //             "(Custom location by user)",
              //             style: TextStyle(
              //               color: Colors.red,
              //               fontSize: 12,
              //               fontStyle: FontStyle.italic,
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 8.w),

              //       RadioListTile<String>(
              //         value: 'custom_start',
              //         groupValue: state.userOption,
              //         title: const Text('Start Point Custom'),
              //         onChanged: (value) {
              //           context.read<SalesActivityFormBloc>().add(
              //             SetUserOption(value!),
              //           );
              //         },
              //       ),
              //       RadioListTile<String>(
              //         value: 'custom_end',
              //         groupValue: state.userOption,
              //         title: const Text('End Point Custom'),
              //         onChanged: (value) {
              //           context.read<SalesActivityFormBloc>().add(
              //             SetUserOption(value!),
              //           );
              //         },
              //       ),
              //     ],
              //   ),
              // ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Color(0xffff0000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ), // Adjust radius here
                        ),
                        onPressed: () {
                          widget.onBackFunction();
                        },
                        child: Text("Back"),
                      ),
                    ),
                    SizedBox(width: 24.w),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Color(0xff1C3FAA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ), // Adjust radius here
                        ),
                        onPressed: () {
                          // context.read<SalesActivityFormBloc>().add(
                          //   SalesActivityFormSubmit(amount: _kasbonController.text),
                          // );
                        },
                        child: Text("Submit"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}