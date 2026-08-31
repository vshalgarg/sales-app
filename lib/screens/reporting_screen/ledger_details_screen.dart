import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../provider/reporting_provider/ledger_provider.dart';

class LedgerDetailsScreen extends StatelessWidget {
  final String viewType;

  const LedgerDetailsScreen({
    super.key,
    required this.viewType,
  });

  @override
  Widget build(BuildContext context) {
    final ledgerProvider = context.watch<LedgerProvider>();
    final ledger = ledgerProvider.ledger;

    if (ledger == null) {
      return Scaffold(
        backgroundColor: AppColors.bodyFillColor,
        appBar: AppBar(
          title: const Text("Ledger"),
        ),
        body: const Center(
          child: Text(
            "No ledger data found",
          ),
        ),
      );
    }

    final entries = ledger.entries ?? [];

    double totalDebit = 0;
    double totalCredit = 0;

    for (final item in entries) {
      totalDebit +=
          double.tryParse(
            item.debit?.toString() ?? "0",
          ) ??
              0;

      totalCredit +=
          double.tryParse(
            item.credit?.toString() ?? "0",
          ) ??
              0;
    }

    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,

      appBar: AppBar(
        backgroundColor: AppColors.bodyFillColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Ledger",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [


            // CUSTOMER / SUPPLIER DETAILS

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  // Header
                  Row(
                    children: [
                      Container(
                        padding:
                        const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors
                              .primaryPurple
                              .withOpacity(0.10),
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          size: 18,
                          color:
                          AppColors.primaryPurple,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        viewType == "CUSTOMER"
                            ? "Supplier Details"
                            : "Customer Details",
                        style: TextStyle(
                          color:
                          AppColors.primaryPurple,
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Divider(
                    color: Colors.grey.shade200,
                    height: 1,
                  ),

                  const SizedBox(height: 10),

                  // Name + Mobile
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Expanded(
                        child: _InfoItem(
                          title: "Name",
                          value:
                          ledger.party?.name ??
                              "",
                        ),
                      ),

                      Expanded(
                        child: _InfoItem(
                          title: "Mobile",
                          value:
                          ledger.party?.phone ??
                              "",
                        ),
                      ),
                    ],
                  ),

                  // Email
                  if (ledger.party?.email != null &&
                      ledger.party!.email!
                          .trim()
                          .isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets.only(
                        top: 5,
                      ),
                      child: _InfoItem(
                        title: "Email",
                        value:
                        ledger.party!.email!,
                      ),
                    ),
                SizedBox(height:5),
                  // GST
                  if (ledger.party?.gstNo != null &&
                      ledger.party!.gstNo!
                          .trim()
                          .isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets.only(
                        top: 5,
                      ),
                      child: _InfoItem(
                        title: "GST No.",
                        value:
                        ledger.party!.gstNo!,
                      ),
                    ),
                  SizedBox(height:5),
                  // Address
                  if (ledger.party?.address != null &&
                      ledger.party!.address!
                          .trim()
                          .isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets.only(
                        top: 5,
                      ),
                      child: _InfoItem(
                        title: "Address",
                        value:
                        ledger.party!.address!,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),


            // LEDGER TRANSACTIONS

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  // Header
                  Row(
                    children: [
                      Container(
                        padding:
                        const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors
                              .primaryPurple
                              .withOpacity(0.10),
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          size: 18,
                          color:
                          AppColors.primaryPurple,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        "Ledger Transactions",
                        style: TextStyle(
                          color:
                          AppColors.primaryPurple,
                          fontSize: 15,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (entries.isEmpty)
                    const Padding(
                      padding:
                      EdgeInsets.symmetric(
                        vertical: 30,
                      ),
                      child: Center(
                        child: Text(
                          "No transactions found",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(
                      entries.length,
                          (index) {
                        final item =
                        entries[index];

                        final debit =
                            double.tryParse(
                              item.debit
                                  ?.toString() ??
                                  "0",
                            ) ??
                                0;

                        final credit =
                            double.tryParse(
                              item.credit
                                  ?.toString() ??
                                  "0",
                            ) ??
                                0;

                        return _TransactionCard(
                          item: item,
                          debit: debit,
                          credit: credit,
                        );
                      },
                    ),

                  if (entries.isNotEmpty)
                    const SizedBox(height: 4),


                  // TOTALS
                  if (entries.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors
                            .primaryPurple
                            .withOpacity(0.08),
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [

                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Total Debit (₹)",
                                  style:
                                  TextStyle(
                                    fontSize: 10,
                                    color: AppColors
                                        .primaryPurple,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  _formatAmount(
                                    totalDebit,
                                  ),
                                  style:
                                  TextStyle(
                                    fontSize: 15,
                                    color: AppColors
                                        .primaryPurple,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            height: 38,
                            width: 1,
                            color:
                            Colors.grey.shade300,
                          ),

                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  "Total Credit (₹)",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                    Colors.green,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  _formatAmount(
                                    totalCredit,
                                  ),
                                  style:
                                  const TextStyle(
                                    fontSize: 15,
                                    color:
                                    Colors.green,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatAmount(
      double value,
      ) {
    return "₹${value.toStringAsFixed(0)}";
  }
}

  // INFO ITEM

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _InfoItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primaryPurple,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}


// TRANSACTION CARD

class _TransactionCard
    extends StatelessWidget {
  final dynamic item;
  final double debit;
  final double credit;

  const _TransactionCard({
    required this.item,
    required this.debit,
    required this.credit,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(bottom: 7),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        borderRadius:
        BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [

          // Calendar icon
          Container(
            padding:
            const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors
                  .primaryPurple
                  .withOpacity(0.08),
              borderRadius:
              BorderRadius.circular(7),
            ),
            child: Icon(
              Icons.calendar_month,
              color:
              AppColors.primaryPurple,
              size: 17,
            ),
          ),

          const SizedBox(width: 7),

          // Date + Invoice
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  item.date == null || item.date.toString().isEmpty
                      ? "-"
                      : DateFormat("dd-MM-yyyy").format(
                    DateTime.parse(item.date.toString()),
                  ),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  item.invoiceNo?.toString() ??
                      "",
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Particular
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                const Text(
                  "Particular",
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  item.particular
                      ?.toString() ??
                      "",
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight:
                    FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Debit
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [

                const Text(
                  "Debit (₹)",
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _format(debit),
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.blue,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          // Credit
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [

                const Text(
                  "Credit (₹)",
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  _format(credit),
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.green,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 3),

          const Icon(
            Icons.chevron_right,
            size: 18,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  String _format(
      double value,
      ) {
    return "₹${value.toStringAsFixed(0)}";
  }
}