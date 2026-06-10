import 'package:flutter/material.dart';

import '../../constants/colors_used.dart';
import '../../customs/elevated_button.dart';

class UpdateUserPassword extends StatefulWidget {
  final String name;
  final Future<void> Function() onUpdate;
  final TextEditingController? newPasswordController;
  final TextEditingController? confirmPasswordController;

  const UpdateUserPassword({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Change Password: ${widget.name}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: widget.newPasswordController,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              labelText: "New Password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: widget.confirmPasswordController,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              labelText: "Confirm Password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomElevatedButton(
                text: "Cancel",
                onPressed: () async {
                  Navigator.pop(context);
                },
                borderRadius: 5,
              ),
              SizedBox(width: 10),
              CustomElevatedButton(
                color: AppColors.primaryPurple,
                text: "Save",
                textStyle: TextStyle(color: Colors.white),
                onPressed: widget.onUpdate,
                borderRadius: 5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
