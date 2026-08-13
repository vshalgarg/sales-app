import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/provider/master_provider/config_provider.dart';
import 'package:hisabio/provider/reporting_provider/credit_provider.dart';
import 'package:hisabio/provider/master_provider/customer_provider.dart';
import 'package:hisabio/provider/entries_provider/add_bill_item_calculation.dart';
import 'package:hisabio/provider/entries_provider/entries_section_provider.dart';
import 'package:hisabio/provider/reporting_provider/ledger_provider.dart';
import 'package:hisabio/provider/login_provider.dart';
import 'package:hisabio/provider/monitoring_provider/graph_provider.dart';
import 'package:hisabio/provider/reporting_provider/purchase_provider.dart';
import 'package:hisabio/provider/reporting_provider/retail_provider.dart';
import 'package:hisabio/provider/reporting_provider/bill_provider.dart';
import 'package:hisabio/provider/master_provider/staff_provider.dart';
import 'package:hisabio/provider/master_provider/supplier_provider.dart';
import 'package:hisabio/provider/master_provider/transport_provider.dart';
import 'package:hisabio/provider/master_provider/user_provider.dart';
import 'package:hisabio/screens/auth_manager.dart';

import 'package:hisabio/screens/splash_screen.dart';
import 'package:hisabio/services/bills/bill_service.dart';
import 'package:hisabio/services/credit/credit_services.dart';
import 'package:hisabio/services/customer/customer_services.dart';
import 'package:hisabio/services/entries_services/entries_service.dart';
import 'package:hisabio/services/ledger/ledger_service.dart';
import 'package:hisabio/services/login.dart';
import 'package:hisabio/services/purchase/purchase_service.dart';
import 'package:hisabio/services/retail/retail_service.dart';
import 'package:hisabio/services/staff/staff_service.dart';
import 'package:hisabio/services/suppliers/supplier_service.dart';
import 'package:hisabio/services/transport/transport_service.dart';
import 'package:hisabio/services/user/user_service.dart';
import 'package:provider/provider.dart';
import 'network/api_provider.dart';
import 'network/api_service.dart';
final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  AuthManager().initialize(navigatorKey);
  final apiProvider = ApiProvider(
  );
  final apiService = ApiService(apiProvider);
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiProvider>.value(
          value: apiProvider,
        ),

        Provider<ApiService>.value(
          value: apiService,
        ),
        ChangeNotifierProvider(create: (_) => LoginProvider(LoginService(apiService))),
        ChangeNotifierProvider(create: (_) => TransportProvider(
            TransportService(apiService))),
        ChangeNotifierProvider(create: (_)=> SupplierProvider(
            SupplierService(apiService))),
        ChangeNotifierProvider(create: (_)=> CustomerProvider(
           CustomerService(apiService))),
        ChangeNotifierProvider(create: (_)=> StaffProvider(
            StaffService(apiService))),
        ChangeNotifierProvider(create: (_)=>   UserProvider(
            UserService(apiService))),
       ChangeNotifierProvider(create: (context) => EntriesProvider(
            EntriesService(context.read<ApiService>()))),
        ChangeNotifierProvider(create: (_)=> BillItemProvider()),
        ChangeNotifierProvider(create: (context) => BillProvider(
            BillService( context.read<ApiService>(),))),
        ChangeNotifierProvider(create: (_) => CreditProvider(
            CreditService(apiService)),),
        ChangeNotifierProvider(create: (_) => PurchaseProvider(
            PurchaseService(apiService))),
        ChangeNotifierProvider(create: (_) => StaffProvider(
            StaffService(apiService))),
        ChangeNotifierProvider(create: (_) => RetailProvider(
            RetailService(apiService)),),
       ChangeNotifierProvider(create: (_) => LedgerProvider(
           LedgerService(apiService))),
        ChangeNotifierProvider(create: (_) => GraphProvider(),),
        ChangeNotifierProvider(create: (_) => ConfigProvider(),),
        //ChangeNotifierProvider(create: (_) => RetailDetailsProvider(),),
      ],
      child: const MyApp(),

    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryPurple),
      ),
      home: const SplashScreen(),
    );
  }
}
