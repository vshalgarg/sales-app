import 'package:flutter/material.dart';

import '../../constants/colors_used.dart';
import '../../customs/elevated_button.dart';

class UpdateUserPassword extends StatefulWidget {
  final String name;
  final Future<void> Function() onCancel;
  final Future<void> Function() onUpdate;
  final TextEditingController? newPasswordController;
  final TextEditingController? confirmPasswordController;

  const UpdateUserPassword({
    super.key,
    required this.onCancel,
    required this.name,
    required this.onUpdate,
    this.confirmPasswordController,
    this.newPasswordController,
  });

  @override
  State<UpdateUserPassword> createState() => _UpdateUserPasswordState();
}

class _UpdateUserPasswordState extends State<UpdateUserPassword> {
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  String? newPasswordError;
  String? confirmPasswordError;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 35),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 35,
                left: 15,
                right: 15,
                bottom: 15,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "Change Password",
                        style: TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight:FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(

                      initialValue: widget.name,
                      enabled: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Email",
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    SizedBox(height:10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: widget.newPasswordController,
                          obscureText: !isPasswordVisible,
                          onChanged: (value) {
                            setState(() {
                              if (value.trim().isEmpty) {
                                newPasswordError = "New Password is required";
                              } else {
                                newPasswordError = null;
                              }

                              final confirm =
                                  widget.confirmPasswordController?.text.trim() ?? "";

                              if (confirm.isNotEmpty && value.trim() != confirm) {
                                confirmPasswordError = "Passwords do not match";
                              } else if (confirm.isNotEmpty) {
                                confirmPasswordError = null;
                              }
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "New Password * ",
                            errorText: newPasswordError,
                            hintStyle: TextStyle(
                                color:Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),

                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: widget.confirmPasswordController,
                          obscureText: !isConfirmPasswordVisible,
                          onChanged: (value) {
                            final password =
                                widget.newPasswordController?.text.trim() ?? "";
                            final confirmPassword = value.trim();

                            setState(() {
                              if (confirmPassword.isEmpty) {
                                confirmPasswordError =
                                "Confirm Password is required";
                              } else if (password != confirmPassword) {
                                confirmPasswordError =
                                "Passwords do not match";
                              } else {
                                confirmPasswordError = null;
                              }
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Confirm Password * ",
                            errorText: confirmPasswordError,
                            hintStyle: TextStyle(
                                color:Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),

                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isConfirmPasswordVisible = !isConfirmPasswordVisible;
                                });
                              },
                              icon: Icon(
                                isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: CustomElevatedButton(
                                text: "Cancel",
                                onPressed: widget.onCancel,
                                borderRadius: 5,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: CustomElevatedButton(
                                color: AppColors.primaryPurple,
                                text: "Save",
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  final password =
                                      widget.newPasswordController?.text.trim() ?? "";

                                  final confirmPassword =
                                      widget.confirmPasswordController?.text.trim() ?? "";

                                  setState(() {
                                    newPasswordError = password.isEmpty
                                        ? "New Password is required"
                                        : null;

                                    confirmPasswordError = confirmPassword.isEmpty
                                        ? "Confirm Password is required"
                                        : password != confirmPassword
                                        ? "Passwords do not match"
                                        : null;
                                  });

                                  if (newPasswordError != null ||
                                      confirmPasswordError != null) {
                                    return;
                                  }

                                  await widget.onUpdate();
                                },
                                borderRadius: 5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF3F0FF),
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: const Icon(
                Icons.person_outline_outlined,
                color: AppColors.primaryPurple,
                size: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
