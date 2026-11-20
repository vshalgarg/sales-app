import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hisabio/constants/app_spacing.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';
import '../../customs/card_entrance_examination.dart';
import '../../customs/containers/master_containers/users_container.dart';
import '../../dialog_boxes/master_dialogBoxes/add_new_user.dart';
import '../../dialog_boxes/master_dialogBoxes/edit_user.dart';
import '../../dialog_boxes/master_dialogBoxes/update_user_password.dart';
import '../../model_classes/user/user.dart';
import '../../pagination/user_pagination_widget.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/master_provider/permission_provider.dart';
import '../../provider/master_provider/user_provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController userSearchController = TextEditingController();

  final TextEditingController newPassword = TextEditingController();

  final TextEditingController confirmPassword = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    final userProvider = context.read<UserProvider>();
    final permissionProvider = context.read<PermissionProvider>();

    Future.microtask(() {
      if (permissionProvider.canView('USER')) {
        userProvider.fetchUsers();
      }
    });
  }

  @override
  void dispose() {
    userSearchController.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void clear() {
    userSearchController.clear();
    newPassword.clear();
    confirmPassword.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    final permissionProvider = context.watch<PermissionProvider>();

    final canView = permissionProvider.canView('USER');
    final canCreate = permissionProvider.canCreate('USER');
    final canUpdate = permissionProvider.canUpdate('USER');
    final canDelete = permissionProvider.canDelete('USER');

    final canAccess = canView || canCreate;
    if (!canAccess) {
      return const Scaffold(
        body: Center(
          child: Text(
            'You do not have permission to access Users.',
          ),
        ),
      );
    }
    if (provider.errorMessage != null) {
      return Scaffold(body: Center(child: Text(provider.errorMessage!)));
    }

    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,

      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: "Users",
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),

      body: Padding(
        padding: AppSpacing.screen,

        child: Column(
            children: [
              if (canView) ...[
                Container(
                  height: 40,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: SearchBar(
                    controller: userSearchController,

                    elevation: const WidgetStatePropertyAll(2),

                    backgroundColor: const WidgetStatePropertyAll(Colors.white),

                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),

                    leading: const Icon(Icons.search_outlined, size: 30),

                    hintText: "Search User...",

                    trailing: [
                      if (userSearchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            userSearchController.clear();

                            await context.read<UserProvider>().fetchUsers();

                            if (!mounted) return;

                            setState(() {});
                          },
                        ),
                    ],

                    onChanged: (value) {
                      setState(() {});

                      if (_debounce?.isActive ?? false) {
                        _debounce!.cancel();
                      }

                      _debounce = Timer(
                        const Duration(milliseconds: 500),
                            () async {
                          if (!mounted) return;

                          final provider = context.read<UserProvider>();

                          if (value.trim().isEmpty) {
                            await provider.fetchUsers();
                          } else {
                            await provider.searchUsers(value.trim());
                          }
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: LocalPaginationWidget<User>(
                      items: provider.users,
                      pageSize: 10,

                      refresh: () async {
                        userSearchController.clear();

                        await provider.fetchUsers();
                      },

                      itemBuilder: (context, user) {
                        return CardEntranceAnimation(
                          key: ValueKey('users-card-${user.id}'),
                          delay: Duration(milliseconds: (provider.users.indexOf(user).clamp(0, 5)) * 65),
                          child: UserContainer(
                            role: user.role,
                            name: user.username ?? "",
                            trashIconTap: canDelete ? () {
                              ExitConfirmationDialog.show(
                                context,
                                isDelete: true,
                                body: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text:
                                            "Are you sure you want to permanently delete ",
                                          ),
                                          TextSpan(
                                            text: user.username,
                                            style: const TextStyle(
                                              color: AppColors.orangeColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(text: "?"),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      "This action cannot be undone.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                saveButtonText: "Delete",
                                discardButtonText: "Cancel",

                                onDiscard: () {
                                  Navigator.pop(context);
                                },

                                onSave: () async {
                                  Navigator.pop(context);
                                  final userProvider = context.read<UserProvider>();

                                  final success = await userProvider.deleteUser(
                                    user.id!,
                                  );

                                  if (!context.mounted) return;

                                  if (success) {
                                    ScaffoldSnackBar.show(
                                      context,
                                      "User deleted successfully",
                                    );
                                  } else {
                                    ScaffoldSnackBar.show(
                                      context,
                                      provider.errorMessage ?? "Failed to delete user",
                                    );
                                  }
                                },
                              );
                            } : null,

                            changePasswordTap: canUpdate ? () {
                              showDialog(
                                context: context,

                                builder: (_) => UpdateUserPassword(
                                  name: user.username ?? "",

                                  newPasswordController: newPassword,

                                  confirmPasswordController: confirmPassword,

                                  onCancel: () async {
                                    clear();
                                    Navigator.pop(context);
                                  },

                                  onUpdate: () async {
                                    if (newPassword.text.trim().isEmpty ||
                                        confirmPassword.text.trim().isEmpty) {
                                      ScaffoldSnackBar.show(
                                        context,
                                        "Please enter password",
                                      );
                                      return;
                                    }

                                    if (newPassword.text.trim() !=
                                        confirmPassword.text.trim()) {
                                      ScaffoldSnackBar.show(
                                        context,
                                        "Password and Confirm Password do not match",
                                      );
                                      return;
                                    }

                                    final userProvider = context.read<UserProvider>();

                                    final success = await userProvider.updatePassword(
                                      body: {
                                        "userId": user.id,
                                        "newPassword": newPassword.text.trim(),
                                      },
                                    );

                                    if (!context.mounted) return;

                                    if (success) {
                                      Navigator.pop(context);

                                      clear();

                                      ScaffoldSnackBar.show(
                                        context,
                                        "Password updated successfully",
                                      );
                                    } else {
                                      ScaffoldSnackBar.show(
                                        context,
                                        provider.errorMessage ??
                                            "Failed to update password",
                                      );
                                    }
                                  },
                                ),
                              );
                            } : null,

                            editIconTap: canUpdate ? () {
                              showDialog(
                                context: context,
                                builder: (_) => EditUserDialog(
                                  userId: user.id!,
                                  username: user.username ?? '',
                                ),
                              );
                            } : null,
                          ),
                        );
                      },
                    ),
                  ),
                )
              ]
              else ...[
                const Expanded(
                  child: Center(
                    child: Text(
                      'You can add users, but cannot view user records.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ]
        ),
      ),

      floatingActionButton: canCreate
          ? FloatingActionButton(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(Iconsax.add, color: Colors.white, size: 40),
        onPressed: () async {
          final message = await showDialog<String>(
            context: context,
            builder: (_) => AddUserDialog(
              scaffoldContext: context,
            ),
          );

          if (!mounted) return;

          if (message != null && message.trim().isNotEmpty) {
            ScaffoldSnackBar.show(
              context,
              message,
            );
          }
        },
      ) : null,
    );
  }
}
