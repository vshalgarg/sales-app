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
import '../provider/master_provider/config_provider.dart';
import '../provider/master_provider/permission_provider.dart';
import '../shared_preferences/login_token.dart';
import 'master_screens/access_management.dart';
import 'master_screens/configurations.dart';
import 'master_screens/customer.dart';
import 'master_screens/staff.dart';
import 'master_screens/supplier.dart';
import 'master_screens/transport.dart';
import 'master_screens/users.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String email = "";
  String role = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    final configProvider = context.read<ConfigProvider>();

    Future.microtask(() {
      configProvider.fetchConfiguration();
    });
  }

  Future<void> _loadUserData() async {
    final emailValue = await AppStorage.getEmail();
    final roleValue = await AppStorage.getRole();

    setState(() {
      if (emailValue != null && emailValue.contains("@")) {
        email = emailValue.split("@").first;
      } else {
        email = emailValue ?? "";
      }

      role = roleValue ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissionProvider = context.watch<PermissionProvider>();

    final canShowSupplier =
        permissionProvider.canView('SUPPLIER') ||
        permissionProvider.canCreate('SUPPLIER');

    final canShowCustomer =
        permissionProvider.canView('CUSTOMER') ||
        permissionProvider.canCreate('CUSTOMER');

    final canShowUser =
        permissionProvider.canView('USER') ||
        permissionProvider.canCreate('USER');

    final canShowStaff =
        permissionProvider.canView('STAFF') ||
        permissionProvider.canCreate('STAFF');

    final canShowTransport =
        permissionProvider.canView('TRANSPORT') ||
        permissionProvider.canCreate('TRANSPORT');
    final canShowAccessManagement = permissionProvider.hasPermission(
      'ACCESS_MANAGEMENT_CURD',
    );

    final canShowBills =
        permissionProvider.canView('BILL_REPORT') ||
        permissionProvider.canCreate('BILL');

    final canShowCredit =
        permissionProvider.canView('CREDIT_REPORT') ||
        permissionProvider.canCreate('CREDIT');

    final canShowPurchase =
        permissionProvider.canView('PURCHASE_REPORT') ||
        permissionProvider.canCreate('PURCHASE');

    final canShowLedger = permissionProvider.canView('LEDGER_REPORT');
    final provider = context.watch<ConfigProvider>();
    return Scaffold(
        appBar: NewCustomAppBar(),

        backgroundColor: AppColors.bodyFillColor,

        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.bodyFillColor,

          child: SingleChildScrollView(
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

            Container(
              color: AppColors.bodyFillColor,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      mainAxisSpacing: 16,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        if (canShowSupplier)
                          menuItemCard(
                            imagePath: "assets/images/supplier 1.png",
                            title: "Suppliers",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SupplierScreen(),
                                ),
                              );
                            },
                          ),
                        if (canShowCustomer)
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
                        if (canShowStaff)
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
                        if (canShowUser)
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
                        if (canShowTransport)
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
                        if (canShowAccessManagement)
                          menuItemCard(
                            imagePath: "assets/images/access_management.png",
                            title: "Access Management",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AccessManagementScreen(),
                                ),
                              );
                            },
                          ),
                        if (role.trim().toUpperCase() == "ADMIN")
                          menuItemCard(
                            imagePath: "assets/images/config.png",
                            title: "Configurations",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConfigurationScreen(),
                                ),
                              );
                            },
                          ),
                        if (canShowBills)
                          menuItemCard(
                            imagePath: "assets/images/bill.png",
                            title: "Bills",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Bills()),
                              );
                            },
                          ),
                        if (canShowCredit)
                          menuItemCard(
                            imagePath: "assets/images/credits.png",
                            title: "Credits",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreditScreen(),
                                ),
                              );
                            },
                          ),
                        if (canShowPurchase)
                          menuItemCard(
                            imagePath: "assets/images/purchase.png",
                            title: "Purchases",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Purchases(),
                                ),
                              );
                            },
                          ),
                        if (provider.retailEnabled &&
                            (permissionProvider.hasPermission('RETAIL_CREATE') ||
                                permissionProvider.hasPermission(
                                  'RETAIL_REPORT_VIEW',
                                )))
                          menuItemCard(
                            imagePath: "assets/images/retailors.png",
                            title: "Retail",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Retail()),
                              );
                            },
                          ),
                        if (canShowLedger)
                          menuItemCard(
                            imagePath: "assets/images/ledger.png",
                            title: "Ledger",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LedgerReporting(),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}
