import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../provider/search_bill_provider.dart';
import '../../reporting_widgets/bill_details_bottom_sheet.dart';
import '../../reporting_widgets/edit_bill_bottom_sheet.dart';
import '../../reporting_widgets/reporting_card.dart';
import '../../customs/app_bar.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../reporting_widgets/reporting_filter_section.dart';
import '../../services/bills_detail_api.dart';
import '../../services/delete_bills_api.dart';
import '../entry_screen/entries_bill_entry.dart';

class Bills extends StatefulWidget {
  const Bills({super.key});

  @override
  State<Bills> createState() => _BillsState();
}

class _BillsState extends State<Bills> {
  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();

  String? selectedSupplier;
  String? selectedCustomer;
  bool isOpening = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = Provider.of<EntriesProvider>(context, listen: false);
      await provider.fetchSuppliers();
      await provider.fetchCustomer();
      Future.microtask(() async {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<BillsProvider>().fetchBills(
            fromDate: fromDateController.text,
            toDate: toDateController.text,);
        });
      });
    });
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  Future<void> _showBillDetails(String billNumber) async {
    final data = await getBillDetails(billNumber);

    if (!mounted) return;
    debugPrint("VIEW DATA => $data");
    debugPrint("VIEW ITEMS => ${data['items']}");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,

      builder: (context) => BillDetailsBottomSheet(data: data),
    );
  }

  Future<void> _applyFilters() async {
    await Provider.of<BillsProvider>(context, listen: false).fetchBills(
      fromDate: fromDateController.text,
      toDate: toDateController.text,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Filters Applied")));
  }

  void _clearFilters() {
    setState(() {
      fromDateController.clear();
      toDateController.clear();

      selectedSupplier = null;
      selectedCustomer = null;
    });
  }

  void _showFilterBottomSheet() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final provider = Provider.of<EntriesProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, bottomSheetSetState) {
            return Container(
              height: 500,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F6FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
                  child: ReportingFilterSection(
                    fromDateController: fromDateController,
                    toDateController: toDateController,

                    dropdowns: [
                      FilterDropdown(
                        label: "Supplier",
                        value: selectedSupplier,
                        items: provider.entries
                            .map((e) => e.supplierName ?? '')
                            .where((e) => e.isNotEmpty)
                            .toList(),
                        onChanged: (value) {
                          bottomSheetSetState(() {
                            selectedSupplier = value;
                          });

                          setState(() {
                            selectedSupplier = value;
                          });
                        },
                      ),

                      FilterDropdown(
                        label: "Customer",
                        value: selectedCustomer,
                        items: provider.customerEntries
                            .map((e) => e.customerName ?? '')
                            .where((e) => e.isNotEmpty)
                            .toList(),
                        onChanged: (value) {
                          bottomSheetSetState(() {
                            selectedCustomer = value;
                          });

                          setState(() {
                            selectedCustomer = value;
                          });
                        },
                      ),
                    ],

                    onApply: () {
                      Navigator.pop(context);
                      _applyFilters();
                    },

                    onClear: () {
                      bottomSheetSetState(() {
                        fromDateController.clear();
                        toDateController.clear();

                        selectedSupplier = null;
                        selectedCustomer = null;
                      });

                      setState(() {
                        fromDateController.clear();
                        toDateController.clear();

                        selectedSupplier = null;
                        selectedCustomer = null;
                      });
                    },
                  ),

              );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,

      appBar: CustomAppBar(
        title: "Bills",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: width < 600 ? 22 : 26,
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: isOpening
            ? null
            : () async {
                setState(() {
                  isOpening = true;
                });
                await Future.delayed(const Duration(milliseconds: 100));

                if (!mounted) return;

                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EntriesBillEntry()),
                );

                if (mounted) {
                  setState(() {
                    isOpening = false;
                  });
                }
              },
        child: isOpening
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add, color: Color(0xFF9CA4DA)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.015,
        ),
        child: Consumer<EntriesProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.white,
                    ),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          final provider = context.read<EntriesProvider>();

                          await provider.fetchSuppliers();
                          await provider.fetchCustomer();

                          if (!mounted) return;

                          Navigator.pop(context);

                          _showFilterBottomSheet();
                        } catch (e) {
                          if (!mounted) return;

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to load filters: $e"),
                            ),
                          );
                        }
                      },
                    ),
                )],
                ),

                SizedBox(height: height * 0.02),

                Expanded(
                  child: Consumer<BillsProvider>(
                    builder: (context, billProvider, child) {
                      if (billProvider.isBillsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (billProvider.bills.isEmpty) {
                        return Center(
                          child: Text(
                            "Apply filters to view bill history",
                            style: TextStyle(
                              fontSize: width * 0.06,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: billProvider.bills.length,
                        itemBuilder: (context, index) {
                          final bill = billProvider.bills[index];

                          return Padding(
                            padding: EdgeInsets.only(bottom: height * 0.015),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return ReportingCard(
                                  fields: [
                                    MapEntry("Bill No", bill.billNumber),

                                    MapEntry("Date", bill.date),

                                    MapEntry("Amount", "₹${bill.billAmount}"),

                                    MapEntry("Supplier", bill.supplierName),

                                    MapEntry("Customer", bill.customerName),
                                  ],

                                  onView: () async {
                                    await _showBillDetails(bill.billNumber);
                                  },

                                  onEdit: () async {
                                    final billDetails = await getBillDetails(
                                      bill.billNumber,
                                    );

                                    if (!context.mounted) return;
                                    final billsProvider = context
                                        .read<BillsProvider>();
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    final updated = await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => EditBillBottomSheet(
                                        billData: billDetails,
                                      ),
                                    );

                                    debugPrint("UPDATED RESULT => $updated");

                                    if (updated == true) {
                                      try {
                                        await billsProvider.fetchBills(
                                          fromDate: "2026-01-01",
                                          toDate: "2026-12-31",
                                        );

                                        for (final bill
                                            in billsProvider.bills) {
                                        }

                                        if (!mounted) return;

                                        setState(() {});

                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Bill Updated Successfully",
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        debugPrint("REFRESH ERROR => $e");
                                      }
                                    }
                                  },
                                  onDelete: () async {
                                    try {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Delete Bill"),
                                            content: Text(
                                              "Delete ${bill.billNumber} ?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                                child: const Text("Cancel"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context, true);
                                                },
                                                child: const Text("Delete"),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirm != true) return;

                                      await deleteBill(bill.billNumber);

                                      if (!mounted) return;

                                      await context
                                          .read<BillsProvider>()
                                          .fetchBills(
                                            fromDate: fromDateController.text,
                                            toDate: toDateController.text,
                                          );
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Bill deleted successfully",
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text("Delete failed: $e"),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
