import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EntryDateTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final VoidCallback? onTap;

  const EntryDateTextField({
    super.key,
    required this.label,
    required this.controller,
    this.firstDate,
    this.lastDate,
    this.onTap,
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
      readOnly: true,
      onTap: () async {
        if (onTap != null) {
          onTap!();
        } else {
          await _selectDate(context);
        }
      },
      decoration: InputDecoration(
       border:OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelText: label,
        suffixIcon: const Icon(Iconsax.calendar_tick),
      ),
    );
  }
}