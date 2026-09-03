import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../constants/colors_used.dart';
import '../enums/customer_mode.dart';

class BankDetailsSection extends StatefulWidget {
  final List banks;
  final VoidCallback onAdd;
  final Function(int) onDelete;
  final FormMode? mode;
  final ScrollController scrollController;

  const BankDetailsSection({
    super.key,
    required this.banks,
    required this.onAdd,
    required this.onDelete,
    required this.scrollController,
    this.mode,
  });

  @override
  State<BankDetailsSection> createState() => _BankDetailsSectionState();
}

class _BankDetailsSectionState extends State<BankDetailsSection> {
  final GlobalKey _bankKey = GlobalKey();
  final GlobalKey _lastBankKey = GlobalKey();
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    final banks = widget.banks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: _bankKey,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });

              if (isExpanded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_bankKey.currentContext != null) {
                    Scrollable.ensureVisible(
                      _bankKey.currentContext!,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      alignment: 0.05,
                    );
                  }
                });
              }
            },
            child: TextFormField(
              enabled: false,
              decoration: InputDecoration(
                suffixIcon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                filled: true,
                fillColor: AppColors.primaryPurple,
                hintText: "Bank Details",
                hintStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),

        if (isExpanded) ...[
          const SizedBox(height: 15),
          if (banks.isEmpty && widget.mode == FormMode.view)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              child: Center(
                child: Text(
                  "No Bank Details Available",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
          Column(
            children: List.generate(banks.length, (index) {
              final bank = banks[index];

              return Padding(
                key: index == banks.length - 1
                    ? _lastBankKey
                    : ValueKey("bank_$index"),
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.bodyFillColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Bank Account ${index + 1}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          if (widget.mode != FormMode.view && banks.length > 1)
                            IconButton(
                              icon: const Icon(
                                Iconsax.trash,
                                color: Colors.red,
                              ),
                              onPressed: () => widget.onDelete(index),
                            ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Account Holder Name",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      TextFormField(
                        enabled: widget.mode != FormMode.view,
                        controller: bank.accountName,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Account Holder Name",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text("Bank Name",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      TextFormField(
                        enabled: widget.mode != FormMode.view,
                        controller: bank.bankName,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Bank Name",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Account Number",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      TextFormField(
                        keyboardType: TextInputType.number,
                        enabled: widget.mode != FormMode.view,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: bank.accountNumber,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Account Number",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "IFSC Code",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      TextFormField(
                        enabled: widget.mode != FormMode.view,
                        controller: bank.ifscCode,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "IFSC Code",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Branch Name",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      TextFormField(
                        enabled: widget.mode != FormMode.view,
                        controller: bank.branchName,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Branch Name",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          if (widget.mode != FormMode.view)
            Align(
              alignment: Alignment.centerRight,

              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.white),
                ),
                child: TextButton(
                  onPressed: () {
                    final banks = widget.banks;

                    if (banks.isEmpty) {
                      widget.onAdd();
                      return;
                    }

                    widget.onAdd();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final context = _lastBankKey.currentContext;

                      if (context != null) {
                        Scrollable.ensureVisible(
                          context,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          alignment: 0.2,
                        );
                      }
                    });
                  },
                  child: const Text(
                    "+ ADD BANK DETAILS",
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
