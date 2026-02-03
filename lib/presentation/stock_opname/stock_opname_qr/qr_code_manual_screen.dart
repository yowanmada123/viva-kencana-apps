import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QrCodeManualScreen extends StatelessWidget {
  const QrCodeManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    log('Access to lib/presentation/qr_code_opname/qr_code_manual_screen.dart');
    return QrCodeView();
  }
}

class QrCodeView extends StatelessWidget {
  final TextEditingController qrCodeManualController = TextEditingController();

  QrCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text("Input Manual Code")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: deviceSize.height * 0.05),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Image.asset(
                    'assets/images/gembok-removebg-preview.png',
                    width: 200.w,
                    height: 200.w,
                  ),
                ),
                TextField(
                  controller: qrCodeManualController,
                  decoration: InputDecoration(
                    hintText: 'Input Kode',
                    hintStyle: TextStyle(fontSize: 14.w),
                  ),
                ),
                SizedBox(height: 20.w),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          log(qrCodeManualController.text);
                          Navigator.pop(context, qrCodeManualController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          // padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          'Submit ',
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
      ),
    );
  }
}
