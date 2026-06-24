import 'package:flutter/material.dart';
import 'package:hisabio/customs/containers/new_custom_app_bar.dart';
import 'package:hisabio/customs/widget_menu.dart';
import 'package:hisabio/screens/reporting_screen/bills.dart';
import 'package:hisabio/screens/reporting_screen/credit.dart';
import 'package:hisabio/screens/reporting_screen/purchase.dart';
import 'package:hisabio/screens/reporting_screen/retail.dart';

import '../constants/colors_used.dart';
import 'master_screens/customer.dart';
import 'master_screens/staff.dart';
import 'master_screens/supplier.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewCustomAppBar(),
      body: Column(
        children: [
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Group 1.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20, bottom: 10),
              child: Text(
                "Hello Amit",
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    menuItemCard(
                      imagePath: "assets/images/supplier 1.png",
                      title: "Suppliers",
                      onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>Supplier()));},
                    ),
                    menuItemCard(
                      imagePath: "assets/images/supplier 1.png",
                      title: "Customers",
                      onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>CustomerScreen()));},
                    ),
                    menuItemCard(
                      imagePath: "assets/images/supplier 1.png",
                      title: "Staff",
                      onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>StaffScreen()));},
                    ),
                    menuItemCard(
                      imagePath: "assets/images/supplier 1.png",
                      title: "Users",
                      onTap: () {},
                    ),
                    menuItemCard(
                      imagePath: "assets/images/supplier 1.png",
                      title: "Transport",
                      onTap: () {},
                    ),
                    menuItemCard(
                      imagePath: "assets/images/supplier 1.png",
                      title: "Configuration",
                      onTap: () {},
                    ),
                    menuItemCard(
                      imagePath: "assets/images/supplier 1.png",
                      title: "Bills",
                      onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context)=> Bills ()));},
                    ),
                    menuItemCard(
                      imagePath: "assets/images/supplier 1.png",
                      title: "Credits",
                      onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context)=> Credit ()));},
                    ),
                    menuItemCard(
                      imagePath: "assets/images/supplier 1.png",
                      title: "Purchases",
                      onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context)=> Purchase ()));},
                    ),
                    menuItemCard(
                      imagePath: "assets/images/supplier 1.png",
                      title: "Retailors",
                      onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context)=> Retail ()));},
                    ),
                    menuItemCard(
                      imagePath: "assets/images/supplier 1.png",
                      title: "Ledger",
                      onTap: () {},
                    ),
                    menuItemCard(
                      imagePath: "assets/images/supplier 1.png",
                      title: "Charts",
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
