import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vivakencanaapp/bloc/stock_opname/mill/mill_bloc.dart';
import 'package:vivakencanaapp/models/mill.dart';

import '../stock_opname/stock_opname_hdr_screen.dart';

class QrCodeOpnameScreen extends StatelessWidget {
  static String routeName = "qrCodeOpnameScreen";
  const QrCodeOpnameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final millRepository = context.read<MillRepository>();

    log('Access to lib/presentation/qr_code_opname/qr_code_opname_screen.dart');

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<MillBloc>()..add(MillLoadEvent()),
        ),
      ],
      child: const QrCodeView(),
    );
  }
}

class QrCodeView extends StatefulWidget {
  const QrCodeView({super.key});

  @override
  State<QrCodeView> createState() => _QrCodeViewState();
}

class _QrCodeViewState extends State<QrCodeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Choose Mill",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.w,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Image.asset("assets/images/image-removebg-preview.png"),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: BlocBuilder<MillBloc, MillState>(
                  builder: (context, state) {
                    /// 🔄 LOADING
                    if (state is MillLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    /// ❌ FAILURE
                    if (state is MillFailure) {
                      return Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            state.exception.toString(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              context.read<MillBloc>().add(
                                const MillLoadEvent(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      );
                    }

                    /// ✅ SUCCESS
                    if (state is MillSuccess) {
                      return _MillDropdownSection(mills: state.mills);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MillDropdownSection extends StatefulWidget {
  final List<Mill> mills;

  const _MillDropdownSection({required this.mills});

  @override
  State<_MillDropdownSection> createState() => _MillDropdownSectionState();
}

class _MillDropdownSectionState extends State<_MillDropdownSection> {
  Mill? selectedMill;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<Mill>(
          value: selectedMill,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Pilih Mill',
            border: OutlineInputBorder(),
          ),
          items:
              widget.mills.map((mill) {
                return DropdownMenuItem<Mill>(
                  value: mill,
                  child: Text('${mill.millID} - ${mill.millName}'),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              selectedMill = value;
            });
          },
        ),

        const SizedBox(height: 12),
        ElevatedButton(
          onPressed:
              selectedMill == null
                  ? null
                  : () {
                    print(selectedMill);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => OpnameStockHdrScreen(
                              mill: selectedMill!, // ✅ object dibawa
                            ),
                      ),
                    );
                  },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
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
      ],
    );
  }
}
