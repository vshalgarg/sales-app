import 'package:flutter/material.dart';
import 'package:hisabio/constants/list_items.dart';

class AddressDetails extends StatefulWidget {
  final TextEditingController addressLine1;
  final TextEditingController addressLine2;
  final TextEditingController state;
  final TextEditingController city;
  final TextEditingController pinCode;

  const AddressDetails({
    super.key,
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
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Address Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 15),
        TextFormField(
          controller: widget.addressLine1,
          decoration: InputDecoration(
            labelText: "Address Line1",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        SizedBox(height: 15),
        TextFormField(
          controller: widget.addressLine2,
          decoration: InputDecoration(
            labelText: "Address Line2",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 15),
        DropdownButtonFormField<String>(
         // value: selectedState,

          decoration: InputDecoration(
            labelText: "State",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          items: ListItems.indianStates.map((state) {
            return DropdownMenuItem(
              value: state,
              child: Text(state),
            );
          }).toList(),

          onChanged: (value) {
            setState(() {
              selectedState = value;

              widget.state.text = value ?? "";
            });
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: widget.city,
          decoration: InputDecoration(
            labelText: "city",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 15),
        TextFormField(  keyboardType: TextInputType.number,
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
