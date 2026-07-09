import 'package:flutter/material.dart';

class CustomApiTextField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final String? Function(T?)? validator;

  const CustomApiTextField({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.hintText ,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final T? selectedValue = items.contains(value) ? value : null;
    return DropdownButtonFormField<T>(
      initialValue: selectedValue,
      isExpanded: true,
      validator: validator,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled:true,
        hintText: hintText,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
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
          )
        ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item)),
        );
      }).toList(),

      onChanged: onChanged,
    );
  }
}