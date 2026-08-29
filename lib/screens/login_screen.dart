import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/provider/login_provider.dart';
import 'package:provider/provider.dart';
import '../customs/elevated_button.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 3,
              color: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset("assets/images/sanjivagency.jpeg"),
                    SizedBox(height: 12),
                    Text(
                      "Username",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter your Username",
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 01),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Password",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: "Enter your Password",
                        hintStyle: TextStyle(color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 01.5,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Consumer<LoginProvider>(
                      builder: (context, provider, child) {
                        return CustomElevatedButton(
                          text: provider.isLoading ? "Logging..." : "Login",
                          height: 50,
                          onPressed: () async {
                            if (usernameController.text.isEmpty &&
                                passwordController.text.isEmpty) {
                              ScaffoldSnackBar.show(
                                context,
                                "Username & Password is Required",
                              );
                              return;
                            }
                            if (usernameController.text.isEmpty) {
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
                            final provider = Provider.of<LoginProvider>(
                              context,
                              listen: false,
                            );
                            bool success = await provider.login(
                              username: usernameController.text.trim(),

                              password: passwordController.text.trim(),
                            );
                            if (!context.mounted) return;
                            if (success) {
                              ScaffoldSnackBar.show(
                                context,
                                provider.userData?.message ??
                                    "Login Successfully",
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>   HomeScreen(),
                                ),
                              );
                            }
                            else {
                              ScaffoldSnackBar.show(
                                context,
                                provider.userData?.message ?? "Login Failed",
                              );
                            }
                          },
                          borderRadius: 5,
                          color: AppColors.primaryPurple,
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          icons: Icons.arrow_right_alt_sharp,
                          iconColor: Colors.white,
                          iconSize: 30,
                        );
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}