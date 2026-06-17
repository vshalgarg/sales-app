import 'package:flutter/material.dart';
import '../constants/colors_used.dart';
import '../enums/customer_mode.dart';

class BankDetailsSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       /* Text(
          "Bank Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),*/
        TextFormField(
          enabled: false,
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.keyboard_arrow_down,color:Colors.white),
            iconColor: Colors.white,
            filled:true,
            fillColor: AppColors.primaryPurple,
            hintText: "Bank Details",hintStyle: TextStyle(color:Colors.white),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),

        ),

        SizedBox(height: 15),
        Text("Account Number",style:TextStyle(color:Colors.white,fontSize: 18)),
        TextFormField(  keyboardType: TextInputType.number,
          enabled: mode != FormMode.view,

          controller: accountNumber,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,
            hintText: "Account Number",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        SizedBox(height: 15),
        Text("IFSC Code",style:TextStyle(color:Colors.white,fontSize: 18)),
        TextFormField(
          enabled: mode != FormMode.view,
          controller: ifscCode,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,
            hintText: "IFSC Code",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        Text("Bank Name",style:TextStyle(color:Colors.white,fontSize: 18)),
        SizedBox(height: 15),
        TextFormField(
          enabled: mode != FormMode.view,
          controller: bankName,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,
            hintText: "Bank Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        SizedBox(height: 15),
        Text("Branch Name",style:TextStyle(color:Colors.white,fontSize: 18)),
        TextFormField(
          enabled: mode != FormMode.view,
          controller: branchName,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,
            hintText: "Branch Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        SizedBox(height: 15),
        Text("Account Holder Name",style:TextStyle(color:Colors.white,fontSize: 18)),
        TextFormField(
          enabled: mode != FormMode.view,
          controller: accountHolderName,
          decoration: InputDecoration(
            filled:true,
            fillColor: Colors.white,
            hintText: "Account Holder Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
      ],
    );
  }
}
