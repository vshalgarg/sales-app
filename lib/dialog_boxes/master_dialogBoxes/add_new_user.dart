import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/elevated_button.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:provider/provider.dart';

import '../../provider/get_user_provider.dart';
import '../../provider/user_all_provider.dart';

class AddNewUser extends StatefulWidget {
  const AddNewUser({super.key});

  @override
  State<AddNewUser> createState() => _AddNewUserState();
}

class _AddNewUserState extends State<AddNewUser> {
  final passwordController = TextEditingController();
  final userController = TextEditingController();
  bool isPasswordVisible = false;
  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(backgroundColor: AppColors.bodyFillColor,
      title: Text("Add New User"),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
        child: Consumer<UserProvider>(
          builder: (context, provider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: userController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "User Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),borderSide:BorderSide.none
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),borderSide: BorderSide.none
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
                DropdownButtonFormField<String>(
                  initialValue: selectedCity,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Role",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),borderSide:BorderSide.none
                    ),
                  ),
                  items: ["ADMIN", "AGENT"]
                      .map(
                        (role) =>
                            DropdownMenuItem(value: role, child: Text(role)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity=value;
                    });
                  },
                ),
                SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomElevatedButton(
                      text: "cancel",
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      borderRadius: 5,
                    ),
                    SizedBox(width: 10),
                    provider.isLoading
                        ? const CircularProgressIndicator()
                        : CustomElevatedButton(
                            color: AppColors.primaryPurple,
                            text: "Save",
                            textStyle: TextStyle(color: Colors.white),
                            onPressed: () async {
                              final body = {
                                "username": userController.text,
                                "password": passwordController.text,
                                "roles": [selectedCity],
                              };

                              await provider.addNewUser(body);
                              if (!context.mounted) return;

                              if (provider.errorMessage != null) {
                                ScaffoldSnackBar.show(
                                  context,
                                  provider.errorMessage!,
                                );
                              } else {
                                ScaffoldSnackBar.show(
                                  context,
                                  provider.addUserResponse?.status ??
                                      "User Added successfully",
                                );
                                await context.read<GetUsersProvider>().getUsers();
                                if (!context.mounted) return;
                                Navigator.pop(context);
                              }
                            },
                            borderRadius: 5,
                          ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
