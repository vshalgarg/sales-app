import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EntryTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final bool? enabled;
  final bool integerOnly;
  final bool decimalAllowed;

  const EntryTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.enabled,
    this.integerOnly = false,
    this.decimalAllowed = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged:onChanged,
      enabled: enabled,
      keyboardType: integerOnly || decimalAllowed
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,

      inputFormatters: integerOnly
          ? [
        FilteringTextInputFormatter.digitsOnly,
      ]
          : decimalAllowed
          ? [
        FilteringTextInputFormatter.allow(
          RegExp(r'^\d*\.?\d*'),
        ),
      ]
          : null,
      decoration: InputDecoration(
        hintText: hintText,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
