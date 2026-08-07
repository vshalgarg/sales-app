import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../customs/dropdown_test.dart';
import '../../customs/elevated_button.dart';
import '../../model_classes/user/add_user_request.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/master_provider/user_provider.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool isPasswordVisible = false;

  String? selectedRole;

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
                      decoration: InputDecoration(
                        labelText: "Username",
                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(5),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(5),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,

                      decoration: InputDecoration(
                        labelText: "Password",
                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(5),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(5),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(5),
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
                      ),
                    ),

                    const SizedBox(height: 12),

                    CustomDropdown(
                      hintText: "Role",
                      initialValue: selectedRole,
                      items: const [
                        "ADMIN",
                        "AGENT",
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
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
                          child: provider.loading
                              ? const Center(
                            child:
                            CircularProgressIndicator(),
                          )
                              : CustomElevatedButton(
                            color:
                            AppColors.primaryPurple,
                            text: "Save",
                            textStyle:
                            const TextStyle(
                              color: Colors.white,
                            ),
                            borderRadius: 5,
                            onPressed: () async {
                              if (usernameController
                                  .text
                                  .trim()
                                  .isEmpty ||
                                  passwordController
                                      .text
                                      .trim()
                                      .isEmpty ||
                                  selectedRole == null) {
                                ScaffoldSnackBar.show(
                                  context,
                                  "Please fill Username, Password & Role",
                                );
                                return;
                              }

                              final request =
                              AddUserRequest(
                                username:
                                usernameController.text
                                    .trim(),
                                password:
                                passwordController.text
                                    .trim(),
                                roles: [
                                  selectedRole!,
                                ],
                              );

                              final success =
                              await context
                                  .read<
                                  UserProvider>()
                                  .addUser(
                                request,
                              );

                              if (!context.mounted) {
                                return;
                              }

                              if (success) {
                                ScaffoldSnackBar.show(
                                  context,
                                  "User added successfully",
                                );

                                Navigator.pop(
                                    context);
                              } else {
                                ScaffoldSnackBar.show(
                                  context,
                                  provider.errorMessage ??
                                      "Failed to add user",
                                );
                              }
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
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: const Icon(
                Icons.person_outline_outlined,
                color: AppColors.primaryPurple,
                size: 35,
              ),
            ),
          ),
          Positioned(
            top:0,
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF3F0FF),
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
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
















// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../constants/colors_used.dart';
// import '../../customs/dropdown_test.dart';
// import '../../customs/elevated_button.dart';
// import '../../model_classes/user/add_user_request.dart';
// import '../../provider/user_provider.dart';
// import '../../pop_ups/scafold_type.dart';
//
// class AddUserDialog extends StatefulWidget {
//   const AddUserDialog({super.key});
//
//   @override
//   State<AddUserDialog> createState() => _AddUserDialogState();
// }
//
// class _AddUserDialogState extends State<AddUserDialog> {
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   bool isPasswordVisible = false;
//   String? selectedRole;
//
//   @override
//   void dispose() {
//     usernameController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<UserProvider>();
//
//     return Dialog(
//         backgroundColor: Colors.transparent,
//         child: Stack(
//             clipBehavior: Clip.none,
//             alignment: Alignment.topCenter,
//             children: [
//         Container(
//         margin: const EdgeInsets.only(top: 35),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Padding(
//             padding: const EdgeInsets.only(
//               top: 35,
//               left: 15,
//               right: 15,
//               bottom: 15,
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                 Text(
//                 "Add New User",
//                 style: TextStyle(
//                   color: AppColors.primaryPurple,
//                   fontWeight: FontWeight.w200,
//                   fontSize: 20,
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: usernameController,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   labelText: "User Name",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(5),
//                     borderSide: const BorderSide(
//                       color: Colors.grey,
//                       width: 0.5,
//                     ),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(5),
//                     borderSide: const BorderSide(
//                       color: Colors.grey,
//                       width: 0.5,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(5),
//                     borderSide: const BorderSide(
//                       color: Colors.grey,
//                       width: 0.5,
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 12),
//
//               TextFormField(
//                 controller: passwordController,
//                 obscureText: !isPasswordVisible,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   labelText: "Password",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(5),
//                     borderSide: const BorderSide(
//                       color: Colors.grey,
//                       width: 0.5,
//                     ),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(5),
//                     borderSide: const BorderSide(
//                       color: Colors.grey,
//                       width: 0.5,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(5),
//                     borderSide: const BorderSide(
//                       color: Colors.grey,
//                       width: 0.5,
//                     ),
//                   ),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       isPasswordVisible
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         isPasswordVisible = !isPasswordVisible;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 12),
//
//               CustomDropdown(
//                 hintText: "Role",
//                 initialValue: selectedRole,
//                 items: const [
//                   "ADMIN",
//                   "AGENT",
//                 ],
//                 onChanged: (value) {
//                   setState(() {
//                     selectedRole = value;
//                   });
//                 },
//               ),
//
//               const SizedBox(height: 25),
//
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomElevatedButton(
//                       text: "Cancel",
//                       borderRadius: 5,
//                       onPressed: () async {
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ),
//
//                   const SizedBox(width: 12),
//
//                   Expanded(
//                     child: provider.loading
//                         ? const Center(
//                       child: SizedBox(
//                         height: 25,
//                         width: 25,
//                         child: CircularProgressIndicator(),
//                       ),
//                     )
//                         : CustomElevatedButton(
//                       color: AppColors.primaryPurple,
//                       text: "Save",
//                       textStyle: const TextStyle(
//                         color: Colors.white,
//                       ),
//                       borderRadius: 5,
//                       onPressed: () async {
//                         if (usernameController.text.trim().isEmpty ||
//                             passwordController.text.trim().isEmpty ||
//                             selectedRole == null) {
//                           ScaffoldSnackBar.show(
//                             context,
//                             "Please fill Username, Password & Role",
//                           );
//                           return;
//                         }
//
//                         final request = AddUserRequest(
//                           username: usernameController.text.trim(),
//                           password: passwordController.text.trim(),
//                           roles: [selectedRole!],
//                         );
//
//                         final success = await context
//                             .read<UserProvider>()
//                             .addUser(request);
//
//                         if (!context.mounted) return;
//
//                         if (success) {
//                           ScaffoldSnackBar.show(
//                             context,
//                             "User added successfully",
//                           );
//
//                           Navigator.pop(context);
//                         } else {
//                           ScaffoldSnackBar.show(
//                             context,
//                             provider.errorMessage ??
//                                 "Failed to add user",
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//                 ],
//               ),
//             ),
//         ),
//         ),
//
//               Positioned(
//                 top: 0,
//                 child: Container(
//                   height: 70,
//                   width: 70,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: const Color(0xFFF3F0FF),
//                     border: Border.all(
//                       color: Colors.white,
//                       width: 4,
//                     ),
//                   ),
//                   child: const Icon(
//                     Icons.person_outline_outlined,
//                     color: AppColors.primaryPurple,
//                     size: 35,
//                   ),
//                 ),
//               ),
//             ],
//         ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
//
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:hisabio/constants/colors_used.dart';
// // import 'package:hisabio/customs/dropdown_test.dart';
// // import 'package:hisabio/customs/elevated_button.dart';
// // import 'package:hisabio/pop_ups/scafold_type.dart';
// // import 'package:provider/provider.dart';
// //
// // import '../../provider/get_user_provider.dart';
// // import '../../provider/user_all_provider.dart';
// //
// // class AddNewUser extends StatefulWidget {
// //   const AddNewUser({super.key});
// //
// //   @override
// //   State<AddNewUser> createState() => _AddNewUserState();
// // }
// //
// // class _AddNewUserState extends State<AddNewUser> {
// //   final passwordController = TextEditingController();
// //   final userController = TextEditingController();
// //   bool isPasswordVisible = false;
// //   String? selectedRole;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Dialog(
// //       backgroundColor: Colors.transparent,
// //       child: Stack(
// //         clipBehavior: Clip.none,
// //         alignment: Alignment.topCenter,
// //         children: [
// //           Container(
// //             margin: const EdgeInsets.only(top: 35),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(16),
// //             ),
// //             child: Padding(
// //               padding: const EdgeInsets.only(
// //                 top: 35,
// //                 left: 15,
// //                 right: 15,
// //               ),
// //               child: SingleChildScrollView(
// //                 child: Column(mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     Text("Add New User",style: TextStyle(
// //                       color: AppColors.primaryPurple,
// //                       fontWeight:FontWeight.w200,
// //                       fontSize: 20,
// //                     ),),
// //                     Padding(
// //                       padding: const EdgeInsets.symmetric(
// //                         vertical: 15,
// //                         horizontal: 0,
// //                       ),
// //                       child: Consumer<UserProvider>(
// //                         builder: (context, provider, child) {
// //                           return Column(
// //                             mainAxisSize: MainAxisSize.min,
// //                             children: [
// //                               TextFormField(
// //                                 controller: userController,
// //                                 decoration: InputDecoration(
// //                                   filled: true,
// //                                   fillColor: Colors.white,
// //                                   labelText: "User Name",
// //
// //                                   border: OutlineInputBorder(
// //                                     borderRadius: BorderRadius.circular(5),
// //                                     borderSide: BorderSide(
// //                                       color: Colors.grey,
// //                                       width: 0.5,
// //                                     ),
// //                                   ),
// //                                   focusedBorder: OutlineInputBorder(
// //                                     borderRadius: BorderRadius.circular(5),
// //                                     borderSide: BorderSide(
// //                                       color: Colors.grey,
// //                                       width: 0.5,
// //                                     ),
// //                                   ), enabledBorder: OutlineInputBorder(
// //                                   borderRadius: BorderRadius.circular(5),
// //                                   borderSide: BorderSide(
// //                                     color: Colors.grey,
// //                                     width: 0.5,
// //                                   ),
// //                                 ),
// //                                 ),
// //                               ),
// //                               SizedBox(height: 10),
// //                               TextFormField(
// //                                 controller: passwordController,
// //                                 obscureText: !isPasswordVisible,
// //                                 decoration: InputDecoration(
// //                                   filled: true,
// //                                   fillColor: Colors.white,
// //                                   labelText: "Password",
// //                                   border: OutlineInputBorder(
// //                                     borderRadius: BorderRadius.circular(5),
// //                                     borderSide: BorderSide(
// //                                       color: Colors.grey,
// //                                       width: 0.5,
// //                                     ),
// //                                   ),
// //                                   focusedBorder: OutlineInputBorder(
// //                                     borderRadius: BorderRadius.circular(5),
// //                                     borderSide: BorderSide(
// //                                       color: Colors.grey,
// //                                       width: 0.5,
// //                                     ),
// //                                   ), enabledBorder: OutlineInputBorder(
// //                                   borderRadius: BorderRadius.circular(5),
// //                                   borderSide: BorderSide(
// //                                     color: Colors.grey,
// //                                     width: 0.5,
// //                                   ),
// //                                 ),
// //                                   suffixIcon: IconButton(
// //                                     onPressed: () {
// //                                       setState(() {
// //                                         isPasswordVisible = !isPasswordVisible;
// //                                       });
// //                                     },
// //                                     icon: Icon(
// //                                       isPasswordVisible
// //                                           ? Icons.visibility
// //                                           : Icons.visibility_off,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                               SizedBox(height: 10),
// //                              CustomDropdown(
// //                                 initialValue: selectedRole,
// //                                 // decoration: InputDecoration(
// //                                 //   filled: true,
// //                                 //   fillColor: Colors.white,
// //                                   hintText: "Role",
// //                                   // border: OutlineInputBorder(
// //                                   //   borderRadius: BorderRadius.circular(5),
// //                                   //   borderSide: BorderSide(
// //                                   //     color: Colors.grey,
// //                                   //     width: 0.5,
// //                                   //   ),
// //                                   // ),
// //                                   // focusedBorder: OutlineInputBorder(
// //                                   //   borderRadius: BorderRadius.circular(5),
// //                                   //   borderSide: BorderSide(
// //                                   //     color: Colors.grey,
// //                                   //     width: 0.5,
// //                                   //   ),
// //                                   // ),
// //                                   // enabledBorder: OutlineInputBorder(
// //                                   //   borderRadius: BorderRadius.circular(5),
// //                                   //   borderSide: BorderSide(
// //                                   //     color: Colors.grey,
// //                                   //     width: 0.5,
// //                                   //   ),
// //                                   // ),
// //                                 items: ["ADMIN", "AGENT"],
// //
// //                                     // .map(
// //                                     //   (role) => DropdownMenuItem(
// //                                     //     value: role,
// //                                     //     child: Text(role),
// //                                     //   ),
// //                                     // )
// //                                     //.toList(),
// //                                 onChanged: (value) {
// //                                   setState(() {
// //                                     selectedRole = value;
// //                                   });
// //                                 },
// //                               ),
// //                               SizedBox(height: 20),
// //                               Column(
// //                                 mainAxisAlignment: MainAxisAlignment.end,
// //                                 children: [
// //                                   CustomElevatedButton(
// //                                     text: "cancel",
// //                                     onPressed: () async {
// //                                       Navigator.pop(context);
// //                                     },
// //                                     borderRadius: 5,
// //                                   ),
// //                                   SizedBox(width: 10),
// //                                   provider.isLoading
// //                                       ? const CircularProgressIndicator()
// //                                       : CustomElevatedButton(
// //                                           color: AppColors.primaryPurple,
// //                                           text: "Save",
// //                                           textStyle: TextStyle(
// //                                             color: Colors.white,
// //                                           ),
// //                                           onPressed: () async {
// //                                             if(userController.text.isEmpty||passwordController.text.isEmpty||selectedRole==null){
// //                                               return ScaffoldSnackBar.show(context,"Please fill UserName,Password & Roles");}
// //                                             final body = {
// //                                               "username": userController.text,
// //                                               "password": passwordController.text,
// //                                               "roles": [selectedRole],
// //                                             };
// //
// //                                             await provider.addNewUser(body);
// //                                             if (!context.mounted) return;
// //
// //                                             if (provider.errorMessage != null) {
// //                                               ScaffoldSnackBar.show(
// //                                                 context,
// //                                                 provider.errorMessage!,
// //                                               );
// //                                             } else {
// //                                               ScaffoldSnackBar.show(
// //                                                 context,
// //                                                 provider
// //                                                         .addUserResponse
// //                                                         ?.status ??
// //                                                     "User Added successfully",
// //                                               );
// //                                               await context
// //                                                   .read<GetUsersProvider>()
// //                                                   .getUsers();
// //                                               if (!context.mounted) return;
// //                                               Navigator.pop(context);
// //                                             }
// //                                           },
// //                                           borderRadius: 5,
// //                                         ),
// //                                 ],
// //                               ),
// //                             ],
// //                           );
// //                         },
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //           Positioned(
// //             top: 0,
// //             child: Container(
// //               height: 70,
// //               width: 70,
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 color: const Color(0xFFF3F0FF),
// //                 border: Border.all(color: Colors.white, width: 4),
// //               ),
// //               child: const Icon(
// //                 Icons.person_outline_outlined,
// //                 color: AppColors.primaryPurple,
// //                 size: 35,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
