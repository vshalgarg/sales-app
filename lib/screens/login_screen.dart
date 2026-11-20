import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/provider/login_provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

import '../customs/elevated_button.dart';
import '../provider/master_provider/permission_provider.dart';
import '../services/saved_login_services.dart';
import 'common/web_view_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool isPasswordVisible = false;
  bool rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _ringAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.18,
        0.62,
        curve: Curves.easeInOut,
      ),
    );

    loadSavedLogin();

    _animationController.forward();
  }

  // Reusable staggered entrance animation.
  Widget _reveal({
    required Widget child,
    required double start,
    required double end,
    Offset beginOffset = const Offset(0, 0.12),
  }) {
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        start,
        end,
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  // Load last saved login credentials.
  Future<void> loadSavedLogin() async {
    try {
      final savedLogin =
      await SavedLoginService.getLastLogin();

      if (!mounted || savedLogin == null) return;

      setState(() {
        usernameController.text =
        savedLogin['username']!;
        passwordController.text =
        savedLogin['password']!;
        rememberMe = true;
      });
    } catch (e) {
      debugPrint('Error loading saved credentials: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Open Terms & Conditions.
  void openTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WebViewScreen(
          title: 'Terms & Conditions',
          assetPath: 'assets/html/terms_and_conditions.html',
        ),
      ),
    );
  }

  // Open Privacy Policy.
  void openPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WebViewScreen(
          title: 'Privacy Policy',
          assetPath: 'assets/html/privacy_policy.html',
        ),
      ),
    );
  }

  // Login functionality.
  Future<void> handleLogin() async {
    if (usernameController.text.trim().isEmpty &&
        passwordController.text.isEmpty) {
      ScaffoldSnackBar.show(
        context,
        "Username & Password is Required",
      );
      return;
    }

    if (usernameController.text.trim().isEmpty) {
      ScaffoldSnackBar.show(
        context,
        "UserName is Required",
      );
      return;
    }

    if (passwordController.text.isEmpty) {
      ScaffoldSnackBar.show(
        context,
        "Password is Required",
      );
      return;
    }

    final loginProvider = Provider.of<LoginProvider>(
      context,
      listen: false,
    );

    final username = usernameController.text.trim();
    final password = passwordController.text;

    bool success = await loginProvider.login(
      username: username,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      // Save credentials only when Remember Me is selected.
      if (rememberMe) {
        try {
          await SavedLoginService.saveLogin(
            username: username,
            password: password,
          );
        } catch (e) {
          debugPrint('Error saving credentials: $e');
        }
      }

      // Notify device/browser to save credentials.
      TextInput.finishAutofillContext(
        shouldSave: true,
      );

      final permissionProvider =
      context.read<PermissionProvider>();

      final token = loginProvider.userData?.token;

      if (token == null || token.isEmpty || JwtDecoder.isExpired(token)) {
        ScaffoldSnackBar.show(context, "Invalid login token");
        return;
      }

      final decodedToken = JwtDecoder.decode(token);
      final permissions = decodedToken['permissions'];

      permissionProvider.setPermissions(
        permissions is List ? permissions : [],
      );

      if (!mounted) return;

      // ScaffoldSnackBar.show(
      //   context,
      //   loginProvider.userData?.message ??
      //       "Login Successfully",
      // );



      Navigator.pushReplacement(
        context,
        PageRouteBuilder<void>(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 1200),
          reverseTransitionDuration: const Duration(milliseconds: 500),

          pageBuilder: (context, animation, secondaryAnimation) {
            return const HomeScreen();
          },

          transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
              ) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final progress = Curves.easeInOutCubic.transform(
                  animation.value,
                );

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Reveal the home screen behind a moving wave.
                    ClipPath(
                      clipper: _PurpleWaveClipper(
                        progress: progress,
                      ),
                      child: child,
                    ),

                    // Glowing purple wave edge.
                    IgnorePointer(
                      child: CustomPaint(
                        painter: _PurpleWaveEdgePainter(
                          progress: progress,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      );
    } else {
      // Do not save unsuccessful login credentials.
      TextInput.finishAutofillContext(
        shouldSave: false,
      );

      ScaffoldSnackBar.show(
        context,
        loginProvider.userData?.message ??
            "Login Failed",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 480,
            ),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _animationController,
                curve: const Interval(
                  0.0,
                  0.25,
                  curve: Curves.easeOut,
                ),
              ),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.97,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(
                      0.0,
                      0.30,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
                child: Card(
                  elevation: 3,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        // LOGO WITH PURPLE RING ANIMATION.
                        Center(
                          child: SizedBox(
                            height: 145,
                            width: 180,
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                final logoProgress =
                                Curves.easeOutBack.transform(
                                  ((_animationController.value -
                                      0.18) /
                                      0.27)
                                      .clamp(0.0, 1.0),
                                );

                                final logoOpacity =
                                ((_animationController.value -
                                    0.18) /
                                    0.22)
                                    .clamp(0.0, 1.0);

                                return Stack(
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Original Sanjeev Agency logo.
                                    Opacity(
                                      opacity: logoOpacity,
                                      child: Transform.scale(
                                        scale: 0.65 +
                                            (0.35 * logoProgress),
                                        child: Image.asset(
                                          "assets/images/sanjivagency.jpeg",
                                          height: 130,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),

                                    // Animated ring drawn ABOVE the logo.
                                    CustomPaint(
                                      size: const Size(145, 145),
                                      painter: _LogoRingPainter(
                                        progress:
                                        _ringAnimation.value,
                                        color:
                                        AppColors.primaryPurple,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // USERNAME AND PASSWORD.
                        _reveal(
                          start: 0.48,
                          end: 0.70,
                          child: AutofillGroup(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Username",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                TextField(
                                  controller: usernameController,
                                  keyboardType:
                                  TextInputType.emailAddress,
                                  textInputAction:
                                  TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.username,
                                  ],
                                  decoration: InputDecoration(
                                    border:
                                    const OutlineInputBorder(),
                                    hintText:
                                    "Enter your Username",
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    enabledBorder:
                                    OutlineInputBorder(
                                      borderSide:
                                      const BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(5),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                const Text(
                                  "Password",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                TextField(
                                  controller: passwordController,
                                  obscureText:
                                  !isPasswordVisible,
                                  textInputAction:
                                  TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.password,
                                  ],
                                  onSubmitted: (_) {
                                    handleLogin();
                                  },
                                  decoration: InputDecoration(
                                    hintText:
                                    "Enter your Password",
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isPasswordVisible =
                                          !isPasswordVisible;
                                        });
                                      },
                                    ),
                                    border:
                                    const OutlineInputBorder(),
                                    enabledBorder:
                                    OutlineInputBorder(
                                      borderSide:
                                      const BorderSide(
                                        color: Colors.grey,
                                        width: 1.5,
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // REMEMBER ME.
                        _reveal(
                          start: 0.62,
                          end: 0.82,
                          child: Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                activeColor:
                                AppColors.primaryPurple,
                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value ?? false;
                                  });
                                },
                              ),
                              const Text(
                                'Remember Me',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // LOGIN BUTTON.
                        _reveal(
                          start: 0.68,
                          end: 0.88,
                          child: Consumer<LoginProvider>(
                            builder: (context, provider, child) {
                              return CustomElevatedButton(
                                text: provider.isLoading
                                    ? "Logging..."
                                    : "Login",
                                height: 50,
                                onPressed: provider.isLoading
                                    ? null
                                    : handleLogin,
                                borderRadius: 5,
                                color: AppColors.primaryPurple,
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                icons:
                                Icons.arrow_right_alt_sharp,
                                iconColor: Colors.white,
                                iconSize: 30,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        // TERMS AND PRIVACY POLICY.
                        _reveal(
                          start: 0.82,
                          end: 1.0,
                          child: Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment:
                              WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  "By continuing, you agree to our ",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),

                                GestureDetector(
                                  onTap:
                                  openTermsAndConditions,
                                  child: const Text(
                                    "Terms & Conditions",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                      fontWeight:
                                      FontWeight.bold,
                                      decoration:
                                      TextDecoration.underline,
                                    ),
                                  ),
                                ),

                                const Text(
                                  " and ",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),

                                GestureDetector(
                                  onTap: openPrivacyPolicy,
                                  child: const Text(
                                    "Privacy Policy",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                      fontWeight:
                                      FontWeight.bold,
                                      decoration:
                                      TextDecoration.underline,
                                    ),
                                  ),
                                ),

                                const Text(
                                  ".",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// PURPLE CIRCULAR LOGO RING
// --------------------------------------------------

class _LogoRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LogoRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    // Increased radius so the ring sits around the logo.
    final radius = size.width * 0.48;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    // Fade the ring at the end of its animation.
    final opacity = progress > 0.78
        ? (1 - progress) / 0.22
        : 1.0;

    // Faint circular track.
    final trackPaint = Paint()
      ..color = color.withOpacity(0.10 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      center,
      radius,
      trackPaint,
    );

    // Moving purple arc.
    final startAngle = -math.pi / 2 +
        (2 * math.pi * progress);

    const sweepAngle = 1.15;

    final arcPaint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        1.5,
      );

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // Glowing moving endpoint.
    final dotAngle = startAngle + sweepAngle;

    final dotPosition = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );

    final glowPaint = Paint()
      ..color = Colors.deepPurpleAccent.withOpacity(
        0.35 * opacity,
      )
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        9,
      );

    final dotPaint = Paint()
      ..color = Colors.deepPurpleAccent.withOpacity(opacity);

    canvas.drawCircle(dotPosition, 9, glowPaint);
    canvas.drawCircle(dotPosition, 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _LogoRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _PurpleWaveClipper extends CustomClipper<Path> {
  final double progress;

  const _PurpleWaveClipper({
    required this.progress,
  });

  Path _createWavePath(Size size) {
    final path = Path();

    final waveHeight = 42.0 *
        math.sin(math.pi * progress);

    final baseY = size.height * progress;

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    // Draw the moving wave from right to left.
    for (int i = 60; i >= 0; i--) {
      final x = size.width * i / 60;

      final wave = math.sin(
        (x / size.width * math.pi * 2) +
            (progress * math.pi * 2),
      ) *
          waveHeight;

      final y = (baseY + wave).clamp(
        0.0,
        size.height,
      );

      path.lineTo(x, y);
    }

    path.close();
    return path;
  }

  @override
  Path getClip(Size size) {
    return _createWavePath(size);
  }

  @override
  bool shouldReclip(
      covariant _PurpleWaveClipper oldClipper,
      ) {
    return oldClipper.progress != progress;
  }
}

class _PurpleWaveEdgePainter extends CustomPainter {
  final double progress;

  const _PurpleWaveEdgePainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final waveHeight = 42.0 *
        math.sin(math.pi * progress);

    final baseY = size.height * progress;

    final path = Path();

    for (int i = 0; i <= 60; i++) {
      final x = size.width * i / 60;

      final wave = math.sin(
        (x / size.width * math.pi * 2) +
            (progress * math.pi * 2),
      ) *
          waveHeight;

      final y = (baseY + wave).clamp(
        0.0,
        size.height,
      );

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final rect = Rect.fromLTWH(
      0,
      baseY - 45,
      size.width,
      90,
    );

    // Outer purple glow.
    final glowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x009B5DE5),
          Color(0xAA9B5DE5),
          Color(0xFF6C35D9),
          Color(0x009B5DE5),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        12,
      );

    canvas.drawPath(path, glowPaint);

    // Sharp glowing edge.
    final edgePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFB98AFF),
          Color(0xFF7036E8),
          Color(0xFFD7B5FF),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, edgePaint);
  }

  @override
  bool shouldRepaint(
      covariant _PurpleWaveEdgePainter oldDelegate,
      ) {
    return oldDelegate.progress != progress;
  }
}
