import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';

class CustomCopyDetailsDialog extends StatelessWidget {
  final String? firmName;
  final String? address;
  final String? contact;
  final String? emails;
  final String? gstNo;
  final String? heading;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? accountHolder;
  final bool showCopyBankButton;
  final bool showCloseIcon;

  const CustomCopyDetailsDialog({
    super.key,
    this.firmName,
    this.contact,
    this.address,
    this.emails,
    this.gstNo,
    this.heading,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.accountHolder,
    this.showCopyBankButton = true,
    this.showCloseIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 35),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 35,
                left: 15,
                right: 15,
                bottom: 15,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        heading ?? "Copy Supplier Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((firmName ?? "").trim().isNotEmpty) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: AppColors.containerFillColor,
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(
                                          Icons.location_city_outlined,
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Firm Name:",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        Text(
                                          "$firmName",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if ((address ?? "").trim().isNotEmpty) ...[
                              Divider(thickness: 0.3),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: AppColors.containerFillColor,
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(
                                          Icons.location_on_sharp,
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Address:",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "$address",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if ((contact ?? "").trim().isNotEmpty) ...[
                              Divider(thickness: 0.3),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: AppColors.containerFillColor,
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(
                                          Icons.phone,
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Contacts:",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "$contact",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if ((emails ?? "").trim().isNotEmpty) ...[
                              Divider(thickness: 0.3),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: AppColors.containerFillColor,
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(
                                          Icons.mail_lock_outlined,
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Email:",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "$emails",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if ((gstNo ?? "").trim().isNotEmpty) ...[
                              Divider(thickness: 0.3),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: AppColors.containerFillColor,
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(
                                          Icons.percent_outlined,
                                          color: AppColors.primaryPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "GST:",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "$gstNo",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if ((bankName ?? "").trim().isNotEmpty) ...[
                              Divider(thickness: 0.3),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: AppColors.containerFillColor,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.account_balance,
                                        color: AppColors.primaryPurple,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Bank Name:",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          bankName!,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if ((accountHolder ?? "").trim().isNotEmpty) ...[
                              Divider(thickness: 0.3),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: AppColors.containerFillColor,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.primaryPurple,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Account Holder:",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          accountHolder!,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if ((accountNumber ?? "").trim().isNotEmpty) ...[
                              Divider(thickness: 0.3),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: AppColors.containerFillColor,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.credit_card,
                                        color: AppColors.primaryPurple,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Account Number:",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          accountNumber!,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if ((ifscCode ?? "").trim().isNotEmpty) ...[
                              Divider(thickness: 0.3),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: AppColors.containerFillColor,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.account_tree,
                                        color: AppColors.primaryPurple,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "IFSC Code:",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          ifscCode!,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: showCopyBankButton
                                ? OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    onPressed: () {
                                      final hasBankDetails =
                                          (bankName?.trim().isNotEmpty ??
                                              false) ||
                                          (accountHolder?.trim().isNotEmpty ??
                                              false) ||
                                          (accountNumber?.trim().isNotEmpty ??
                                              false) ||
                                          (ifscCode?.trim().isNotEmpty ??
                                              false);

                                      if (!hasBankDetails) {
                                        ScaffoldSnackBar.show(
                                          context,
                                          "No bank details found",
                                        );
                                        return;
                                      }

                                      final buffer = StringBuffer();

                                      if ((bankName ?? "").trim().isNotEmpty) {
                                        buffer.writeln(
                                          "*Bank Name*: $bankName",
                                        );
                                      }

                                      if ((accountHolder ?? "")
                                          .trim()
                                          .isNotEmpty) {
                                        buffer.writeln(
                                          "*Account Holder*: $accountHolder",
                                        );
                                      }

                                      if ((accountNumber ?? "")
                                          .trim()
                                          .isNotEmpty) {
                                        buffer.writeln(
                                          "*Account Number*: $accountNumber",
                                        );
                                      }

                                      if ((ifscCode ?? "").trim().isNotEmpty) {
                                        buffer.writeln("*IFSC*: $ifscCode");
                                      }

                                      Clipboard.setData(
                                        ClipboardData(text: buffer.toString()),
                                      );

                                      Navigator.pop(context);

                                      ScaffoldSnackBar.show(
                                        context,
                                        "Bank details copied successfully",
                                      );
                                    },
                                    child: const Text("Copy Bank Details",
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),),
                                  )
                                : OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel"),
                                  ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            flex:1,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: () {
                                final buffer = StringBuffer();

                                if ((firmName ?? "").trim().isNotEmpty) {
                                  buffer.writeln("*Firm Name*: $firmName");
                                }

                                if ((address ?? "").trim().isNotEmpty) {
                                  buffer.writeln("*Address*: $address");
                                }

                                if ((contact ?? "").trim().isNotEmpty) {
                                  buffer.writeln("*Contacts*: $contact");
                                }

                                if ((emails ?? "").trim().isNotEmpty) {
                                  buffer.writeln("*Email*: $emails");
                                }

                                if ((gstNo ?? "").trim().isNotEmpty) {
                                  buffer.writeln("*GST*: $gstNo");
                                }
                                Clipboard.setData(
                                  ClipboardData(text: buffer.toString()),
                                );
                                Navigator.pop(context);
                                ScaffoldSnackBar.show(
                                  context,
                                  "Copied successfully",
                                );
                              },
                              child: const Text(
                                "Copy",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (showCloseIcon)
          Positioned(
            top: 25,
            right: -2,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 25),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF3F0FF),
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: const Icon(
                Icons.copy,
                color: AppColors.primaryPurple,
                size: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
