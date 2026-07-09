import 'package:flutter/material.dart';
import '../constants/colors_used.dart';
import '../model_classes/search_credit.dart';

class CreditDetailsBottomSheet extends StatefulWidget {
  final SearchCreditEntry credit;

  const CreditDetailsBottomSheet({
    super.key,
    required this.credit,
  });

  @override
  State<CreditDetailsBottomSheet> createState() =>
      _CreditDetailsBottomSheetState();
}

class _CreditDetailsBottomSheetState
    extends State<CreditDetailsBottomSheet> {
  bool showTransaction = true;
  bool showParty = false;
  bool showReference = false;
  bool showMisc = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF9CA4DA),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF9499D8),
                Color(0xFFB6BCE3),
              ],
            ),
          ),
          child: Column(
            children: [
              // HEADER
          Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 2),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                      "Credit Details",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: width < 600 ? 16 : 30,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [

                      // TRANSACTION DETAILS
                    _sectionCard(
                    title: "Transaction Details",
                    expanded: showTransaction,
                    onTap: () {
                      setState(() {
                        showTransaction = !showTransaction;
                      });
                    },
                    child: Column(
                          children: [
                            _field(
                              "Invoice Number",
                              widget.credit.billNumber ?? "-",
                            ),
                            _field(
                              "Transaction Date",
                              widget.credit.date ?? "-",
                            ),
                            _field(
                              "Payment Type",
                              widget.credit.paymentType ?? "-",
                            ),
                            _field(
                              "Received Amount",
                              "₹${widget.credit.receivedAmount ?? 0}",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // PARTY INFORMATION
                      _sectionCard(
                        title: "Party Information",
                        expanded: showParty,
                        onTap: () {
                          setState(() {
                            showParty = !showParty;
                          });
                        },
                        child: Column(
                          children: [
                            _field(
                              "Supplier Name",
                              widget.credit.supplierName ?? "-",
                            ),
                            _field(
                              "Customer Name",
                              widget.credit.customerName ?? "-",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // REFERENCE DETAILS
                      _sectionCard(
                        title: "Reference Details",
                        expanded: showReference,
                        onTap: () {
                          setState(() {
                            showReference = !showReference;
                          });
                        },
                        child: Column(
                          children: [
                            _field(
                              "Reference Number",
                              widget.credit.referenceNumber ?? "-",
                            ),
                            _field(
                              "Reference Date",
                              widget.credit.referenceDate ?? "-",
                            ),
                            _field(
                              "Slip Number",
                              widget.credit.slipNumber ?? "-",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // MISCELLANEOUS
                      _sectionCard(
                        title: "Miscellaneous",
                        expanded: showMisc,
                        onTap: () {
                          setState(() {
                            showMisc = !showMisc;
                          });
                        },
                        child: Column(
                          children: [
                            _field(
                              "Draw Type",
                              widget.credit.drawType ?? "-",
                            ),
                            _field(
                              "Remarks",
                              widget.credit.remark ?? "-",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),

        if (expanded) ...[
          const SizedBox(height: 15),
          child,
        ],
      ],
    );
  }

  Widget _field(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(6),
            ),
            child: Text(
              value.isEmpty ? "-" : value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}