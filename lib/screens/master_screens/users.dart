import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';
import '../../customs/containers/master_containers/users_container.dart';
import '../../dialog_boxes/master_dialogBoxes/add_new_user.dart';
import '../../dialog_boxes/master_dialogBoxes/update_user_password.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/user_provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController userSearchController =
  TextEditingController();

  final TextEditingController newPassword =
  TextEditingController();

  final TextEditingController confirmPassword =
  TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<UserProvider>().fetchUsers();
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

    if (provider.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(provider.errorMessage!),
        ),
      );
    }

    final users = provider.users;

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
            padding: const EdgeInsets.all(15),

            child: Column(
              children: [

              Container(
              height: 40,
              width: double.infinity,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),

              child: SearchBar(
                controller: userSearchController,

                elevation:
                const WidgetStatePropertyAll(2),

                backgroundColor:
                const WidgetStatePropertyAll(
                  Colors.white,
                ),

                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(5),
                  ),
                ),

                leading: const Icon(
                  Icons.search_outlined,
                  size: 30,
                ),

                hintText: "Search User...",

                trailing: [
                  if (userSearchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        userSearchController.clear();

                        await context
                            .read<UserProvider>()
                            .fetchUsers();

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

            const SizedBox(height: 15),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  userSearchController.clear();
                  await context.read<UserProvider>().fetchUsers();
                },
                child: users.isEmpty
                    ? const Center(
                  child: Text(
                    "No User Found",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                )
                    : ListView.separated(
                  separatorBuilder:
                      (_, __) =>
                  const SizedBox(height: 8),

                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return UserContainer(
                      name: user.username ?? "",

                      trashIconTap: () {
                        ExitConfirmationDialog.show(
                          context,
                          saveButtonText: "Yes",
                          discardButtonText: "No",

                          bodyText:
                          "Are you sure you want to permanently delete ${user.username}? This action cannot be undone.",

                          onDiscard: () {
                            Navigator.pop(context);
                          },

                          onSave: () async {
                            Navigator.pop(context);
                            final success = await context
                                .read<UserProvider>()
                                .deleteUser(user.id!);

                            if (!context.mounted) return;

                            if (success) {
                           //   Navigator.pop(context,true);

                              ScaffoldSnackBar.show(
                                context,
                                "User deleted successfully",
                              );
                            } else {
                              ScaffoldSnackBar.show(
                                context,
                                provider.errorMessage ??
                                    "Failed to delete user",
                              );
                            }
                          },
                        );
                      },

                      editIconTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => UpdateUserPassword(
                            name: user.username ?? "",

                            newPasswordController: newPassword,

                            confirmPasswordController:
                            confirmPassword,

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

                              final success = await context
                                  .read<UserProvider>()
                                  .updatePassword(
                                body: {
                                  "userId": user.id,
                                  "newPassword":
                                  newPassword.text.trim(),
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
                      },
                    );
                  },
                ),
            ),
            )
              ],
            ),
        ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(
          Iconsax.add,
          color: Colors.white,
          size: 40,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddUserDialog(),
          );
        },
      ),
    );
  }
}







// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:hisabio/customs/containers/master_containers/users_container.dart';
// import 'package:hisabio/pop_ups/scafold_type.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors_used.dart';
// import '../../customs/app_bar.dart';
// import '../../dialog_boxes/master_dialogBoxes/add_new_user.dart';
// import '../../dialog_boxes/master_dialogBoxes/update_user_password.dart';
// import '../../pop_ups/general_closing_popup.dart';
// import '../../provider/get_user_provider.dart';
// import '../../provider/user_all_provider.dart';
//
// class UsersScreen extends StatefulWidget {
//   const UsersScreen({super.key});
//
//   @override
//   State<UsersScreen> createState() => _UsersScreenState();
// }
//
// class _UsersScreenState extends State<UsersScreen> {
//   final userSearchController = TextEditingController();
//   final confirmPassword = TextEditingController();
//   final newPassword = TextEditingController();
//   Timer? _debounce;
//
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       context.read<UserProvider>().clearSearch();
//       context.read<GetUsersProvider>().getUsers();
//     });
//   }
//
//   @override
//   void dispose() {
//     userSearchController.dispose();
//     _debounce?.cancel();
//     confirmPassword.dispose();
//     super.dispose();
//   }
//
//   void clear() {
//     confirmPassword.clear();
//     newPassword.clear();
//     userSearchController.clear();
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final userProvider = context.watch<GetUsersProvider>();
//     final searchProvider = context.watch<UserProvider>();
//     final isSearching = searchProvider.searchUsers != null;
//     final users = isSearching
//         ? searchProvider.searchUsers ?? []
//         : userProvider.users?.users ?? [];
//     if (userProvider.isLoading) {
//       return Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     if (userProvider.error != null) {
//       return Scaffold(body: Center(child: Text(userProvider.error!)));
//     }
//     return Scaffold(
//       backgroundColor: AppColors.bodyFillColor,
//       appBar: CustomAppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);},
//         ),
//         title: "Users",
//         textStyle: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w600,
//           fontSize: 25,
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: Column(
//           children: [
//             Container(
//               width: double.infinity,
//               height: 40,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: SearchBar(
//                 shape: WidgetStatePropertyAll(
//                   RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                 ),
//                 controller: userSearchController,
//                 elevation: WidgetStatePropertyAll(2),
//                 trailing: [
//                   if (userSearchController.text.isNotEmpty)
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () {
//                         userSearchController.clear();
//                         context.read<UserProvider>().clearSearch();
//                         setState(() {});
//                       },
//                     ),
//                 ],
//                 hintText: "Search User...",
//                 leading: Icon(Icons.search_outlined, size: 30),
//                 backgroundColor: WidgetStatePropertyAll(Colors.white),
//                 onChanged: (value) {
//                   if (_debounce?.isActive ?? false) {
//                     _debounce!.cancel();
//                   }
//
//                   _debounce = Timer(const Duration(milliseconds: 500), () {
//                     if (value.trim().isNotEmpty) {
//                       context.read<UserProvider>().searchUsersByKeyword(value);
//                     } else {
//                       context.read<UserProvider>().clearSearch();
//                     }
//                   });
//                 },
//               ),
//             ),
//             SizedBox(height: 15),
//             Expanded(
//               child: users.isEmpty
//                   ? const Center(
//                       child: Text(
//                         "No User Found",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     )
//                   : ListView.separated(
//                       separatorBuilder: (context, index) {
//                         return SizedBox(height: 8);
//                       },
//                       itemCount: users.length,
//                       itemBuilder: (context, index) {
//                         if (isSearching) {
//                           final user = searchProvider.searchUsers![index];
//                           return UserContainer(
//                             name: (user['username'] ?? user['userName'] ?? "").toString(),
//                             trashIconTap: () {
//                               ExitConfirmationDialog.show(
//                                 context,
//                                 saveButtonText: "Yes",
//                                 discardButtonText: "No",
//                                 onDiscard: () {
//                                   Navigator.pop(context);
//                                 },
//                                 bodyText:
//                                 "Are you sure you want to permanently delete ${user['username']}? This action cannot be undo.",
//                                 onSave: () async {
//
//                                   await context.read<UserProvider>().deleteUser(
//                                     user['id']!.toInt(),
//                                   );
//                                   if (!context.mounted) return;
//
//                                   final provider = context.read<UserProvider>();
//
//                                   if (provider.errorMessage == null) {
//                                       Navigator.pop(context);
//
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             provider
//                                                 .deleteUserResponse
//                                                 ?.message ??
//                                                 "User deleted successfully",
//                                           ),
//                                         ),
//                                       );
//                                       await context
//                                           .read<UserProvider>()
//                                           .searchUsersByKeyword(userSearchController.text);
//                                   }
//                                 },
//                               );
//                             },
//                             editIconTap: () {
//                               showDialog(
//                                 context: context,
//                                 builder: (context) => UpdateUserPassword(
//                                   onCancel: () async {
//                                     clear();
//                                     Navigator.pop(context);
//                                   },
//                                   newPasswordController: newPassword,
//                                   confirmPasswordController: confirmPassword,
//                                   name: (user['username'] ?? user['userName'] ?? "").toString(),
//                                   onUpdate: () async {
//                                     if (newPassword.text.trim() !=
//                                         confirmPassword.text.trim()) {
//                                       ScaffoldMessenger.of(
//                                         context,
//                                       ).showSnackBar(
//                                         const SnackBar(
//                                           content: Text(
//                                             "Password and Confirm Password do not match",
//                                           ),
//                                         ),
//                                       );
//                                       return;
//                                     }
//                                     await context
//                                         .read<UserProvider>()
//                                         .updatePassword(
//                                           body: {
//                                             "userId": user['id'],
//                                             "newPassword": confirmPassword.text,
//                                           },
//                                         );
//
//                                     if (!context.mounted) return;
//
//                                     final provider = context
//                                         .read<UserProvider>();
//
//                                     if (provider.errorMessage == null) {
//                                       Navigator.pop(context);
//                                       clear();
//
//                                       ScaffoldMessenger.of(
//                                         context,
//                                       ).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             provider
//                                                     .updatePasswordResponse
//                                                     ?.message ??
//                                                 "Password updated successfully",
//                                           ),
//                                         ),
//                                       );
//                                     }
//                                   },
//                                 ),
//                               );
//                             },
//                           );
//                         }
//                         final user = userProvider.users!.users![index];
//                         return UserContainer(
//                           name: user.username ?? '',
//                           trashIconTap: () {
//                             ExitConfirmationDialog.show(
//                               context,
//                               saveButtonText: "Yes",
//                               discardButtonText: "No",
//
//                               onDiscard: () {
//                                 Navigator.pop(context);
//                               },
//                               bodyText:
//                                   "Are you sure you want to permanently delete ${user.username}? This action cannot be undo.",
//                               onSave: () async {
//                                  await context.read<UserProvider>().deleteUser(
//                                   user.id!.toInt(),
//                                 );
//
//                                 final provider = context.read<UserProvider>();
//                                 if (provider.errorMessage == null) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                        SnackBar(
//                                          content: Text(
//                                            provider
//                                                    .deleteUserResponse
//                                                    ?.message ??
//                                                "User deleted successfully",
//                                          ),
//                                        ),
//                                      );
//                                   Navigator.pop(context);
//                                   await context
//                                       .read<GetUsersProvider>()
//                                       .getUsers();
//                                    }
//
//                               },
//                             );
//                           },
//                           editIconTap: () {
//                             showDialog(
//                               context: context,
//                               builder: (context) => UpdateUserPassword(
//                                 onCancel: () async {
//                                   clear();
//                                   Navigator.pop(context);
//                                 },
//                                 confirmPasswordController: confirmPassword,
//                                 newPasswordController: newPassword,
//                                 name: user.username!,
//                                 onUpdate: () async {
//                                   if (newPassword.text.trim() !=
//                                       confirmPassword.text.trim()) {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text(
//                                           "Password and Confirm Password do not match",
//                                         ),
//                                       ),
//                                     );
//                                     return;
//                                   }
//                                   if(newPassword.text.isEmpty||confirmPassword.text.isEmpty){
//                                     ScaffoldSnackBar.show(context,"Please fill Password and confirm Password");
//                                     return;
//                                   }
//                                   await context
//                                       .read<UserProvider>()
//                                       .updatePassword(
//                                         body: {
//                                           "userId": user.id,
//                                           "newPassword": confirmPassword.text,
//                                         },
//                                       );
//
//                                   if (!context.mounted) return;
//
//                                   final provider = context.read<UserProvider>();
//
//                                   if (provider.errorMessage == null) {
//                                     Navigator.pop(context);
//
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           provider
//                                                   .updatePasswordResponse
//                                                   ?.message ??
//                                               "Password updated successfully",
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 },
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//         onPressed: () {
//           showDialog(context: context, builder: (context) => AddNewUser());
//         },
//         backgroundColor: AppColors.primaryPurple,
//         child: Icon(Iconsax.add, color: Colors.white, size: 40),
//       ),
//     );
//   }
// }
