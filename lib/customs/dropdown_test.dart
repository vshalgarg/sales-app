import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdown extends StatefulWidget {
  final String? label;
  final List<String> items;
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final bool isDisabled;
  final bool isRequired;

  const CustomDropdown({
    super.key,
    this.label,
    required this.items,
    this.initialValue,
    required this.onChanged,
    this.isDisabled = false,
    this.isRequired = false,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selectedValue;

  final TextEditingController _searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null &&
        widget.items.contains(widget.initialValue)) {
      selectedValue = widget.initialValue;
    }
  }

  @override
  void didUpdateWidget(CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != null &&
        widget.items.contains(widget.initialValue)) {

      setState(() {
        selectedValue = widget.initialValue;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              children: [

                TextSpan(
                  text: widget.label!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),

                if (widget.isRequired)
                  const TextSpan(
                    text: " *",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 5),
        ],

        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(

            isExpanded: true,

            hint: Text(
              widget.isDisabled
                  ? "Field Disabled"
                  : "Select",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            items: widget.items.map((item) {

              return DropdownMenuItem<String>(
                value: item,

                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              );

            }).toList(),

            value: selectedValue,

            onChanged: widget.isDisabled
                ? null
                : (value) {

              setState(() {
                selectedValue = value;
              });

              widget.onChanged(value);
            },

            buttonStyleData: ButtonStyleData(
              height: 50,

              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),

                border: Border.all(
                  color: Colors.grey,
                ),

                color: widget.isDisabled
                    ? Colors.grey.shade200
                    : Colors.white,
              ),
            ),

            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black,
              ),
            ),

            dropdownStyleData: DropdownStyleData(
              maxHeight: 250,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
            ),

            menuItemStyleData: const MenuItemStyleData(
              height: 45,
            ),

            dropdownSearchData: DropdownSearchData(

              searchController: _searchController,

              searchInnerWidgetHeight: 50,

              searchInnerWidget: Container(
                height: 50,

                padding: const EdgeInsets.all(8),

                child: TextFormField(
                  controller: _searchController,

                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              searchMatchFn: (item, searchValue) {

                return item.value
                    .toString()
                    .toLowerCase()
                    .contains(
                  searchValue.toLowerCase(),
                );
              },
            ),

            onMenuStateChange: (isOpen) {

              if (!isOpen) {
                _searchController.clear();
              }
            },
          ),
        ),
      ],
    );
  }
}