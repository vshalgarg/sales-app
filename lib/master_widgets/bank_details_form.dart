import 'package:flutter/material.dart';
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
        Text(
          "Bank Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 15),
        TextFormField(  keyboardType: TextInputType.number,
          enabled: mode != FormMode.view,

          controller: accountNumber,
          decoration: InputDecoration(
            labelText: "Account Number",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 15),
        TextFormField(
          enabled: mode != FormMode.view,
          controller: ifscCode,
          decoration: InputDecoration(
            labelText: "IFSC Code",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 15),
        TextFormField(
          enabled: mode != FormMode.view,
          controller: bankName,
          decoration: InputDecoration(
            labelText: "Bank Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 15),
        TextFormField(
          enabled: mode != FormMode.view,
          controller: branchName,
          decoration: InputDecoration(
            labelText: "Branch Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        SizedBox(height: 15),
        TextFormField(
          enabled: mode != FormMode.view,
          controller: accountHolderName,
          decoration: InputDecoration(
            labelText: "Account Holder Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
