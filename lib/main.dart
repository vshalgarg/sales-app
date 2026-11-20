
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/provider/master_provider/config_provider.dart';
import 'package:hisabio/provider/master_provider/permission_provider.dart';
import 'package:hisabio/provider/master_provider/role_provider.dart';
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
import 'package:hisabio/services/role/role_service.dart';
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

  // Restore permissions from valid JWT.
  // Restore permissions from valid JWT.
  List<dynamic> savedPermissions = [];

  if (token != null && token.isNotEmpty) {
    try {
      if (!JwtDecoder.isExpired(token)) {
        final decodedToken = JwtDecoder.decode(token);

        debugPrint('========== STARTUP JWT ==========');
        debugPrint('Token roles: ${decodedToken['roles']}');

        final permissions = decodedToken['permissions'];

        if (permissions is List) {
          savedPermissions = permissions;
        }

        debugPrint('JWT permissions count: ${savedPermissions.length}');
        debugPrint('JWT permissions: $savedPermissions');
        debugPrint('=================================');
      }
    } catch (e) {
      debugPrint('JWT permission restoration failed: $e');
    }
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
          create: (_) => PermissionProvider()
            ..setPermissions(savedPermissions),
        ),

        ChangeNotifierProvider(
          create: (context) => RoleProvider(
            RoleService(context.read<ApiService>()),
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
    ),
  );

  AuthManager().initialize(navigatorKey);
}

// --------------------------------------------------
// MY APP
// --------------------------------------------------

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({
    super.key,
    required this.initialScreen,
  });

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
                            valueColor:
                            AlwaysStoppedAnimation<Color>(
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

      home: SplashEntryTransition(
        child: initialScreen,
      ),
    );
  }
}

// --------------------------------------------------
// SPLASH ENTRY TRANSITION
// --------------------------------------------------

class SplashEntryTransition extends StatefulWidget {
  final Widget child;

  const SplashEntryTransition({
    super.key,
    required this.child,
  });

  @override
  State<SplashEntryTransition> createState() =>
      _SplashEntryTransitionState();
}

class _SplashEntryTransitionState
    extends State<SplashEntryTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _loginFade;
  late final Animation<double> _loginScale;
  late final Animation<Offset> _loginSlide;

  bool get isHomeScreen => widget.child is HomeScreen;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    // LOGIN ENTRANCE ANIMATION.
    _loginFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        0.40,
        curve: Curves.easeOutCubic,
      ),
    );

    _loginScale = Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(_loginFade);

    _loginSlide = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(_loginFade);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    // --------------------------------------------------
    // EXPIRED / MISSING TOKEN:
    // SPLASH -> LOGIN
    // --------------------------------------------------

    if (!isHomeScreen) {
      return FadeTransition(
        opacity: _loginFade,
        child: SlideTransition(
          position: _loginSlide,
          child: ScaleTransition(
            scale: _loginScale,
            child: widget.child,
          ),
        ),
      );
    }

    // --------------------------------------------------
    // VALID TOKEN:
    // SPLASH -> HOME WITH PURPLE WAVE
    // --------------------------------------------------

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress =
        Curves.easeInOutCubic.transform(
          _controller.value,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            // White splash background.
            const ColoredBox(
              color: Colors.white,
            ),

            // Home screen revealed by the wave.
            ClipPath(
              clipper: _SplashWaveClipper(
                progress: progress,
              ),
              child: child,
            ),

            // Purple glowing wave and ring.
            IgnorePointer(
              child: CustomPaint(
                painter: _SplashWavePainter(
                  progress: progress,
                  color: AppColors.primaryPurple,
                ),
                size: Size.infinite,
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// --------------------------------------------------
// SPLASH TO HOME WAVE CLIPPER
// --------------------------------------------------

class _SplashWaveClipper extends CustomClipper<Path> {
  final double progress;

  const _SplashWaveClipper({
    required this.progress,
  });

  double _waveY(double x, Size size) {
    final amplitude =
        38 * math.sin(math.pi * progress);

    final wave = math.sin(
      (x / size.width * math.pi * 2) +
          (progress * math.pi * 2),
    );

    return (
        size.height * progress + amplitude * wave
    ).clamp(0.0, size.height);
  }

  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    for (int i = 60; i >= 0; i--) {
      final x = size.width * i / 60;

      path.lineTo(
        x,
        _waveY(x, size),
      );
    }

    path.close();

    return path;
  }

  @override
  bool shouldReclip(
      covariant _SplashWaveClipper oldClipper,
      ) {
    return oldClipper.progress != progress;
  }
}

// --------------------------------------------------
// PURPLE WAVE + GLOWING RING PAINTER
// --------------------------------------------------

class _SplashWavePainter extends CustomPainter {
  final double progress;
  final Color color;

  const _SplashWavePainter({
    required this.progress,
    required this.color,
  });

  double _waveY(double x, Size size) {
    final amplitude =
        38 * math.sin(math.pi * progress);

    final wave = math.sin(
      (x / size.width * math.pi * 2) +
          (progress * math.pi * 2),
    );

    return (
        size.height * progress + amplitude * wave
    ).clamp(0.0, size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // --------------------------------------------------
    // GLOWING RING
    // --------------------------------------------------

    final ringProgress =
    (progress / 0.38).clamp(0.0, 1.0);

    final ringOpacity =
    (1.0 - progress / 0.48).clamp(0.0, 1.0);

    if (ringOpacity > 0) {
      final center = Offset(
        size.width / 2,
        size.height / 2,
      );

      final radius = math.min(
        size.width * 0.20,
        size.height * 0.13,
      );

      final ringRect = Rect.fromCircle(
        center: center,
        radius: radius,
      );

      // Faint circular track.
      final trackPaint = Paint()
        ..color = color.withOpacity(
          0.10 * ringOpacity,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawCircle(
        center,
        radius,
        trackPaint,
      );

      // Moving purple arc.
      final ringPaint = Paint()
        ..color = color.withOpacity(ringOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          3,
        );

      final sweep = 2 * math.pi * ringProgress;

      canvas.drawArc(
        ringRect,
        -math.pi / 2,
        sweep,
        false,
        ringPaint,
      );

      // Glowing moving endpoint.
      final angle = -math.pi / 2 + sweep;

      final dot = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final glowPaint = Paint()
        ..color = color.withOpacity(
          0.35 * ringOpacity,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          12,
        );

      canvas.drawCircle(
        dot,
        11,
        glowPaint,
      );

      canvas.drawCircle(
        dot,
        4,
        Paint()
          ..color = color.withOpacity(ringOpacity),
      );
    }

    // --------------------------------------------------
    // PURPLE WAVE EDGE
    // --------------------------------------------------

    if (progress <= 0 || progress >= 1) return;

    final path = Path();

    for (int i = 0; i <= 80; i++) {
      final x = size.width * i / 80;
      final y = _waveY(x, size);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final rect = Rect.fromLTWH(
      0,
      size.height * progress - 45,
      size.width,
      90,
    );

    // Outer purple glow.
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.65),
          Colors.deepPurpleAccent.withOpacity(0.9),
          color.withOpacity(0.0),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        12,
      );

    canvas.drawPath(
      path,
      glowPaint,
    );

    // Sharp purple wave edge.
    final edgePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.deepPurpleAccent,
          Color(0xFF7036D9),
          Color(0xFFB58AFF),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      path,
      edgePaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _SplashWavePainter oldDelegate,
      ) {
    return oldDelegate.progress != progress;
  }
}
