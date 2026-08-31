import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../customs/containers/role_dropdown.dart';
import '../../customs/elevated_button.dart';
import '../../model_classes/user/add_user_request.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/master_provider/user_provider.dart';

class AddUserDialog extends StatefulWidget {
  final BuildContext scaffoldContext;
  const AddUserDialog({
    super.key,
    required this.scaffoldContext,
  });

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool isPasswordVisible = false;

  String? selectedRole = "Agent";
  String? usernameError;
  String? passwordError;
  String? roleError;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Add New User",
                      style: TextStyle(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w200,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: usernameController,
                      onChanged: (_) {
                        if (usernameError != null) {
                          setState(() {
                            usernameError = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Username * ",
                        errorText: usernameError,
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: usernameError != null
                                ? Colors.red
                                : Colors.grey,
                            width: usernameError != null ? 1 : 0.5,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: usernameError != null
                                ? Colors.red
                                : Colors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      onChanged: (_) {
                        if (passwordError != null) {
                          setState(() {
                            passwordError = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Password *",
                        errorText: passwordError,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: passwordError != null
                                ? Colors.red
                                : Colors.grey,
                            width: passwordError != null ? 1 : 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: passwordError != null
                                ? Colors.red
                                : Colors.grey,
                            width: 1,
                          ),
                        ),
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
                      ),
                    ),

                    const SizedBox(height: 12),

                    RoleDropdown(
                      value: selectedRole,
                      errorText: roleError,
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                          roleError = null;
                        });
                      },
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: CustomElevatedButton(
                            text: "Cancel",
                            borderRadius: 5,
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: CustomElevatedButton(
                            color: AppColors.primaryPurple,
                            text: "Save",
                            textStyle: const TextStyle(color: Colors.white),
                            borderRadius: 5,
                            onPressed: () async {
                              final username = usernameController.text.trim();
                              final password = passwordController.text.trim();

                              setState(() {
                                usernameError = username.isEmpty
                                    ? "Username is required"
                                    : null;

                                passwordError = password.isEmpty
                                    ? "Password is required"
                                    : null;

                                roleError = null;
                              });

                              if (usernameError != null ||
                                  passwordError != null) {
                                return;
                              }
                              final request = AddUserRequest(
                                username: username,
                                password: password,
                                roles: [selectedRole!],
                              );

                              final provider = context.read<UserProvider>();

                              final success = await provider.addUser(request);

                              if (!context.mounted) return;

                              if (success) {
                                final message = provider.successMessage;

                                Navigator.pop(context);

                                if (!context.mounted) return;

                                if (message != null &&
                                    message.trim().isNotEmpty) {
                                  ScaffoldSnackBar.show(
                                    widget.scaffoldContext,
                                    message,
                                  );
                                }

                                return;
                              }

                              final errorMessage = provider.errorMessage;

                              Navigator.pop(context);

                              if (!widget.scaffoldContext.mounted) return;

                              if (errorMessage != null &&
                                  errorMessage.trim().isNotEmpty) {
                                ScaffoldSnackBar.show(
                                  widget.scaffoldContext,
                                  errorMessage,
                                );
                              }

                              return;
                            },
                          ),
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
              child: Icon(
                Iconsax.add,
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
