import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/colors_used.dart';
import '../provider/retail_provider.dart';

class RetailDetailsBottomSheet extends StatefulWidget {
  final int retailId;

  const RetailDetailsBottomSheet({super.key, required this.retailId});

  @override
  State<RetailDetailsBottomSheet> createState() =>
      _RetailDetailsBottomSheetState();
}

class _RetailDetailsBottomSheetState extends State<RetailDetailsBottomSheet> {
  bool showRetailInfo = true;
  bool showHistory = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RetailDetailsProvider>().fetchRetailDetails(widget.retailId);
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

        final retail = provider?.retailDetails;

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
                      icon: const Icon(Icons.close,
                      color: Colors.white,),
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
                          border: Border.all(
                            color: const Color(0xFFD9D9D9),
                          ),
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
                                  });
                                },
                              ),
                            ),

                            if (showRetailInfo)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _infoItem(
                                            "Retailer",
                                            retail.name,

                                          ),
                                        ),
                                        Expanded(
                                          child: _infoItem("Date", retail.date),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 28),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _infoItem(
                                            "Referred By",
                                            retail.customerName,
                                          ),
                                        ),
                                        Expanded(
                                          child: _infoItem(
                                            "Staff",
                                            retail.staffName,
                                          ),
                                        ),
                                      ],
                                    ),
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
                                              "Total: ${formatAmount(supplier.totalAmount)}",
                                              Colors.grey,
                                            ),
                                            _chip(
                                              "Deposited: ${formatAmount(supplier.depositAmount)}",
                                              Colors.green,
                                            ),
                                            _chip(
                                              "Remaining: ${formatAmount(supplier.balanceAmount)}",
                                              supplier.balanceAmount > 0
                                                  ? Colors.deepOrange
                                                  : Colors.green,
                                            ),
                                          ],
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
            color:Color(0xFF6B6B6B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 14)),
    );
  }
}
