import 'package:flutter/material.dart';
import '../qr_code/qr_code_screen.dart';
import '../fdpi/fdpi_menu_screen.dart';

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyGridLayout();
  }
}

class MyGridLayout extends StatelessWidget {
  final List<Map<String, dynamic>> buttons = [
    {'icon': Icons.local_shipping, 'text': 'Loading'},
    {'icon': Icons.real_estate_agent, 'text': 'FDPI'},
    // {'icon': Icons.diversity_2, 'text': 'CRM'},
    // {'icon': Icons.supervisor_account, 'text': 'HRIS'},
    // {'icon': Icons.storage, 'text': 'Master'},
    // {'icon': Icons.attach_money, 'text': 'Purchasing'},
    // {'icon': Icons.warehouse, 'text': 'Warehouse'},
    // {'icon': Icons.bar_chart, 'text': 'Report'},
    // {'icon': Icons.local_shipping, 'text': 'Projects'},
    // {'icon': Icons.request_quote_outlined, 'text': 'Tax'},
    // {'icon': Icons.factory, 'text': 'Manufacture'},
    // {'icon': Icons.people, 'text': 'HRIS'},
  ];

  void _navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QrCodeScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FDPIMenuScreen()),
        );
        break;
      default:
        print(index);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1E4694),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Color(0xffffffff)),
          onPressed: () => print("Menu"),
        ),
        title: Text(
          'VIVA KENCANA',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
        child: GridView.count(
          crossAxisCount: 4, // Number of columns
          children: List.generate(buttons.length, (index) {
            return Container(
              padding: EdgeInsets.all(4.0),
              // margin: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        color: Color(0xff1E4694),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: IconButton(
                        icon: Icon(buttons[index]['icon']),
                        iconSize: 24.0,
                        color: Colors.white,
                        onPressed: () {
                          // Add your onPressed logic here
                          _navigateToScreen(context, index);
                        },
                      ),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      buttons[index]['text'],
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Color(0xff1E4694),
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
