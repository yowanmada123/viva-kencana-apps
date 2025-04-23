import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QrCodeManualScreen extends StatelessWidget {
  const QrCodeManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Color(0xff3B3B3B)),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        title: Text("Input Manual Code"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: deviceSize.height * 0.05),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  hintStyle: TextStyle(fontSize: 14),
                  isCollapsed: true,
                ),
                obscureText: true,
              ),
              SizedBox(height: 20.w),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context, qrCodeManualController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        // padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        'Submit ',
                        style: TextStyle(
                          fontSize: 16,
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
}
