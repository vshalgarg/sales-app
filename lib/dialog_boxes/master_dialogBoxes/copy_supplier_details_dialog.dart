import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/model_classes/supplier/bank_details_request.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';

class CustomCopyDetailsDialog extends StatelessWidget {
  final String? firmName;
  final String? address;
  final String? contact;
  final String? emails;
  final String? gstNo;
  final String? heading;

  // NEW: multiple bank details
  final List<BankDetailRequest> bankDetails;

  final String? transport;

  final bool showCopyBankButton;
  final bool showCloseIcon;

  const CustomCopyDetailsDialog({
    super.key,
    this.firmName,
    this.address,
    this.contact,
    this.emails,
    this.gstNo,
    this.heading,
    this.bankDetails = const [],
    this.transport,
    this.showCopyBankButton = true,
    this.showCloseIcon = true,
  });

  String _clean(String? value) {
    final text = value?.trim() ?? "";

    if (text.isEmpty) return "";

    final lower = text.toLowerCase();

    if (lower == "null" ||
        lower == "n/a" ||
        lower == "na" ||
        text == "-") {
      return "";
    }

    return text;
  }

  bool _hasValue(String? value) {
    return _clean(value).isNotEmpty;
  }

  bool _hasBankValue(BankDetailRequest bank) {
    return _hasValue(bank.accountName) ||
        _hasValue(bank.bankName) ||
        _hasValue(bank.accountNumber) ||
        _hasValue(bank.ifscCode) ||
        _hasValue(bank.branchName);
  }

  bool get hasBankDetails {
    return bankDetails.any(_hasBankValue);
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.containerFillColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryPurple,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _clean(value),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetails(BankDetailRequest bank, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height:5),
        Text(
          "Bank Account ${index + 1}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        if (_hasValue(bank.accountName))
          _buildInfoTile(
            icon: Icons.person_outline,
            title: "Account Holder Name",
            value: _clean(bank.accountName),
          ),
        const SizedBox(height: 10),
        if (_hasValue(bank.bankName))
          _buildInfoTile(
            icon: Icons.account_balance,
            title: "Bank Name",
            value: _clean(bank.bankName),
          ),
        const SizedBox(height: 10),
        if (_hasValue(bank.accountNumber))
          _buildInfoTile(
            icon: Icons.numbers,
            title: "Account Number",
            value: _clean(bank.accountNumber),
          ),
        const SizedBox(height: 10),
        if (_hasValue(bank.ifscCode))
          _buildInfoTile(
            icon: Icons.code,
            title: "IFSC Code",
            value: _clean(bank.ifscCode),
          ),
        const SizedBox(height: 10),
        if (_hasValue(bank.branchName))
          _buildInfoTile(
            icon: Icons.account_tree_outlined,
            title: "Branch",
            value: _clean(bank.branchName),
          ),
      ],
    );
  }

  // COPY ONLY BANK DETAILS
  void _copyBankDetails(BuildContext context) {
    if (!hasBankDetails) {
      ScaffoldSnackBar.show(
        context,
        "No bank details found",
      );
      return;
    }

    final buffer = StringBuffer();

    for (int i = 0; i < bankDetails.length; i++) {
      final bank = bankDetails[i];

      if (!_hasBankValue(bank)) {
        continue;
      }

      buffer.writeln("Bank Account ${i + 1}");

      if (_hasValue(bank.accountName)) {
        buffer.writeln(
          "Account Holder : ${_clean(bank.accountName)}",
        );
      }

      if (_hasValue(bank.bankName)) {
        buffer.writeln(
          "Bank Name : ${_clean(bank.bankName)}",
        );
      }

      if (_hasValue(bank.accountNumber)) {
        buffer.writeln(
          "Account Number : ${_clean(bank.accountNumber)}",
        );
      }

      if (_hasValue(bank.ifscCode)) {
        buffer.writeln(
          "IFSC Code : ${_clean(bank.ifscCode)}",
        );
      }

      if (_hasValue(bank.branchName)) {
        buffer.writeln(
          "Branch : ${_clean(bank.branchName)}",
        );
      }

      buffer.writeln();
    }

    Clipboard.setData(
      ClipboardData(
        text: buffer.toString().trim(),
      ),
    );

    Navigator.pop(context);

    ScaffoldSnackBar.show(
      context,
      "Bank details copied successfully",
    );
  }

  // COPY EVERYTHING
  void _copyAllDetails(BuildContext context) {
    final buffer = StringBuffer();

    if (_hasValue(firmName)) {
      buffer.writeln(
        "Firm Name : ${_clean(firmName)}",
      );
      buffer.writeln();
    }

    if (_hasValue(address)) {
      buffer.writeln("Address : ");
      buffer.writeln(_clean(address));
      buffer.writeln();
    }

    if (_hasValue(contact)) {
      buffer.writeln("Contacts : ");
      buffer.writeln(_clean(contact));
      buffer.writeln();
    }

    if (_hasValue(transport)) {
      buffer.writeln(
        "Transport : ${_clean(transport)}",
      );
      buffer.writeln();
    }

    if (_hasValue(emails)) {
      buffer.writeln(
        "Email : ${_clean(emails)}",
      );
      buffer.writeln();
    }

    if (_hasValue(gstNo)) {
      buffer.writeln(
        "GST : ${_clean(gstNo)}",
      );
      buffer.writeln();
    }

    // if (hasBankDetails) {
    //   buffer.writeln("Bank Details");
    //   buffer.writeln();
    //
    //   for (int i = 0; i < bankDetails.length; i++) {
    //     final bank = bankDetails[i];
    //
    //     if (!_hasBankValue(bank)) {
    //       continue;
    //     }
    //
    //     buffer.writeln(
    //       "Bank Details ${i + 1}",
    //     );
    //
    //     if (_hasValue(bank.accountName)) {
    //       buffer.writeln(
    //         "Account Holder : ${_clean(bank.accountName)}",
    //       );
    //     }
    //
    //     if (_hasValue(bank.bankName)) {
    //       buffer.writeln(
    //         "Bank Name : ${_clean(bank.bankName)}",
    //       );
    //     }
    //
    //     if (_hasValue(bank.accountNumber)) {
    //       buffer.writeln(
    //         "Account Number : ${_clean(bank.accountNumber)}",
    //       );
    //     }
    //
    //     if (_hasValue(bank.ifscCode)) {
    //       buffer.writeln(
    //         "IFSC Code : ${_clean(bank.ifscCode)}",
    //       );
    //     }
    //
    //     if (_hasValue(bank.branchName)) {
    //       buffer.writeln(
    //         "Branch : ${_clean(bank.branchName)}",
    //       );
    //     }

    //     buffer.writeln();
    //   }
    // }

    Clipboard.setData(
      ClipboardData(
        text: buffer.toString().trim(),
      ),
    );

    Navigator.pop(context);

    ScaffoldSnackBar.show(
      context,
      "Copied successfully",
    );
  }

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
              padding: const EdgeInsets.fromLTRB(
                16,
                36,
                16,
                16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                  MediaQuery.of(context).size.height * .75,
                  maxWidth: 650,
                ),
                child: IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          heading ?? "Copy Supplier Details",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                if (_hasValue(firmName))
                                  _buildInfoTile(
                                    icon: Icons.business,
                                    title: "Firm Name",
                                    value: _clean(firmName),
                                  ),

                                if (_hasValue(address))
                                  _buildInfoTile(
                                    icon:
                                    Icons.location_on_outlined,
                                    title: "Address",
                                    value: _clean(address),
                                  ),

                                if (_hasValue(contact))
                                  _buildInfoTile(
                                    icon: Icons.phone,
                                    title: "Contacts",
                                    value: _clean(contact),
                                  ),

                                if (_hasValue(transport))
                                  _buildInfoTile(
                                    icon:
                                    Icons.local_shipping_outlined,
                                    title: "Transport",
                                    value: _clean(transport),
                                  ),

                                if (_hasValue(emails))
                                  _buildInfoTile(
                                    icon: Icons.email_outlined,
                                    title: "Email",
                                    value: _clean(emails),
                                  ),

                                if (_hasValue(gstNo))
                                  _buildInfoTile(
                                    icon:
                                    Icons.receipt_long_outlined,
                                    title: "GST",
                                    value: _clean(gstNo),
                                  ),

                                // ALL BANK DETAILS

                                if (hasBankDetails) ...[
                                  const SizedBox(height: 10),

                                  const Text(
                                    "Bank Details",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  ...List.generate(
                                    bankDetails.length,
                                        (index) {
                                      final bank =
                                      bankDetails[index];

                                      if (!_hasBankValue(bank)) {
                                        return const SizedBox();
                                      }

                                      return _buildBankDetails(
                                        bank,
                                        index,
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: () {
                                    if (showCopyBankButton) {
                                      _copyBankDetails(context);
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  },
                                  style:
                                  OutlinedButton.styleFrom(
                                    shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      showCopyBankButton
                                          ? "Copy Bank Details"
                                          : "Cancel",
                                      maxLines: 1,
                                      style:
                                      const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Flexible(
                              flex: 2,
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _copyAllDetails(context),
                                  style:
                                  ElevatedButton.styleFrom(
                                    backgroundColor:
                                    AppColors.primaryPurple,
                                    shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Copy",
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    ),
                                  ),
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
          ),

          if (showCloseIcon)
            Positioned(
              top: 25,
              right: -2,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 22,
                  ),
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
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: const Icon(
                Icons.copy,
                size: 35,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
