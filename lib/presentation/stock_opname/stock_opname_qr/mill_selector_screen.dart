import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vivakencanaapp/bloc/stock_opname/mill/mill_bloc.dart';
import 'package:vivakencanaapp/bloc/stock_opname/mill_selector/mill_selector_bloc.dart';
import 'package:vivakencanaapp/models/mill.dart';
import 'package:vivakencanaapp/presentation/stock_opname/stock_opname/stock_opname_hdr_screen.dart';

class MillSelectorScreen extends StatelessWidget {
  static String routeName = "millSelectorScreen";

  const MillSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    log('Access to mill_selector_screen.dart');

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<MillSelectorBloc>()..add(MillSelectorLoadEvent()),
        ),
        BlocProvider.value(value: context.read<MillBloc>()),
      ],
      child: const MillSelectorView(),
    );
  }
}

class MillSelectorView extends StatefulWidget {
  const MillSelectorView({super.key});

  @override
  State<MillSelectorView> createState() => _MillSelectorViewState();
}

class _MillSelectorViewState extends State<MillSelectorView> {
  Mill? selectedMill;

  Widget buildDropdown(List<Mill> mills, Size deviceSize) {
    if (mills.length == 1 && selectedMill == null) {
      selectedMill = mills.first;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: deviceSize.height * 0.05),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Image.asset(
                  'assets/images/image-removebg-preview.png',
                  width: 250.w,
                  height: 200.w,
                ),
              ),

              SizedBox(height: 20.h),

              DropdownButtonFormField<Mill>(
                value: selectedMill,
                hint: const Text("Select Mill"),
                items:
                    mills.map((mill) {
                      return DropdownMenuItem(
                        value: mill,
                        child: Text(mill.millName),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMill = value;
                  });
                },
              ),

              SizedBox(height: 24.h),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          selectedMill == null
                              ? null
                              : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => OpnameStockHdrScreen(
                                          mill: selectedMill!,
                                        ),
                                  ),
                                );
                              },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        'GO',
                        style: TextStyle(
                          fontSize: 16.w,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Choose Office",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: BlocListener<MillSelectorBloc, MillSelectorState>(
        listener: (context, state) {
          if (state is MillSelectorSuccess && state.mills.isEmpty) {
            final millBloc = context.read<MillBloc>();

            if (millBloc.state is MillInitial) {
              log("Fallback → menjalankan MillBloc");
              millBloc.add(MillLoadEvent());
            }
          }
        },

        child: BlocBuilder<MillSelectorBloc, MillSelectorState>(
          builder: (context, selectorState) {
            if (selectorState is MillSelectorLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (selectorState is MillSelectorFailure) {
              return Center(child: Text(selectorState.message));
            }

            if (selectorState is MillSelectorSuccess) {
              /// Jika mill ada → langsung tampil
              if (selectorState.mills.isNotEmpty) {
                return buildDropdown(selectorState.mills, deviceSize);
              }

              /// Jika kosong → fallback ke MillBloc
              return BlocBuilder<MillBloc, MillState>(
                builder: (context, millState) {
                  if (millState is MillInitial || millState is MillLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (millState is MillFailure) {
                    return Center(child: Text(millState.exception.toString()));
                  }

                  if (millState is MillSuccess) {
                    return buildDropdown(millState.mills, deviceSize);
                  }

                  return const SizedBox();
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
