import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/auth/logout/logout_bloc.dart';
import '../../bloc/sales_activity/sales_activity_form_bloc.dart';
import '../../data/repository/auth_repository.dart';
import '../../models/sales_activity/customer_info.dart';
import '../../models/sales_activity/sales_info.dart';
import '../../models/sales_activity/submit_data.dart' as model;
import '../../utils/image_to_base_64_converter.dart';
import '../../utils/strict_location.dart';
import '../widgets/base_danger_button.dart';
import '../widgets/base_dropdown_button.dart';
import '../widgets/base_dropdown_search.dart';
import '../widgets/base_primary_button.dart';
import 'sales_activity_dashboard_screen.dart';

class SalesActivityFormScreen extends StatefulWidget {
  final SalesInfo sales;
  const SalesActivityFormScreen({super.key, required this.sales});

  @override
  State<SalesActivityFormScreen> createState() =>
      _SalesActivityFormScreenState();
}

class _SalesActivityFormScreenState extends State<SalesActivityFormScreen> {
  CustomerInfo? selectedCustomerInfo;

  List<CustomerInfo> customerList = [];
  List<String> provinceList = [];
  List<String> cityList = [];
  List<String> districtList = [];
  List<String> villageList = [];
  List<String> custBusiness = [
    "APLIKATOR BAJA RINGAN",
    "BENGKEL LAS (BAJA)",
    "DEVELOPER (GUDANG/RUMAH)",
    "END USER",
    "GROSIR BAHAN BANGUNAN",
    "GROSIR BAJA RINGAN",
    "KIOS KENCANA",
    "KONTRAKTOR UMUM/GENERAL KONTRAKTOR",
    "LAIN-LAIN",
    "PERUSAHAAN DAGANG",
    "PERUSAHAAN INDUSTRI (PABRIK/OWNER)",
    "PERUSAHAAN JASA/TRADING",
    "TOKO BANGUNAN UMUM",
    "TOKO BESI",
    "TOKO GALVALUM",
    "TOKO KACA & ALUMINIUM",
  ];
  List<String> custBusinessType = [
    "PERORANGAN",
    "CV",
    "FIRMA",
    "PT",
    "KOPERASI",
    "YAYASAN",
  ];

  List<String> custBusinessStatus = ["SWASTA NASIONAL", "BUMN", "PMA"];
  List<String> custTaxType = ["PKP", "NON PKP"];
  List<String> custOfficeType = ["GEDUNG", "RUKO", "RUMAH", "PABRIK/GUDANG"];
  List<String> custOfficeOwnership = ["SENDIRI", "SEWA", "KONTRAK", "LAINNYA"];
  List<String> custType = ["RETAIL", "PROJECT", "OTHER"];
  dynamic salesVehicle = {
    "Company Car": "Company Car",
    "Private Car": "Private Car",
    "Private Motorcycle": "Private Motorcycle",
    "Online Transport": "Online Transport",
  };

  dynamic newOrExisting = {"N": "Existing Customer", "Y": "New Customer"};

  String customerType = 'Existing Customer';
  String? selectedCustomer;
  String? selectedVehicle;
  String? selectedProvince;
  String? selectedCity;
  String? selectedDistrict;
  String? selectedVillage;
  String? selectedKindOfBusiness;
  String? selectedBusinessStatus;
  String? selectedBusinessType;
  String? selectedTaxType;
  String? selectedOfficeType;
  String? selectedOwnership;
  String? selectedCustomerType;
  String? selectedSalesVehicle;
  String? selectedNewOrExist;

  int currentStep = 0;
  double progress = 1;

  Timer? _debounce;

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

  final pageController = PageController(initialPage: 0);

  void resetCustomerForm() {
    custIdController.clear();
    nameController.clear();
    ktpController.clear();
    phoneController.clear();
    emailController.clear();
    addressController.clear();
    provinceController.clear();
    cityController.clear();
    districtController.clear();
    villageController.clear();
    selectedProvince = null;
    selectedCity = null;
    selectedDistrict = null;
    selectedVillage = null;
  }

  @override
  void dispose() {
    custIdController.dispose();
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
    log('Access to lib/presentation/sales_activity/sales_activity_form_screen.dart');
    super.initState();
    _debounce?.cancel();
    context.read<SalesActivityFormBloc>().add(FetchProvinces());
  }

  @override
  Widget build(BuildContext context) {
    bool isExisting = selectedNewOrExist == "N";

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
              backgroundColor: Theme.of(context).primaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                'Customer Visit',
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
            ),
            body: BlocConsumer<SalesActivityFormBloc, SalesActivityFormState>(
              listener: (context, state) {
                if (state is CustomerSearchError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Telah terjadi kesalahan. Silakan coba lagi!",
                      ),
                      duration: Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
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
                              BaseDropdownButton(
                                label: "New/Existing",
                                items: newOrExisting,
                                value: selectedNewOrExist,
                                onChanged: (val) {
                                  setState(() {
                                    selectedNewOrExist = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 6),

                              if (isExisting) ...[
                                BlocListener<
                                  SalesActivityFormBloc,
                                  SalesActivityFormState
                                >(
                                  listenWhen:
                                      (previous, current) =>
                                          current is CustomerDetailLoadSuccess,
                                  listener: (context, state) {
                                    if (state is CustomerDetailLoadSuccess) {
                                      final detail = state.customerDetail;

                                      setState(() {
                                        custIdController.text =
                                            detail.customerId;
                                        nameController.text =
                                            detail.namaCustomer;
                                        ktpController.text = detail.npwp;
                                        phoneController.text = detail.telepon;
                                        emailController.text = detail.email;
                                        addressController.text = detail.alamat;
                                        provinceController.text =
                                            detail.propinsi;
                                        cityController.text = detail.realCity;
                                        districtController.text =
                                            detail.district;
                                        villageController.text = detail.vilage;
                                      });
                                    }
                                  },
                                  child: BlocListener<
                                    SalesActivityFormBloc,
                                    SalesActivityFormState
                                  >(
                                    listenWhen:
                                        (previous, current) =>
                                            current is CustomerSearchSuccess,
                                    listener: (context, state) {
                                      if (state is CustomerSearchSuccess) {
                                        setState(() {
                                          customerList = state.customers;
                                        });
                                      }
                                    },
                                    child: BaseDropdownSearch<CustomerInfo>(
                                      label: "Customer",
                                      items: customerList,
                                      getLabel:
                                          (customer) => customer.namaCustomer,
                                      selectedValue: selectedCustomerInfo,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedCustomerInfo = val;
                                        });

                                        if (val != null) {
                                          context
                                              .read<SalesActivityFormBloc>()
                                              .add(
                                                FetchCustomerDetail(
                                                  widget.sales.companyId,
                                                  val.customerId,
                                                ),
                                              );
                                        }
                                      },
                                      onSearchChanged: (query) {
                                        if (_debounce?.isActive ?? false) _debounce?.cancel();
                                        _debounce = Timer(const Duration(milliseconds: 500), () {
                                          if (query.isNotEmpty) {
                                            context.read<SalesActivityFormBloc>().add(
                                              SearchCustomerData(
                                                widget.sales.companyId,
                                                query,
                                              ),
                                            );
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],

                              TextFormField(
                                controller: nameController,
                                readOnly: isExisting,
                                decoration: InputDecoration(
                                  label: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Customer Name',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.w,
                                            )
                                        ),
                                      ]
                                    ),
                                  ),
                                ),
                              ),
                              buildTextField(
                                label: "KTP/NPWP",
                                controller: ktpController,
                                isReadOnly: isExisting,
                              ),
                              TextFormField(
                                controller: phoneController,
                                readOnly: isExisting,
                                decoration: InputDecoration(
                                  label: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Customer Phone',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 16.w,
                                            )
                                        ),
                                      ]
                                    ),
                                  ),
                                ),
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
                              BlocBuilder<
                                SalesActivityFormBloc,
                                SalesActivityFormState
                              >(
                                builder: (context, state) {
                                  if (state is ProvinceLoadSuccess) {
                                    provinceList = state.provinces;
                                  } else if (state is SalesActivityError) {
                                    return Text(state.message);
                                  }
                                  return BaseDropdownSearch<String>(
                                    label: "Province",
                                    isDisabled: isExisting,
                                    items: provinceList,
                                    getLabel: (province) => province,
                                    selectedValue: selectedProvince,
                                    controller: provinceController,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          selectedProvince = val;
                                          cityController.clear();
                                          districtController.clear();
                                          villageController.clear();
                                          context
                                              .read<SalesActivityFormBloc>()
                                              .add(FetchCities(val));
                                        });
                                      }
                                    },
                                  );
                                },
                              ),
                              BlocBuilder<
                                SalesActivityFormBloc,
                                SalesActivityFormState
                              >(
                                builder: (context, state) {
                                  if (state is CityLoadSuccess) {
                                    cityList = state.cities;

                                    districtController.clear();
                                  } else if (state is SalesActivityError) {
                                    return Text(state.message);
                                  }
                                  return BaseDropdownSearch<String>(
                                    label: "City",
                                    isDisabled: isExisting,
                                    items: cityList,
                                    getLabel: (city) => city,
                                    selectedValue: selectedCity,
                                    controller: cityController,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          selectedCity = val;
                                          districtController.clear();
                                          villageController.clear();

                                          context
                                              .read<SalesActivityFormBloc>()
                                              .add(FetchDistricts(val));
                                        });
                                      }
                                    },
                                  );
                                },
                              ),
                              BlocBuilder<
                                SalesActivityFormBloc,
                                SalesActivityFormState
                              >(
                                builder: (context, state) {
                                  if (state is DistrictLoadSuccess) {
                                    districtList = state.districts;
                                  } else if (state is SalesActivityError) {
                                    return Text(state.message);
                                  }
                                  return BaseDropdownSearch<String>(
                                    label: "District",
                                    isDisabled: isExisting,
                                    items: districtList,
                                    getLabel: (district) => district,
                                    selectedValue: selectedDistrict,
                                    controller: districtController,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          selectedDistrict = val;
                                          villageController.clear();
                                          context
                                              .read<SalesActivityFormBloc>()
                                              .add(FetchVillages(val));
                                        });
                                      }
                                    },
                                  );
                                },
                              ),
                              BlocBuilder<
                                SalesActivityFormBloc,
                                SalesActivityFormState
                              >(
                                builder: (context, state) {
                                  if (state is VillageLoadSuccess) {
                                    villageList = state.villages;
                                  } else if (state is SalesActivityError) {
                                    return Text(state.message);
                                  }
                                  return BaseDropdownSearch<String>(
                                    label: "Village",
                                    isDisabled: isExisting,
                                    items: villageList,
                                    getLabel: (village) => village,
                                    selectedValue: selectedVillage,
                                    controller: villageController,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          selectedVillage = val;
                                        });
                                      }
                                    },
                                  );
                                },
                              ),
                              if (!isExisting) ...[
                                BaseDropdownButton(
                                  label: "Kind of Business",
                                  items: custBusiness,
                                  value: selectedKindOfBusiness,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedKindOfBusiness = val;
                                    });
                                  },
                                ),

                                BaseDropdownButton(
                                  label: "Business Status",
                                  items: custBusinessStatus,
                                  value: selectedBusinessStatus,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedBusinessStatus = val;
                                    });
                                  },
                                ),

                                BaseDropdownButton(
                                  label: "Business Type",
                                  items: custBusinessType,
                                  value: selectedBusinessType,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedBusinessType = val;
                                    });
                                  },
                                ),

                                BaseDropdownButton(
                                  label: "Tax Type",
                                  items: custTaxType,
                                  value: selectedTaxType,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedTaxType = val;
                                    });
                                  },
                                ),

                                BaseDropdownButton(
                                  label: "Office Type",
                                  items: custOfficeType,
                                  value: selectedOfficeType,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedOfficeType = val;
                                    });
                                  },
                                ),

                                BaseDropdownButton(
                                  label: "Ownership",
                                  items: custOfficeOwnership,
                                  value: selectedOwnership,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedOwnership = val;
                                    });
                                  },
                                ),

                                BaseDropdownButton(
                                  label: "Customer Type",
                                  items: custType,
                                  value: selectedCustomerType,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedCustomerType = val;
                                    });
                                  },
                                ),
                              ],

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

                              SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xff1C3FAA,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
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
                                        child: Text("Next"),
                                      ),
                                    ),
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
                      custId: selectedCustomerInfo?.customerId ?? '',
                      custName: nameController.text,
                      ktpNpwp: ktpController.text,
                      phone: phoneController.text,
                      email: emailController.text,
                      address: addressController.text,
                      province: selectedProvince ?? provinceController.text,
                      city: selectedCity ?? cityController.text,
                      district: selectedDistrict ?? districtController.text,
                      village: selectedVillage ?? villageController.text,
                      custBusiness: selectedKindOfBusiness,
                      custBusinessStatus: selectedBusinessStatus,
                      custBusinessType: selectedBusinessType,
                      custTaxType: selectedTaxType,
                      custOfficeType: selectedOfficeType,
                      custOwnership: selectedOwnership,
                      custType: selectedCustomerType,
                      salesVehicle: selectedSalesVehicle,
                      newOrExist: selectedNewOrExist,
                      salesId: widget.sales.salesId,
                      sales: widget.sales,
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
}

class _SalesActivityFormSecondStep extends StatefulWidget {
  final Function onBackFunction;
  final String custId;
  final String custName;
  final String ktpNpwp;
  final String phone;
  final String email;
  final String address;
  final String province;
  final String city;
  final String district;
  final String village;
  final String? custBusiness;
  final String? custBusinessStatus;
  final String? custBusinessType;
  final String? custTaxType;
  final String? custOfficeType;
  final String? custOwnership;
  final String? custType;
  final String? salesVehicle;
  final String? newOrExist;
  final String salesId;
  final SalesInfo sales;

  const _SalesActivityFormSecondStep({
    required this.onBackFunction,
    required this.custId,
    required this.custName,
    required this.ktpNpwp,
    required this.phone,
    required this.email,
    required this.address,
    required this.province,
    required this.city,
    required this.district,
    required this.village,
    this.custBusiness,
    this.custBusinessStatus,
    this.custBusinessType,
    this.custTaxType,
    this.custOfficeType,
    this.custOwnership,
    this.custType,
    this.newOrExist,
    required this.salesVehicle,
    required this.salesId,
    required this.sales,
  });

  @override
  State<_SalesActivityFormSecondStep> createState() =>
      _SalesActivityFormSecondStepState();
}

class _SalesActivityFormSecondStepState
    extends State<_SalesActivityFormSecondStep> {
  String? selectedOfficePoint;
  String? selectedUserPoint;
  String imagePath = '';

  bool setAsCustomerAddress = false;

  final ImagePicker _picker = ImagePicker();

  final MapController _mapController = MapController();
  final odometerController = TextEditingController();
  final remarkController = TextEditingController();

  final List<String> activities = [
    'Registrasi Customer Baru',
    'Penawaran Produk',
    'Taking Order',
    'Info Program/Hadiah',
    'Penagihan',
    'Customer Visit/Assistensi',
  ];

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
        final imageFile = File(pickedFile.path);
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
        context.read<SalesActivityFormBloc>().add(
          AddImageEvent(model.ImageItem(file: imageFile.path)),
        );

        if (odometerValue != null) {
          context.read<SalesActivityFormBloc>().add(
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
    final targetPath =
        "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

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
    odometerController.text =
        context.read<SalesActivityFormBloc>().state.odometer;
    context.read<SalesActivityFormBloc>().add(LoadCurrentLocation());
  }

  @override
  void dispose() {
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
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            final img = state.images[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 150,
                                  child: TextField(
                                    onChanged: (value) {
                                      context.read<SalesActivityFormBloc>().add(
                                        UpdateRemarkEvent(index, value),
                                      );
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Photo Remark",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
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
                        },
                      ),
                    ),
                  ],
                ),
              ),
              BlocListener<SalesActivityFormBloc, SalesActivityFormState>(
                listenWhen:
                    (previous, current) =>
                        previous.odometer != current.odometer,
                listener: (context, state) {
                  odometerController.text = state.odometer;
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.w,
                  ),
                  child: TextFormField(
                    controller: odometerController,
                    decoration: InputDecoration(
                      label: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Odometer',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16.w,
                                )
                            ),
                            TextSpan(
                              text: ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.w,
                                )
                            ),
                          ]
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
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
                      child: MultiBlocListener(
                        listeners: [
                          BlocListener<
                            SalesActivityFormBloc,
                            SalesActivityFormState
                          >(
                            listenWhen:
                                (previous, current) =>
                                    current is! CurrentLocationLoading &&
                                    current.position != null,
                            listener: (context, state) {
                              if (state.position != null) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  _mapController.move(
                                    LatLng(
                                      state.position!.latitude,
                                      state.position!.longitude,
                                    ),
                                    17.0,
                                  );
                                });
                              }
                            },
                          ),
                        ],
                        child: BlocBuilder<
                          SalesActivityFormBloc,
                          SalesActivityFormState
                        >(
                          builder: (context, state) {
                            if (state is CurrentLocationLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: LatLng(-7.250445, 112.768845),
                                initialZoom: 10.0,
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
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(state.address),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.w),
                child: SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<SalesActivityFormBloc, SalesActivityFormState>(
                    builder: (context, state) {
                      return BasePrimaryButton(
                        onPressed: () async {
                          final position =
                              await StrictLocation.getCurrentPosition();
                          if (position.isMocked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Perangkat terdeteksi menggunakan lokasi palsu",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          context.read<SalesActivityFormBloc>().add(
                            SetLocationEvent(),
                          );
                        },
                        isLoading: state.isLoadingLocation,
                        label: 'Get Location',
                        icon: Icons.location_on,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.w),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      setAsCustomerAddress = !setAsCustomerAddress;
                    });
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Row(
                    children: [
                      Checkbox(
                        value: setAsCustomerAddress,
                        onChanged: (value) {
                          setState(() {
                            setAsCustomerAddress = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          "Set This GPS Location as Customer Address",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.w),
                child: TextFormField(
                  controller: remarkController,
                  decoration: const InputDecoration(labelText: 'Remark'),
                  keyboardType: TextInputType.text,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: BlocBuilder<
                        SalesActivityFormBloc,
                        SalesActivityFormState
                      >(
                        builder: (context, state) {
                          final isLoading = state is SalesActivityFormLoading;
                          return BaseDangerButton(
                            label: 'Back',
                            onPressed:
                                isLoading
                                    ? null
                                    : () {
                                      widget.onBackFunction();
                                    },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 24.w),
                    Expanded(
                      child: BlocConsumer<
                        SalesActivityFormBloc,
                        SalesActivityFormState
                      >(
                        listener: (context, state) {
                          if (state is SalesActivityFormSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Form customer berhasil disubmit!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => SalesActivityDashboardScreen(
                                      sales: widget.sales,
                                    ),
                              ),
                            );
                          } else if (state is SalesActivityError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                          }
                        },
                        builder: (context, state) {
                          final isLoading = state is SalesActivityFormLoading;
                          return BasePrimaryButton(
                            label: "Submit",
                            isLoading: isLoading,
                            onPressed: () async {
                              if (state.address == '') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Mohon pastikan alamat tersedia.",
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              final selected = state.selectedActivities;
                              final List<model.ImageItem> modelImages =
                                  await prepareImagesForSubmission(
                                    state.images,
                                  );
                              final formData = model.SalesActivityFormData(
                                customerId: widget.custId,
                                customerName: widget.custName,
                                customerKtpNpwp: widget.ktpNpwp,
                                customerPhone: widget.phone,
                                customerEmail: widget.email,
                                customerAddress: widget.address,
                                customerProvince: widget.province,
                                customerCity: widget.city,
                                customerDistrict: widget.district,
                                customerVillage: widget.village,
                                customerBussiness: widget.custBusiness ?? '',
                                customerBussinessStatus:
                                    widget.custBusinessStatus ?? '',
                                customerBussinessType:
                                    widget.custBusinessType ?? '',
                                customerTaxType: widget.custTaxType ?? '',
                                customerOfficeType: widget.custOfficeType ?? '',
                                customerOfficeOwnership:
                                    widget.custOwnership ?? '',
                                customerType: widget.custType ?? '',
                                checkboxCar: widget.salesVehicle,
                                chkNewCustRequest: selected.contains(
                                  activities[0],
                                ),
                                chkProductOffer: selected.contains(
                                  activities[1],
                                ),
                                chkTakeOrder: selected.contains(activities[2]),
                                chkInfoPromo: selected.contains(activities[3]),
                                chkTakeBilling: selected.contains(
                                  activities[4],
                                ),
                                chkCustomerVisit: selected.contains(
                                  activities[5],
                                ),
                                currentLocation: state.address,
                                latitude: state.position!.latitude,
                                longitude: state.position!.longitude,
                                remark: remarkController.text,
                                images: modelImages,
                                salesid: widget.salesId,
                                setAddress: setAsCustomerAddress,
                                speedoKmModel: odometerController.text,
                              );

                              context.read<SalesActivityFormBloc>().add(
                                SubmitSalesActivityForm(formData),
                              );
                            },
                          );
                        },
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
