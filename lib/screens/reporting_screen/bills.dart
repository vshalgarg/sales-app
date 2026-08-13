import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/enums/customer_mode.dart';
import 'package:hisabio/pop_ups/general_closing_popup.dart';
import 'package:hisabio/pop_ups/scafold_type.dart';
import 'package:hisabio/provider/reporting_provider/bill_provider.dart';
import 'package:hisabio/provider/entries_provider/entries_section_provider.dart';
import 'package:hisabio/reporting_widgets/reporting_card.dart';
import 'package:hisabio/reporting_widgets/reporting_filter_section.dart';
import 'package:hisabio/screens/entry_screen/entries_bill_entry.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../model_classes/bills/bill.dart';
import '../../pagination/pagination_widget.dart';

class Bills extends StatefulWidget {
  const Bills({super.key});

  @override
  State<Bills> createState() => _BillsState();
}

class _BillsState extends State<Bills> {
  final TextEditingController fromDateController =
  TextEditingController();

  final TextEditingController toDateController =
  TextEditingController();

  bool isFilterApplied = false;

  bool isOpening = false;

  String? selectedSupplier;

  String? selectedCustomer;

  int? selectedSupplierId;

  int? selectedCustomerId;

  List<String> supplierItems = [];

  List<String> customerItems = [];

  void _showBottomSheetSnackBar(BuildContext context,
      String message,) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) =>
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.containerFillColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      entry.remove();
    });
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10));

    final formatter = DateFormat("yyyy-MM-dd");

    fromDateController.text = formatter.format(tenDaysAgo);
    toDateController.text = formatter.format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final billProvider = context.read<BillProvider>();

      billProvider.setFromDate(fromDateController.text);
      billProvider.setToDate(toDateController.text);

      // Start bills immediately
      await billProvider.fetchInitialBills();

      if (!mounted) return;

      // Load filter data separately
      final entriesProvider = context.read<EntriesProvider>();

      await Future.wait([
        entriesProvider.fetchSuppliers(),
        entriesProvider.fetchCustomer(),
      ]);
    });
  }
  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();

    super.dispose();
  }
  Future<void> _showBillDetails(String billNumber) async {
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EntriesBillEntry(
              mode: FormMode.view,
              id: billNumber,
            ),
      ),
    );
  }

  Future<void> _applyFilters() async {
    final entriesProvider =
    context.read<EntriesProvider>();

    final billProvider =
    context.read<BillProvider>();

    int? supplierId;
    int? customerId;

    if (selectedSupplier != null) {
      final supplier = entriesProvider.entries.firstWhere(
            (e) => e.supplierName == selectedSupplier,
      );

      supplierId = supplier.id?.toInt();
    }

    if (selectedCustomer != null) {
      final customer =
      entriesProvider.customerEntries.firstWhere(
            (e) => e.customerName == selectedCustomer,
      );

      customerId = customer.id?.toInt();
    }

    billProvider.setFromDate(
      fromDateController.text.isEmpty
          ? null
          : fromDateController.text,
    );

    billProvider.setToDate(
      toDateController.text.isEmpty
          ? null
          : toDateController.text,
    );

    billProvider.setSupplierId(supplierId);

    billProvider.setCustomerId(customerId);

    setState(() {
      isFilterApplied = true;
    });

    await billProvider.refresh();
  }

  Future<void> _clearFilters() async {
    setState(() {
      fromDateController.clear();
      toDateController.clear();

      selectedSupplier = null;
      selectedCustomer = null;
      isFilterApplied = false;
    });

    final provider = context.read<BillProvider>();

    provider.setFromDate(null);
    provider.setToDate(null);
    provider.setSupplierId(null);
    provider.setCustomerId(null);

    await provider.refresh();
  }
  void _showFilterBottomSheet() {
    final provider =
    context.read<EntriesProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(40),
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
                        .map((e) => e.supplierName ?? "")
                        .where((e) => e.isNotEmpty)
                        .toList(),
                    onChanged: (value) {
                      setBottomState(() {
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
                        .map((e) => e.customerName ?? "")
                        .where((e) => e.isNotEmpty)
                        .toList(),
                    onChanged: (value) {
                      setBottomState(() {
                        selectedCustomer = value;
                      });

                      setState(() {
                        selectedCustomer = value;
                      });
                    },
                  ),
                ],
                onApply: () async {
                  final hasFilter =
                      fromDateController.text.isNotEmpty ||
                          toDateController.text.isNotEmpty ||
                          selectedSupplier != null ||
                          selectedCustomer != null;

                  if (!hasFilter) {
                    _showBottomSheetSnackBar(
                      context,
                      "Please select at least one filter.",
                    );
                    return;
                  }

                  Navigator.pop(context);

                  await _applyFilters();
                },
                onClear: () async {
                  await _clearFilters();

                  setBottomState(() {});
                },
              ),
            );
          },
        );
      },
    );
  }
  Future<void> _resetBillsBeforeExit() async {
    final provider = context.read<BillProvider>();

    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10));
    final formatter = DateFormat("yyyy-MM-dd");

    final fromDate = formatter.format(tenDaysAgo);
    final toDate = formatter.format(now);

    // Reset screen filter values
    selectedSupplier = null;
    selectedCustomer = null;
    selectedSupplierId = null;
    selectedCustomerId = null;
    isFilterApplied = false;

    fromDateController.text = fromDate;
    toDateController.text = toDate;

    // Reset provider filter values
    provider.setFromDate(fromDate);
    provider.setToDate(toDate);
    provider.setSupplierId(null);
    provider.setCustomerId(null);

    // Remove the currently filtered cards
    provider.clear();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    final width = size.width;
    final height = size.height;

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          await _resetBillsBeforeExit();

          if (!mounted) return;

          Navigator.pop(context);
        },
        child: Scaffold(
      backgroundColor: AppColors.bodyFillColor,

      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: "Bills",
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: Colors.white,
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: isOpening
            ? null
            : () async {
          setState(() {
            isOpening = true;
          });

          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EntriesBillEntry(),
            ),
          );

          if (!mounted) return;

          if (refresh == true) {
            await context.read<BillProvider>().refresh();
          }

          setState(() {
            isOpening = false;
          });
        },
        child: isOpening
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(
          Iconsax.add,
          color: Colors.white,
          size: 34,
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.015,
        ),
        child: Consumer<BillProvider>(
          builder: (context, provider, child) {
            return PaginationWidget<Bill>(
              pagination: provider.pagination,

              items: provider.data.items,

              loading: provider.loading,

              fetchPage: (page) async {
                await provider.fetchPage(page);
              },

              refresh: () async {
                await provider.refresh();
              },

              itemBuilder: (context, bill) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: height * 0.015,
                  ),
                  child: ReportingCard(
                    leadingIcon: Iconsax.document,

                    title: "Invoice :",

                    value: bill.invoiceNo ?? "",

                    chips: [
                      ReportChip(
                        icon: Iconsax.calendar,
                        text: bill.date ?? "",
                      ),
                    ],

                    fields: [
                      ReportField(
                        icon: Iconsax.shop,
                        label: "Supplier",
                        value: bill.supplierName ?? "",
                      ),

                      ReportField(
                        icon: Iconsax.user,
                        label: "Customer",
                        value: bill.customerName ?? "",
                      ),
                    ],

                    amount: bill.billAmount?.toString(),

                    deleteWithAmount: true,

                    onTap: () async {
                      await _showBillDetails(
                        bill.billNumber ?? "",
                      );
                    },

                    onEdit: () async {
                       final refresh =
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EntriesBillEntry(
                                mode: FormMode.edit,
                                id: bill.billNumber,
                              ),
                        ),
                      );

                      if (!mounted) return;

                      if (refresh == true) {
                        await provider.refresh();
                      }
                    },

                    onDelete: () async {
                      ExitConfirmationDialog.show(
                        context,
                        bodyText:
                        "Are you sure you want to delete this bill?",

                        saveButtonText: "Yes",

                        discardButtonText: "No",

                        onDiscard: () {
                          Navigator.pop(context);
                        },

                        onSave: () async {
                          Navigator.pop(context);
                          final success =
                          await provider.deleteBill(
                            bill.billNumber ?? "",
                          );

                          if (success) {
                            await provider.refresh();
                          }

                          if (!mounted) return;

                          ScaffoldSnackBar.show(
                            context,
                            success
                                ? "Bill deleted successfully"
                                : "Failed to delete bill",
                          );
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
    )
    );
  }
}