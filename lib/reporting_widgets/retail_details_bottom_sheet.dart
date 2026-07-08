import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/colors_used.dart';
import '../model_classes/retail_deposit_history_model.dart';
import '../provider/retail_provider.dart';

class RetailDetailsBottomSheet extends StatefulWidget {
  final int retailId;

  const RetailDetailsBottomSheet({super.key, required this.retailId});

  @override
  State<RetailDetailsBottomSheet> createState() =>
      _RetailDetailsBottomSheetState();
}

class _RetailDetailsBottomSheetState extends State<RetailDetailsBottomSheet> {
  int? expandedSupplierIndex;
  bool showRetailInfo = true;
  bool showHistory = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RetailDetailsProvider>();

      provider.fetchRetailDetails(widget.retailId);
      provider.fetchDepositHistory(widget.retailId);
    });
  }

  String formatAmount(num amount) {
    return "₹${amount.toStringAsFixed(0)}";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RetailDetailsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SizedBox(
            height: 400,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final retail = provider.retailDetails;

        if (retail == null) {
          return const SizedBox(
            height: 400,
            child: Center(child: Text("No Data Found")),
          );
        }

        return Container(
          height: MediaQuery.of(context).size.height * .9,
          color: AppColors.bodyFillColor,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "View Retailer",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      /// Retail Info
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD9D9D9)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 55,
                              decoration: BoxDecoration(
                                color: Color(0xFF4057A6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                title: const Text(
                                  "Retailer Info",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: Icon(
                                  showRetailInfo
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                                onTap: () {
                                  setState(() {
                                    showRetailInfo = !showRetailInfo;

                                    if (showRetailInfo) {
                                      showHistory = false;
                                    }
                                  });
                                },
                              ),
                            ),

                            if (showRetailInfo)
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    _infoItem("Retailer", retail.name),
                                    const SizedBox(height: 16),

                                    _infoItem("Date", retail.date),
                                    const SizedBox(height: 16),

                                    _infoItem(
                                      "Referred By",
                                      retail.customerName,
                                    ),
                                    const SizedBox(height: 16),

                                    _infoItem("Staff", retail.staffName),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// History
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD9D9D9)),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 55,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4057A6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                title: const Text(
                                  "History",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: Icon(
                                  showHistory
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                                onTap: () {
                                  setState(() {
                                    showHistory = !showHistory;

                                    if (showHistory) {
                                      showRetailInfo = false;
                                    }
                                  });
                                },
                              ),
                            ),

                            if (showHistory)
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: retail.suppliers.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final supplier = retail.suppliers[index];

                                  final history = provider.depositHistory
                                      .firstWhere(
                                        (e) =>
                                            e.retailSupplierId ==
                                            supplier.retailSupplierId,
                                        orElse: () => RetailDepositHistoryModel(
                                          retailSupplierId:
                                              supplier.retailSupplierId,
                                          supplierId: supplier.supplierId,
                                          supplierName: supplier.supplierName,
                                          supplierCity: "",
                                          totalAmount: supplier.totalAmount,
                                          depositAmount: supplier.depositAmount,
                                          balanceAmount: supplier.balanceAmount,
                                          deposits: [],
                                        ),
                                      );
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          supplier.supplierName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: [
                                            _chip(
                                              title: "Total",
                                              value: "₹${supplier.totalAmount}",
                                              color: Colors.grey,
                                              onTap: () {
                                                setState(() {
                                                  expandedSupplierIndex =
                                                      expandedSupplierIndex ==
                                                          index
                                                      ? null
                                                      : index;
                                                });
                                              },
                                            ),
                                            _chip(
                                              title: "Deposited",
                                              value:
                                                  "₹${supplier.depositAmount}",
                                              color: Colors.green,
                                              onTap: () {
                                                setState(() {
                                                  expandedSupplierIndex =
                                                      expandedSupplierIndex ==
                                                          index
                                                      ? null
                                                      : index;
                                                });
                                              },
                                            ),
                                            _chip(
                                              title: "Remaining",
                                              value:
                                                  "₹${supplier.balanceAmount}",
                                              color: supplier.balanceAmount > 0
                                                  ? Colors.orange
                                                  : Colors.green,
                                              onTap: () {
                                                setState(() {
                                                  expandedSupplierIndex =
                                                      expandedSupplierIndex ==
                                                          index
                                                      ? null
                                                      : index;
                                                });
                                              },
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        AnimatedCrossFade(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          crossFadeState:
                                              expandedSupplierIndex == index
                                              ? CrossFadeState.showSecond
                                              : CrossFadeState.showFirst,
                                          firstChild: const SizedBox.shrink(),
                                          secondChild: Container(
                                            margin: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12,
                                                      ),
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFF4057A6),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                8,
                                                              ),
                                                          topRight:
                                                              Radius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                  ),
                                                  child: const Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          "Date",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "Deposit Amount",
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                history.deposits.isEmpty
                                                    ? const Padding(
                                                        padding: EdgeInsets.all(
                                                          16,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "No Deposit History",
                                                          ),
                                                        ),
                                                      )
                                                    : Column(
                                                        children: List.generate(
                                                          history
                                                              .deposits
                                                              .length,
                                                          (i) {
                                                            final deposit =
                                                                history
                                                                    .deposits[i];

                                                            return Column(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            16,
                                                                        vertical:
                                                                            12,
                                                                      ),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: Text(
                                                                          deposit.date.isEmpty
                                                                              ? "-"
                                                                              : deposit.date,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child: Text(
                                                                          "₹${deposit.amount}",
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                if (i !=
                                                                    history
                                                                            .deposits
                                                                            .length -
                                                                        1)
                                                                  const Divider(
                                                                    height: 1,
                                                                  ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FC),
            border: Border.all(color: const Color(0xFFD9D9D9)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip({
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: color, fontSize: 14),
            children: [
              TextSpan(
                text: "$title: ",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
