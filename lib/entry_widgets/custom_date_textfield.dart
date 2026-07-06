import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EntryDateTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  const EntryDateTextField({
    super.key,
    required this.label,
    required this.controller,
    this.firstDate,
    this.lastDate,
    this.onTap,
    this.validator
  });

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );

    if (pickedDate != null) {
      controller.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly: true,
      onTap: () async {
        if (onTap != null) {
          onTap!();
        } else {
          await _selectDate(context);
        }
      },
      decoration: InputDecoration(
        filled: true,
        fillColor:Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Colors.grey),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Colors.blue),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        hintText: label,
        suffixIcon: const Icon(Iconsax.calendar_tick),
      ),
    );
  }
}
