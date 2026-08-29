import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class EntryDateTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final VoidCallback? onTap;
  final bool? enabled;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;
  const EntryDateTextField({
    super.key,
    this.enabled,
    required this.label,
    required this.controller,
    this.firstDate,
    this.lastDate,
    this.onTap,
    this.validator,
    this.autovalidateMode,
  });

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    if (controller.text.trim().isNotEmpty) {
      try {
        initialDate =
            DateFormat('dd-MM-yyyy').parse(controller.text.trim());
      } catch (_) {
        initialDate = DateTime.now();
      }
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime.now(),
    );

    if (pickedDate != null) {
      controller.text =
          DateFormat('dd-MM-yyyy').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      validator: validator,
      autovalidateMode: autovalidateMode,
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
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.white),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.white),
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
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: const Icon(Iconsax.calendar_tick),
      ),
    );
  }
}