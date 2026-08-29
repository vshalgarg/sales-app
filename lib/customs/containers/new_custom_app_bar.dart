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
        backgroundColor: Colors.white,

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
          SizedBox(
          width: 48,
          height: 48,
          child: Padding(
        padding: const EdgeInsets.all(2),
            child: Image.asset('assets/images/img.png',
              fit: BoxFit.contain,
            ),
            ),
          ),
      const SizedBox(width: 5),
      const Text(
        "hissabio",
        style: TextStyle(
          color: AppColors.primaryPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
      ]
        ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout,size:30),
          onPressed:(){
            ExitConfirmationDialog.show(
              context,
              bodyText: "Are you sure you want to logout?",
              icon: Icons.logout,
              saveButtonText: "Logout",
              discardButtonText: "Cancel",
              isLogout: true,
              onSave: () async {
                final navigator = Navigator.of(context);
                await AppStorage.clear();
                if (!mounted) return;
                navigator.push(
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()));
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