import 'package:flutter/material.dart';
import 'package:hisabio/constants/list_items.dart';
import 'package:hisabio/enums/supplier_mode.dart';

class AddressDetails extends StatefulWidget {
  final SupplierMode mode;
  final TextEditingController addressLine1;
  final TextEditingController addressLine2;
  final TextEditingController state;
  final TextEditingController city;
  final TextEditingController pinCode;

  const AddressDetails({
    super.key,
    required this.mode,
    required this.addressLine1,
    required this.addressLine2,
    required this.state,
    required this.city,
    required this.pinCode,
  });

  @override
  State<AddressDetails> createState() => _AddressDetailsState();
}

class _AddressDetailsState extends State<AddressDetails> {
  String? selectedState;
  @override
  void initState() {
    super.initState();

    selectedState =
    widget.state.text.isEmpty ? null : widget.state.text;
  }
  @override
  void didUpdateWidget(covariant AddressDetails oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state.text != selectedState) {
      setState(() {
        selectedState =
        widget.state.text.isEmpty ? null : widget.state.text;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Address Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 15),
        TextFormField(  enabled: widget.mode != SupplierMode.view,
          controller: widget.addressLine1,
          decoration: InputDecoration(
            labelText: "Address Line1",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        SizedBox(height: 15),
        TextFormField(enabled: widget.mode != SupplierMode.view,
          controller: widget.addressLine2,
          decoration: InputDecoration(
            labelText: "Address Line2",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: selectedState,
          isExpanded: true,
          decoration: InputDecoration(
            enabled: widget.mode != SupplierMode.view,
            labelText: "State",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          ),
          menuMaxHeight: double.infinity,
          items: ListItems.indianStates.map((state) {
            return DropdownMenuItem(
              value: state,
              child: Text(state),
            );
          }).toList(),
          onChanged: widget.mode == SupplierMode.view
            ? null
              : (value) {
            setState(() {
              selectedState = value;
             widget.state.text = value ?? "";
            });
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          enabled: widget.mode != SupplierMode.view,
          controller: widget.city,
          decoration: InputDecoration(
            labelText: "city",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 15),
        TextFormField(  keyboardType: TextInputType.number,
          enabled: widget.mode != SupplierMode.view,
          controller: widget.pinCode,
          decoration: InputDecoration(
            labelText: "Pin Code",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
