import 'package:flutter/material.dart';
import 'package:hisabio/screens/login_screen.dart';
import '../../constants/colors_used.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../shared_preferences/login_token.dart';

class NewCustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const NewCustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  State<NewCustomAppBar> createState() => _NewCustomAppBarState();
}

class _NewCustomAppBarState extends State<NewCustomAppBar> {
  String email = "";

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final value = await AppStorage.getEmail();

    if (!mounted) return;

    setState(() {
      email = value ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(7),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryPurple,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              "h",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
      title: const Text(
        "hissabio",
        style: TextStyle(
          color: AppColors.primaryPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout,size:30),
          onPressed:(){
            ExitConfirmationDialog.show(
              context,
              bodyText: "Are you sure you want to logout?",
              saveButtonText: "Logout",
              discardButtonText: "Cancel",

              onSave: () async {
                await AppStorage.clear();

                Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginScreen()));
              },

              onDiscard: () {
                Navigator.pop(context);
              },

            );
          },
        ),
      ],
    );
  }
}