import 'package:flutter/material.dart';

import '../screens/entry_screen/entries_bill_entry.dart';
import '../screens/master_screens/supplier.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Supplier()),
            );
            break;

          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const EntriesBillEntry()),
            );
            break;

          //case 2:
          //Navigator.pushReplacement(
          //context,
          //MaterialPageRoute(
          //builder: (_) => const ReportingScreen(),
          //),
          //);
          //break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Master"),
        BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Entries"),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: "Reporting",
        ),
      ],
    );
  }
}
