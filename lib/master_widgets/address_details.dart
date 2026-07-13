import 'package:flutter/material.dart';
import 'package:hisabio/constants/list_items.dart';

import '../constants/colors_used.dart';
import '../enums/customer_mode.dart';

class AddressDetails extends StatefulWidget {
  final FormMode? mode;
  final TextEditingController addressLine1;
  final TextEditingController addressLine2;
  final TextEditingController state;
  final TextEditingController city;
  final TextEditingController pinCode;

  const AddressDetails({
    super.key,
    this.mode,
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
   bool isExpanded=false;

  @override
  void initState() {
    super.initState();

    selectedState = widget.state.text.isEmpty ? null : widget.state.text;
  }

  @override
  void didUpdateWidget(covariant AddressDetails oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state.text != selectedState) {
      setState(() {
        selectedState = widget.state.text.isEmpty ? null : widget.state.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        GestureDetector(onTap:(){setState(() {
          isExpanded=!isExpanded;

        });},
          child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
              suffixIcon: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,color:Colors.white),
              iconColor: Colors.white,
              filled:true,
              fillColor: AppColors.primaryPurple,
              hintText: "Address Details",hintStyle: TextStyle(color:Colors.white),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),  borderSide: BorderSide.none,),
            ),

          ),
        ),
    if (isExpanded) ...[

        SizedBox(height: 15),
        Text("Address Line1",style:TextStyle(color:Colors.white,fontSize: 18)),
        TextFormField(
          minLines: 1,
          maxLines: 5,
          enabled: widget.mode != FormMode.view,
          controller: widget.addressLine1,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,
            hintText: "Address Line1",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),  borderSide: BorderSide.none,),
          ),
        ),

        SizedBox(height: 15),
        Text("Address Line2",style:TextStyle(color:Colors.white,fontSize: 18)),
        TextFormField(
          minLines: 1,
          maxLines: 5,
          enabled: widget.mode != FormMode.view,
          controller: widget.addressLine2,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,
            hintText: "Address Line2",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),  borderSide: BorderSide.none,),
          ),
        ),
        SizedBox(height: 15),

        Text("State",style:TextStyle(color:Colors.white,fontSize: 18),
        ),
        DropdownButtonFormField<String>(
          initialValue: ListItems.indianStates.contains(selectedState)
              ? selectedState
              : null,
          isExpanded: true,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,
            enabled: widget.mode != FormMode.view,
            hintText: "State",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),  borderSide: BorderSide.none,),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          menuMaxHeight: double.infinity,
          items: ListItems.indianStates.map((state) {
            return DropdownMenuItem(value: state, child: Text(state));
          }).toList(),
          onChanged: widget.mode == FormMode.view
              ? null
              : (value) {
                  setState(() {
                    selectedState = value;
                    widget.state.text = value ?? "";
                  });
                },
        ),

        SizedBox(height: 15),
        Text("City",style:TextStyle(color:Colors.white,fontSize: 18)),
        TextFormField(
          enabled: widget.mode != FormMode.view,
          controller: widget.city,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,
            hintText: "city",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),  borderSide: BorderSide.none,),
          ),
        ),
        SizedBox(height: 15),
        Text("Pin Code",style:TextStyle(color:Colors.white,fontSize: 18)),
        TextFormField(
          keyboardType: TextInputType.number,
          maxLength: 6,
          enabled: widget.mode != FormMode.view,
          controller: widget.pinCode,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,

            hintText: "Pin Code",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),  borderSide: BorderSide.none,),
          ),
        ),
     ] ],
    );
  }
}
