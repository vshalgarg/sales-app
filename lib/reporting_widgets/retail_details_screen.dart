import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/retailers/retail_details.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/colors_used.dart';
import '../customs/app_bar.dart';
import '../model_classes/retailers/retail_deposit_history_model.dart';
import '../provider/reporting_provider/retail_provider.dart';

class RetailDetailsScreen extends StatefulWidget {
  final int retailId;

  const RetailDetailsScreen({super.key, required this.retailId});

  @override
  State<RetailDetailsScreen> createState() => _RetailDetailsScreenState();
}

class _RetailDetailsScreenState extends State<RetailDetailsScreen> {
  int? expandedSupplierIndex;

  bool showRetailInfo = true;
  bool showHistory = true;
  final Map<int, GlobalKey> _historyKeys = {};
 // final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<RetailProvider>();

      await provider.fetchRetailDetails(widget.retailId);
      await provider.fetchDepositHistory(widget.retailId);
    });
  }
  @override
  void dispose() {
  //  _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<RetailProvider>(
      builder: (context, provider, child) {
        if (provider.detailsLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final retail = provider.retailDetails;

        if (retail == null) {
          return const Scaffold(body: Center(child: Text("No Data Found")));
        }

        return Scaffold(
          backgroundColor: AppColors.bodyFillColor,

          appBar: CustomAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),

            title: "View Retailers",

            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),

          body: SafeArea(
            child: SingleChildScrollView(
              //controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // Retail Information
                  _sectionHeader(
                    title: "Retail Information",
                    expanded: showRetailInfo,
                    onTap: () {
                      setState(() {
                        showRetailInfo = !showRetailInfo;
                      });
                    },
                  ),

                  if (showRetailInfo) ...[
                    const SizedBox(height: 16),

                    _infoItem("Retailer", retail.name),

                    const SizedBox(height: 15),

                    _infoItem(
                      "Date",
                      "${retail.date.day.toString().padLeft(2, "0")}-"
                          "${retail.date.month.toString().padLeft(2, "0")}-"
                          "${retail.date.year}",
                    ),

                    const SizedBox(height: 15),

                    _infoItem("Referred By", retail.customerName ?? "-"),

                    const SizedBox(height: 15),

                    _infoItem("Staff", retail.staffName ?? "-"),
                    const SizedBox(height: 15),

          _infoItem(
            "Commission",
            retail.commission ?? "-",
                    ),
                  ],

                  const SizedBox(height: 24),
                  //History
                  _sectionHeader(
                    title: "History",
                    expanded: showHistory,
                    onTap: () {
                      setState(() {
                        showHistory = !showHistory;
                      });
                    },
                  ),

                  if (showHistory) ...[
                    const SizedBox(height: 16),

                    ListView.builder(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: retail.suppliers.length,

                      itemBuilder: (context, index) {
                        final RetailSupplier supplier = retail.suppliers[index];

                        RetailDepositHistoryModel? history;
                        try {
                          history = provider.depositHistory.firstWhere(
                            (e) =>
                                e.retailSupplierId == supplier.retailSupplierId,
                          );
                        } catch (_) {
                          history = null;
                        }
                        return _buildHistoryCard(
                          supplier: supplier,
                          history: history,
                          retailDate: retail.date,
                          staffName: retail.staffName,
                          customerName: retail.customerName ?? "-",
                          index: index,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard({
    required RetailSupplier supplier,
    required dynamic history,
    required DateTime retailDate,
    required String? staffName,
    required String customerName,
    required int index,
  }) {
    final bool expanded = expandedSupplierIndex == index;
    final GlobalKey cardKey =
    _historyKeys.putIfAbsent(index, () => GlobalKey());
    return Card(
      key: cardKey,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xffF2EDFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: AppColors.primaryPurple,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.supplierName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 2,
                        ),
                      ),

                     // const SizedBox(height: 3),

                      // Text.rich(
                      //   TextSpan(
                      //     children: [
                      //       const TextSpan(
                      //         text: "Referred By : ",
                      //         style: TextStyle(fontWeight: FontWeight.w600),
                      //       ),
                      //       TextSpan(text: customerName),
                      //     ],
                      //   ),
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: TextStyle(
                      //     color: Colors.grey[700],
                      //     fontSize: 12,
                      //   ),
                      // ),
                      //
                      // Text.rich(
                      //   TextSpan(
                      //     children: [
                      //       const TextSpan(
                      //         text: "Staff : ",
                      //         style: TextStyle(fontWeight: FontWeight.w600),
                      //       ),
                      //       TextSpan(text: staffName ?? "-"),
                      //     ],
                      //   ),
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: TextStyle(
                      //     color: Colors.grey[700],
                      //     fontSize: 12,
                      //   ),
                      // ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFFF2E8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${retailDate.day.toString().padLeft(2, "0")}-"
                        "${retailDate.month.toString().padLeft(2, "0")}-"
                        "${retailDate.year}",
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade300, thickness: 1, height: 2),
            const SizedBox(height: 10),

            // Amount Cards
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Total",
                      value: "₹${supplier.totalAmount}",
                      color: Color(0xff3B5BDB),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: const Color(0xffE5E7EB),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.arrow_downward,
                      title: "Deposited",
                      value: "₹${supplier.depositAmount}",
                      color: const Color(0xff3B5BDB),
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 30,
                    color: const Color(0xffE5E7EB),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.arrow_upward,
                      title: "Remaining",
                      value: "₹${supplier.balanceAmount}",
                      color: const Color(0xff2E9E57),
                    ),
                  ),

                  InkWell(
                    onTap: () async {
                      if (expanded) {
                        setState(() {
                          expandedSupplierIndex = null;
                        });
                        return;
                      }

                      setState(() {
                        expandedSupplierIndex = index;
                      });

                      // Wait until the expanded content has been laid out.
                      await WidgetsBinding.instance.endOfFrame;

                      if (!mounted) return;

                      final cardContext = cardKey.currentContext;

                      if (cardContext != null) {
                        await Scrollable.ensureVisible(
                          cardContext,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          alignment: 0.05,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Icon(
                        expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (expanded) ...[
              SizedBox(height: 3),
              Row(
                children: [
                  Text(
                    "Deposits (${history?.deposits.length ?? 0})",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              if (history == null || history.deposits.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Center(
                    child: Text(
                      "No Deposit History",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              if (history != null && history.deposits.isNotEmpty)
                ...List.generate(history.deposits.length, (i) {
                  final deposit = history.deposits[i];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            // Date
                            SizedBox(
                              width: 120,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 16,
                                    color: AppColors.primaryPurple,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    deposit.date.isEmpty
                                        ? "-"
                                        : DateFormat("dd-MM-yyyy").format(
                                      DateTime.parse(deposit.date),
                                    ),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),

                            // Amount
                            SizedBox(
                              width: 110,
                              child: Text(
                                "₹${deposit.amount}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ),

                            // Status
                            // SizedBox(
                            //   width: 70,
                            //   child: Align(
                            //     alignment: Alignment.centerRight,
                            //     child: Container(
                            //       decoration: BoxDecoration(
                            //         color: const Color(0xffE8F7EE),
                            //         borderRadius: BorderRadius.circular(10),
                            //       ),
                            //       child: const Text(
                            //         "Deposited",
                            //         style: TextStyle(
                            //           color: Colors.green,
                            //           fontWeight: FontWeight.w600,
                            //           fontSize: 10,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 0.8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff6B7280),
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
          )
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader({
    required String title,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            AnimatedRotation(
              turns: expanded ? .5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),

        const SizedBox(height: 5),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            value.trim().isEmpty ? "-" : value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class DashedDivider extends StatelessWidget {
  final double height; // Thickness of the line
  final double dashWidth; // Length of each individual dash
  final double dashGap; // Empty space between dashes
  final Color color; // Color of the line

  const DashedDivider({
    super.key,
    this.height = 1.5,
    this.dashWidth = 8.0, // Longer width creates the dash effect
    this.dashGap = 4.0,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashGap)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
