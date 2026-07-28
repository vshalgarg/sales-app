import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors_used.dart';
import '../enums/customer_mode.dart';

class BankDetailsSection extends StatefulWidget {
  final FormMode? mode;
  final TextEditingController accountNumber;
  final TextEditingController ifscCode;
  final TextEditingController bankName;
  final TextEditingController branchName;
  final TextEditingController accountHolderName;

  const BankDetailsSection({
    super.key,
    this.mode,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.branchName,
    required this.accountHolderName,
  });

  @override
  State<BankDetailsSection> createState() => _BankDetailsSectionState();
}

class _BankDetailsSectionState extends State<BankDetailsSection> {
  bool isBasicInfoExpanded=false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(onTap:(){setState(() {
          isBasicInfoExpanded = !isBasicInfoExpanded;
        });},
          child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
              suffixIcon: Icon(isBasicInfoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white),
              iconColor: Colors.white,
              filled:true,
              fillColor: AppColors.primaryPurple,
              hintText: "Bank Details",hintStyle: TextStyle(color:Colors.white),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),  borderSide: BorderSide.none,),
            ),
          ),
        ),

        if (isBasicInfoExpanded) ...[
        SizedBox(height: 15),
        Text("Account Number",style:TextStyle(color:Colors.white,fontSize: 18)),
        TextFormField(
          keyboardType: TextInputType.number,
          enabled: widget.mode != FormMode.view,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],

          controller: widget.accountNumber,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,
            hintText: "Account Number",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),  borderSide: BorderSide.none,),
          ),
        ),
        SizedBox(height: 15),
        Text("IFSC Code",style:TextStyle(color:Colors.white,fontSize: 18)),
        TextFormField(
          enabled: widget.mode != FormMode.view,
          controller: widget.ifscCode,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,
            hintText: "IFSC Code",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),  borderSide: BorderSide.none,),
          ),
        ), SizedBox(height: 15),
        Text("Bank Name",style:TextStyle(color:Colors.white,fontSize: 18)),
          TextFormField(
          enabled: widget.mode != FormMode.view,
          controller: widget.bankName,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,
            hintText: "Bank Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),  borderSide: BorderSide.none,),
          ),
        ),
        SizedBox(height: 15),
        Text("Branch Name",style:TextStyle(color:Colors.white,fontSize: 18)),
        TextFormField(
          enabled: widget.mode != FormMode.view,
          controller: widget.branchName,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,
            hintText: "Branch Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),  borderSide: BorderSide.none,),
          ),
        ),
        SizedBox(height: 15),
        Text("Account Holder Name",style:TextStyle(color:Colors.white,fontSize: 18)),
        TextFormField(
          enabled: widget.mode != FormMode.view,
          controller: widget.accountHolderName,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,
            hintText: "Account Holder Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5),  borderSide: BorderSide.none,),
          ),
        ),
        ],
      ],
    );
  }
}
