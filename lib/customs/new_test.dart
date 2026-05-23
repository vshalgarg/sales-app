import 'package:flutter/material.dart';

class CustomDropdownMenu extends StatefulWidget {
  final String? label;
  final List<String> items;
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final bool isRequired;
  final bool isDisabled;
  final double? width;

  const CustomDropdownMenu({
    super.key,
    this.label,
    required this.items,
    this.initialValue,
    required this.onChanged,
    this.isRequired = false,
    this.isDisabled = false,
    this.width,
  });

  @override
  State<CustomDropdownMenu> createState() =>
      _CustomDropdownMenuState();
}

class _CustomDropdownMenuState
    extends State<CustomDropdownMenu> {
  String? selectedValue;
  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(
      covariant CustomDropdownMenu oldWidget) {

    super.didUpdateWidget(oldWidget);

    if (widget.initialValue != oldWidget.initialValue) {
      selectedValue = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        /// LABEL
        if (widget.label != null) ...[

          RichText(
            text: TextSpan(
              children: [

                TextSpan(
                  text: widget.label!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                if (widget.isRequired)
                  const TextSpan(
                    text: " *",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],

        /// DROPDOWN
        DropdownMenu<String>(

          width: widget.width ??
              MediaQuery.of(context).size.width,

          initialSelection: selectedValue,

          enabled: !widget.isDisabled,

          hintText: //widget.isDisabled
             // ? "Field Disabled"
               "Preferred Transport",

          enableSearch: true,

          enableFilter: true,

          requestFocusOnTap: true,

         // menuHeight: 250,

          textStyle: const TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),

          trailingIcon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
          ),

          selectedTrailingIcon: const Icon(
            Icons.keyboard_arrow_up,
            color: Colors.black,
          ),

          inputDecorationTheme: InputDecorationTheme(

            filled: true,

            fillColor:// widget.isDisabled
              //  ? Colors.grey.shade200
                 Colors.white,

            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),

              borderSide: BorderSide(
                color: widget.isDisabled?Colors.grey.shade200
               : Colors.grey.shade400,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),

              borderSide: BorderSide(
                color: Colors.grey.shade600,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),

              borderSide: const BorderSide(
                color: Colors.deepPurple,
                width: 1.8,
              ),
            ),
          ),

          menuStyle: MenuStyle(

            backgroundColor:
            const WidgetStatePropertyAll(
              Colors.white,
            ),

            elevation:
            const WidgetStatePropertyAll(4),

            shape: WidgetStatePropertyAll(

              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(12),
              ),
            ),
          ),

          dropdownMenuEntries:
          widget.items.map((item) {

            return DropdownMenuEntry<String>(
              value: item,
              label: item,
            );

          }).toList(),

          onSelected: widget.isDisabled
              ? null
              : (value) {

            setState(() {
              selectedValue = value;
            });

            widget.onChanged(value);
          },
        ),
      ],
    );
  }
}