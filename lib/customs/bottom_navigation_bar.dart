import 'package:flutter/material.dart';
class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,

      items: [
        BottomNavigationBarItem(label: "Master", icon: Icon(Icons.add_a_photo)),
        BottomNavigationBarItem(icon: Icon(Icons.add_a_photo), label: "Entries"),
        BottomNavigationBarItem(icon: Icon(Icons.add_a_photo), label: "Reporting"),
      ],
    );
  }
}
