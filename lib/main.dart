import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/provider/add_customer.dart';
import 'package:hisabio/provider/add_new_staff_provider.dart';
import 'package:hisabio/provider/add_new_transport.dart';
import 'package:hisabio/provider/add_newsupplier.dart';
import 'package:hisabio/provider/delete_customer_provider.dart';
import 'package:hisabio/provider/delete_staff_provider.dart';
import 'package:hisabio/provider/delete_supplier_provider.dart';
import 'package:hisabio/provider/delete_transport_provider.dart';
import 'package:hisabio/provider/entries_provider/entries_section_provider.dart';
import 'package:hisabio/provider/get_customer_byid_provider.dart';
import 'package:hisabio/provider/get_customers_provider.dart';
import 'package:hisabio/provider/get_staff_by_id_provider.dart';
import 'package:hisabio/provider/get_staff_provider.dart';
import 'package:hisabio/provider/get_supplier_provider.dart';
import 'package:hisabio/provider/get_suppliers_byid_provider.dart';
import 'package:hisabio/provider/get_transport_by_id_provider.dart';
import 'package:hisabio/provider/get_transport_details_provider.dart';
import 'package:hisabio/provider/get_transport_provider.dart';
import 'package:hisabio/provider/get_user_provider.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hisabio/provider/login_provider.dart';
import 'package:hisabio/provider/search_customer_provider.dart';
import 'package:hisabio/provider/search_staff_provider.dart';
import 'package:hisabio/provider/search_supplier_provider.dart';
import 'package:hisabio/provider/search_transport_provider.dart';
import 'package:hisabio/provider/update_customer_provider.dart';
import 'package:hisabio/provider/update_staff_provider.dart';
import 'package:hisabio/provider/update_supplier_provider.dart';
import 'package:hisabio/provider/user_all_provider.dart';
import 'package:hisabio/screens/login_screen.dart';
//import 'package:hisabio/screens/master_screens/add_new_supplier.dart';
import 'package:provider/provider.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  //await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => TransportProvider()),
        ChangeNotifierProvider(create: (_) =>AddSupplierProvider()),
        ChangeNotifierProvider(create: (_)=>DeleteSupplierProvider ()),
        ChangeNotifierProvider(create: (_) => UpdateSupplierProvider()),
        ChangeNotifierProvider(create: (_) => GetSupplierByIdProvider()),
        ChangeNotifierProvider(create: (_)=> SearchSupplierProvider()),
        ChangeNotifierProvider(create: (_)=> CustomersProvider()),
        ChangeNotifierProvider(create: (_)=> DeleteCustomerProvider()),
        ChangeNotifierProvider(create: (_)=> AddCustomerProvider()),
        ChangeNotifierProvider(create: (_)=> SearchCustomerProvider()),
        ChangeNotifierProvider(create: (_)=> GetCustomerByIdProvider()),
        ChangeNotifierProvider(create: (_)=> UpdateCustomerProvider()),
        ChangeNotifierProvider(create: (_)=> GetStaffProvider()),
        ChangeNotifierProvider(create: (_)=> DeleteStaffProvider()),
        ChangeNotifierProvider(create: (_)=> SearchStaffProvider()),
        ChangeNotifierProvider(create: (_)=> AddNewStaffProvider()),
        ChangeNotifierProvider(create: (_)=> GetStaffByIdProvider()),
        ChangeNotifierProvider(create: (_)=>  UpdateStaffProvider()),
        ChangeNotifierProvider(create: (_)=>  GetTransportProvider()),
        ChangeNotifierProvider(create: (_)=>  DeleteTransportProvider()),
        ChangeNotifierProvider(create: (_)=>  AddNewTransportProvider()),
        ChangeNotifierProvider(create: (_)=>SearchTransportProvider()),
        ChangeNotifierProvider(create: (_)=>GetTransportByIdProvider()),
        ChangeNotifierProvider(create: (_)=> GetUsersProvider()),
        ChangeNotifierProvider(create: (_)=>   UserProvider()),
        ChangeNotifierProvider(create: (_)=>  EntriesProvider()),
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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme),

        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryPurple),
      ),
      home: const LoginScreen(),
    );
  }
}
