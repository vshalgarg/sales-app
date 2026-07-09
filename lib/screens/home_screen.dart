import 'package:flutter/material.dart';
import 'package:hisabio/customs/containers/new_custom_app_bar.dart';
import 'package:hisabio/customs/widget_menu.dart';
import 'package:hisabio/screens/reporting_screen/bills.dart';
import 'package:hisabio/screens/reporting_screen/credit.dart';
import 'package:hisabio/screens/reporting_screen/ledger.dart';
import 'package:hisabio/screens/reporting_screen/purchase.dart';
import 'package:hisabio/screens/reporting_screen/retail.dart';
import 'package:provider/provider.dart';
import '../constants/colors_used.dart';
import '../provider/config_provider.dart';
import '../shared_preferences/login_token.dart';
import 'master_screens/configurations.dart';
import 'master_screens/customer.dart';
import 'master_screens/staff.dart';
import 'master_screens/supplier.dart';
import 'master_screens/transport.dart';
import 'master_screens/users.dart';
import 'monitoring_screens/charts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
 // bool showRetailFeature = false;
  String email = "";
  @override
  void initState() {
    super.initState();
    _loadEmail();
    Future.microtask(() {
      context.read<ConfigProvider>().fetchConfiguration();
    });
  }
  Future<void> _loadEmail() async {
    final value = await AppStorage.getEmail();

    setState(() {
      if (value != null && value.contains("@")) {
        email = value.split("@").first;
      } else {
        email = value ?? "";
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConfigProvider>();
    return Scaffold(
      appBar: NewCustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Group 1.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  "Hello $email",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    //crossAxisSpacing: 16,
                     mainAxisSpacing: 16,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      menuItemCard(
                        imagePath: "assets/images/supplier 1.png",
                        title: "Suppliers",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Supplier()),
                          );
                        },
                      ),
                      menuItemCard(
                        imagePath: "assets/images/customer.png",
                        title: "Customers",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerScreen(),
                            ),
                          );
                        },
                      ),
                      menuItemCard(
                        imagePath: "assets/images/teamwork.png",
                        title: "Staff",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StaffScreen(),
                            ),
                          );
                        },
                      ),
                      menuItemCard(
                        imagePath: "assets/images/users.png",
                        title: "Users",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UsersScreen(),
                            ),
                          );
                        },
                      ),
                      menuItemCard(
                        imagePath: "assets/images/transport.png",
                        title: "Transport",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransportScreen(),
                            ),
                          );
                        },
                      ),
                        menuItemCard(
                          imagePath: "assets/images/config.png",
                          title: "Configurations",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ConfigurationScreen()),
                            );
                          },
                        ),
                      menuItemCard(
                        imagePath: "assets/images/bill.png",
                        title: "Bills",
                        onTap: () {Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Bills()));
                        },
                      ),
                      menuItemCard(
                        imagePath: "assets/images/credits.png",
                        title: "Credits",
                        onTap: () { Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Credit()));
                        },
                      ),
                      menuItemCard(
                        imagePath: "assets/images/purchase.png",
                        title: "Purchases",
                        onTap: () {Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Purchase()));
                        },
                      ),


                      if(provider.retailEnabled)
                      menuItemCard(
                        imagePath: "assets/images/retailors.png",
                        title: "Retailors",
                        onTap: () {Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Retail()));}
                      ),
                      menuItemCard(
                        imagePath: "assets/images/ledger.png",
                        title: "Ledger",
                        onTap: () {Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LedgerReporting()));},
                      ),
                      menuItemCard(
                        imagePath: "assets/images/charts.png",
                        title: "Charts",
                        onTap: () {Navigator.push(context, MaterialPageRoute(builder:(context)=>ChartsScreen()));},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )));
  }
}
