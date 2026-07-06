import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EntryTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final bool? enabled;
  final bool integerOnly;
  final bool decimalAllowed;
  final String? Function(String?)? validator;
  const EntryTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.enabled,
    this.integerOnly = false,
    this.decimalAllowed = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: integerOnly || decimalAllowed
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,

      inputFormatters: integerOnly
          ? [FilteringTextInputFormatter.digitsOnly]
          : decimalAllowed
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
          : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
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
      ),
    );
  }
}
