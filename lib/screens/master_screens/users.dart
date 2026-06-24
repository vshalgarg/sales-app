import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hisabio/customs/containers/master_containers/users_container.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';
import '../../dialog_boxes/master_dialogBoxes/add_new_user.dart';
import '../../dialog_boxes/master_dialogBoxes/delete_custom_dialog.dart';
import '../../dialog_boxes/master_dialogBoxes/update_user_password.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../provider/get_user_provider.dart';
import '../../provider/user_all_provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final userSearchController = TextEditingController();
  final confirmPassword = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<GetUsersProvider>().getUsers();
    });
  }

  @override
  void dispose() {
    userSearchController.dispose();
    _debounce?.cancel();
    confirmPassword.dispose();
    super.dispose();
  }

  void clear() {
    confirmPassword.clear();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<GetUsersProvider>();
    final searchProvider = context.watch<UserProvider>();
    final isSearching = searchProvider.searchUsers != null;
    if (userProvider.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (userProvider.error != null) {
      return Scaffold(body: Center(child: Text(userProvider.error!)));
    }
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: "Users",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SearchBar(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                controller: userSearchController,
                elevation: WidgetStatePropertyAll(2),
                hintText: "Search User...",
                leading: Icon(Icons.search_outlined, size: 30),
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) {
                    _debounce!.cancel();
                  }

                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    if (value.trim().isNotEmpty) {
                      context.read<UserProvider>().searchUsersByKeyword(value);
                    } else {
                      context.read<UserProvider>().clearSearch();
                    }
                  });
                },
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return SizedBox(height: 8);
                },
                itemCount: isSearching
                    ? searchProvider.searchUsers!.length
                    : userProvider.users!.users!.length,
                itemBuilder: (context, index) {
                  if (isSearching) {
                    final user = searchProvider.searchUsers![index];
                    return UserContainer(
                      name: user['username'] ?? '',
                      trashIconTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => CustomDeleteDialog(
                            dialogBoxName: "Delete User",
                            onDelete: () async {
                              await context.read<UserProvider>().deleteUser(
                                user['id']!.toInt(),
                              );
                              if (!context.mounted) return;

                              final provider = context.read<UserProvider>();

                              if (provider.errorMessage == null) {
                                await context
                                    .read<GetUsersProvider>()
                                    .getUsers();

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  clear();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        provider.deleteUserResponse?.message ??
                                            "User deleted successfully",
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            name: user['userName'],
                          ),
                        );
                      },
                      editIconTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => UpdateUserPassword(
                            confirmPasswordController: confirmPassword,
                            name: user['userName'],
                            onUpdate: () async {
                              await context.read<UserProvider>().updatePassword(
                                body: {
                                  "userId": user['id'],
                                  "newPassword": confirmPassword.text,
                                },
                              );

                              if (!context.mounted) return;

                              final provider = context.read<UserProvider>();

                              if (provider.errorMessage == null) {
                                Navigator.pop(context);
                                clear();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      provider
                                              .updatePasswordResponse
                                              ?.message ??
                                          "Password updated successfully",
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  }
                  final user = userProvider.users!.users![index];
                  return UserContainer(
                    name: user.username ?? '',
                    trashIconTap: () {
                      ExitConfirmationDialog.show(
                        context,
                        saveButtonText: "Delete",
                        onClose: () {
                          Navigator.pop(context);
                        },
                        onDiscard: () {
                          Navigator.pop(context);
                        },
                        bodyText:
                            "Are you sure you want to permanently delete ${user.username}? This action cannot be undo.",
                        onSave: () async {
                          await context.read<UserProvider>().deleteUser(
                            user.id!.toInt(),
                          );
                          if (!context.mounted) return;

                          final provider = context.read<UserProvider>();

                          if (provider.errorMessage == null) {
                            await context.read<GetUsersProvider>().getUsers();

                            if (context.mounted) {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.deleteUserResponse?.message ??
                                        "User deleted successfully",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                    editIconTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => UpdateUserPassword(
                          confirmPasswordController: confirmPassword,
                          name: user.username!,
                          onUpdate: () async {
                            await context.read<UserProvider>().updatePassword(
                              body: {
                                "userId": user.id,
                                "newPassword": confirmPassword.text,
                              },
                            );

                            if (!context.mounted) return;

                            final provider = context.read<UserProvider>();

                            if (provider.errorMessage == null) {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.updatePasswordResponse?.message ??
                                        "Password updated successfully",
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () {
          showDialog(context: context, builder: (context) => AddNewUser());
        },
        backgroundColor: AppColors.primaryPurple,
        child: Icon(Iconsax.add, color: Colors.white, size: 40),
      ),
    );
  }
}
