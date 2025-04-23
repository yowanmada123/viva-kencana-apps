import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../warehouse/warehouse_select_screen.dart';
import 'qr_code_manual_screen.dart';
import 'qr_code_scan_screen.dart';

class QrCodeScreen extends StatelessWidget {
  static String routeName = "qrCodeScreen";
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const QrCodeView();
  }
}

class QrCodeView extends StatelessWidget {
  const QrCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Scan QR Code",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 24,
                color: Color(0xff3B3B3B),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SvgPicture.asset("assets/svg/qr-code-image.svg"),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final String id = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QrCodeScanScreen(),
                          ),
                        );
                        if (id != "") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      WarehouseSelectScreen(batchID: id),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        'Scan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final String id = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QrCodeManualScreen(),
                          ),
                        );
                        if (id != "") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      WarehouseSelectScreen(batchID: id),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        'Input Manual',
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
            ),
          ],
        ),
      ),
    );
  }
}
