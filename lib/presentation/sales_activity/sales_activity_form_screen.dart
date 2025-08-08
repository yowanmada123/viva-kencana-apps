import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/auth/authentication/authentication_bloc.dart';
import '../../bloc/auth/logout/logout_bloc.dart';
import '../../bloc/sales_activity/sales_activity_form_bloc.dart';
import '../../data/repository/auth_repository.dart';
import '../../models/errors/custom_exception.dart';
import '../../models/sales_activity/customer_info.dart';
import '../../models/sales_activity/submit_data.dart' as model;
import '../../utils/image_to_base_64_converter.dart';
import '../widgets/base_dropdown_button.dart';
import '../widgets/base_dropdown_search.dart';
import '../widgets/base_pop_up.dart';
import '../widgets/base_primary_button.dart';
import 'sales_activity_form_checkin_screen.dart';

class SalesActivityFormScreen extends StatefulWidget {
  const SalesActivityFormScreen({super.key});

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
  dynamic salesmanVehicle = {
    "Y": "Company Car",
    "N": "Private Car",
    "M": "Private Motorcycle",
    "L": "Online Transport",
  };

  dynamic newOrExisting = {
    "Y": "New Customer",
    "N": "Existing Customer",
  };

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
  String? selectedSalesmanVehicle;
  String? selectedNewOrExist;

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

  void resetCustomerForm() {
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
        builder:
            (_) => BasePopUpDialog(
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

    context.read<SalesActivityFormBloc>().add(FetchProvinces());
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
                if (state is CustomerSearchError) {
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
                              BaseDropdownButton(
                                label: "New/Existing",
                                items: newOrExisting,
                                value: selectedNewOrExist,
                                onChanged: (val){
                                  setState(() {
                                    selectedNewOrExist = val;
                                  });
                                }
                              ),
                              // DropdownButtonFormField<String>(
                              //   value: customerType,
                              //   padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                              //   decoration: const InputDecoration(
                              //     labelText: 'New/Existing',
                              //   ),
                              //   items:
                              //       ['Existing Customer', 'New Customer']
                              //           .map(
                              //             (type) => DropdownMenuItem(
                              //               value: type,
                              //               child: Text(type),
                              //             ),
                              //           )
                              //           .toList(),
                              //   onChanged: (value) {
                              //     setState(() {
                              //       customerType = value!;
                              //       selectedCustomer = null;

                              //       if (customerType == 'New Customer') {
                              //         resetCustomerForm();
                              //       }
                              //     });
                              //   },
                              // ),
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
                                        nameController.text =
                                            detail.namaCustomer;
                                        ktpController.text = detail.npwp;
                                        phoneController.text = detail.telepon;
                                        emailController.text = detail.email;
                                        addressController.text = detail.alamat;
                                        provinceController.text =
                                            detail.propinsi;
                                        cityController.text = detail.real_City;
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
                                                  val.customerId,
                                                ),
                                              );
                                        }
                                      },
                                      onSearchChanged: (query) {
                                        if (query.isNotEmpty) {
                                          context
                                              .read<SalesActivityFormBloc>()
                                              .add(SearchCustomerData(query));
                                        }
                                      },
                                    ),
                                  ),
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
                                label: "Salesman Vehicle",
                                items: salesmanVehicle,
                                value: selectedSalesmanVehicle,
                                onChanged: (val) {
                                  setState(() {
                                    selectedSalesmanVehicle = val;
                                  });
                                },
                              ),

                              SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  BasePrimaryButton(
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
                                    label: "Next",
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
                      salesVehicle: selectedSalesmanVehicle,
                      newOrExist: selectedNewOrExist,
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

  const _SalesActivityFormSecondStep({
    required this.onBackFunction,
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
  });

  @override
  State<_SalesActivityFormSecondStep> createState() =>
      _SalesActivityFormSecondStepState();
}

class _SalesActivityFormSecondStepState
    extends State<_SalesActivityFormSecondStep> {
  final MapController _mapController = MapController();
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

  Future<List<model.Image>> prepareImagesForSubmission(
    List<ImageWithFile> images,
  ) async {
    return await Future.wait(
      images.map((img) async {
        final url = await imageToDataUri(img.file);
        return model.Image(src: url, remark: img.remark, price: img.price);
      }),
    );
  }

  @override
  void initState() {
    super.initState();
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
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                state.images[index].file,
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
                child: BasePrimaryButton(
                  onPressed:
                      () => context.read<SalesActivityFormBloc>().add(
                        SetLocationEvent(),
                      ),
                  label: 'Get Location',
                  icon: Icons.location_on,
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
                    // BlocBuilder<SalesActivityFormBloc, SalesActivityFormState>(
                    //   builder: (context, state) {
                    //   },
                    // ),
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
                          ),
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
                        onPressed: () async {
                          final activities = [
                            'Registrasi Customer Baru',
                            'Penawaran Produk',
                            'Taking Order',
                            'Info Program/Hadiah',
                            'Penagihan',
                            'Customer Visit/Assistensi',
                          ];
                          final selected = state.selectedActivities;
                          final List<model.Image> modelImages =
                              await prepareImagesForSubmission(state.images);
                          final formData = model.SalesActivityFormData(
                            customerId: '',
                            custName: widget.custName,
                            custKtpNpwp: widget.ktpNpwp,
                            custPhone: widget.phone,
                            custEmail: widget.email,
                            custAddress: widget.address,
                            custProvince: widget.province,
                            custCity: widget.city,
                            custDistrict: widget.district,
                            custVillage: widget.village,
                            custBussiness: widget.custBusiness ?? '',
                            custBussinessStatus:
                                widget.custBusinessStatus ?? '',
                            custBussinessType: widget.custBusinessType ?? '',
                            custTaxType: widget.custTaxType ?? '',
                            custOfficeType: widget.custOfficeType ?? '',
                            custOfficeOwnership: widget.custOwnership ?? '',
                            custType: widget.custType ?? '',
                            checkboxCar: widget.salesVehicle,
                            checkbox1: selected.contains(activities[0]),
                            checkbox2: selected.contains(activities[1]),
                            checkbox3: selected.contains(activities[2]),
                            checkbox4: selected.contains(activities[3]),
                            checkbox5: selected.contains(activities[4]),
                            checkbox6: selected.contains(activities[5]),
                            currentLocation: state.address,
                            latitude: state.position!.latitude,
                            longitude: state.position!.longitude,
                            remark: "",
                            image: "",
                            images: modelImages,
                            new_: widget.newOrExist,
                            checkpoint: "",
                            salesid: "",
                            speedoKmModel: "",
                          );

                          context.read<SalesActivityFormBloc>().add(
                            SubmitSalesActivityForm(formData),
                          );
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
