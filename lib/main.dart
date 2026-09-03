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
import 'package:hisabio/provider/reporting_provider/purchase_provider.dart';
import 'package:hisabio/provider/reporting_provider/retail_provider.dart';
import 'package:hisabio/provider/reporting_provider/bill_provider.dart';
import 'package:hisabio/provider/master_provider/staff_provider.dart';
import 'package:hisabio/provider/master_provider/supplier_provider.dart';
import 'package:hisabio/provider/master_provider/transport_provider.dart';
import 'package:hisabio/provider/master_provider/user_provider.dart';
import 'package:hisabio/screens/auth_manager.dart';
import 'package:hisabio/screens/home_screen.dart';
import 'package:hisabio/screens/login_screen.dart';
import 'package:hisabio/services/bills/bill_service.dart';
import 'package:hisabio/services/config/configuration_services.dart';
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
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:hisabio/utils/loading_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'network/api_provider.dart';
import 'network/api_service.dart';
final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Failed to load .env: $e');
  }
  LoadingService.initialize();
  final apiProvider = ApiProvider();
  final apiService = ApiService(apiProvider);
  final token = await AppStorage.getToken();

  Widget initialScreen;

  if (token == null || token.isEmpty) {
    initialScreen = const LoginScreen();
  } else if (JwtDecoder.isExpired(token)) {
    await AppStorage.clear();
    initialScreen = const LoginScreen();
  } else {
    initialScreen = const HomeScreen();
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiProvider>.value(
          value: apiProvider,
        ),

        Provider<ApiService>.value(
          value: apiService,
        ),

        ChangeNotifierProvider(
          create: (_) => LoginProvider(
            LoginService(apiService),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => TransportProvider(
            TransportService(apiService),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => SupplierProvider(
            SupplierService(apiService),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => CustomerProvider(
            CustomerService(apiService),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => StaffProvider(
            StaffService(apiService),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => UserProvider(
            UserService(apiService),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => EntriesProvider(
            EntriesService(context.read<ApiService>()),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => BillItemProvider(),
        ),

        ChangeNotifierProvider(
          create: (context) => BillProvider(
            BillService(context.read<ApiService>()),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => CreditProvider(
            CreditService(apiService),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => PurchaseProvider(
            PurchaseService(apiService),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => RetailProvider(
            RetailService(apiService),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => LedgerProvider(
            LedgerService(apiService),
          ),
        ),
    ChangeNotifierProvider(
      create: (_) => ConfigProvider(
        ConfigurationService(apiService),
      ),
        ),
      ],
      child: MyApp(
        initialScreen: initialScreen,
    ),
    )
  );
  AuthManager().initialize(navigatorKey);
}
class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({
    super.key,
    required this.initialScreen,});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData.light().textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryPurple,
        ),
      ),
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),

            ValueListenableBuilder<bool>(
              valueListenable: LoadingService.isLoading,
              builder: (context, isLoading, _) {
                if (!isLoading) {
                  return const SizedBox.shrink();
                }

                return Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.45),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(15),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryPurple,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      home:initialScreen,
    );
  }
}