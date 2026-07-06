import 'dart:async';

import 'package:flutter/material.dart';
import '../shared_preferences/login_token.dart';
import 'home_screen.dart';
import 'login_screen.dart'; // Change to your next screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    });
  }
  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = await AppStorage.isLoggedIn();

    if (!mounted) return;

    final token = await AppStorage.getToken();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
        (token != null && token.isNotEmpty)
            ? const HomeScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Hisabio',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3045D3),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}