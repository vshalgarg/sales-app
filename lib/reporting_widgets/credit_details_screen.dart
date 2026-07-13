import 'package:flutter/material.dart';
import '../constants/colors_used.dart';
import '../customs/app_bar.dart';
import '../model_classes/search_credit.dart';

class CreditDetailsScreen extends StatefulWidget {
  final SearchCreditEntry credit;

  const CreditDetailsScreen({
    super.key,
    required this.credit,
  });

  @override
  State<CreditDetailsScreen> createState() => _CreditDetailsScreenState();
}

class _CreditDetailsScreenState extends State<CreditDetailsScreen> {
  bool showTransaction = true;
  bool showParty = false;
  bool showReference = false;
  bool showMisc = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: "Credit Details",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
      ),
      body: SafeArea(
        child: Container(
          color: AppColors.bodyFillColor,
          child:  SingleChildScrollView(
            padding: const EdgeInsets.all(15),
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

                      const SizedBox(height: 15),

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

                      const SizedBox(height: 15),

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

                      const SizedBox(height: 15),

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