import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';
import '../../enums/customer_mode.dart';
import '../../model_classes/purchases/purchase.dart';
import '../../pagination/pagination_widget.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/reporting_provider/purchase_provider.dart';
import '../../reporting_widgets/reporting_card.dart';
import '../../reporting_widgets/reporting_filter_section.dart';
import '../entry_screen/purchase_entry.dart';

class Purchases extends StatefulWidget {
  const Purchases({super.key});

  @override
  State<Purchases> createState() => _PurchasesState();
}

class _PurchasesState extends State<Purchases> {
  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();

  bool isFilterApplied = false;

  bool isOpening = false;

  String? selectedSupplier;

  String? selectedCustomer;

  int? selectedSupplierId;

  int? selectedCustomerId;

  int? selectedStaffId;

  List<String> supplierItems = [];

  List<String> customerItems = [];

  String _toApiDate(String date) {
    if (date.isEmpty) return date;

    final parsed = DateFormat("dd-MM-yyyy").parse(date);
    return DateFormat("yyyy-MM-dd").format(parsed);
  }
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    final tenDaysAgo = now.subtract(const Duration(days: 10));

    final formatter = DateFormat("dd-MM-yyyy");

    final defaultFromDate = formatter.format(tenDaysAgo);
    final defaultToDate = formatter.format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;

      final entriesProvider = context.read<EntriesProvider>();

      final provider = context.read<PurchaseProvider>();

      await entriesProvider.fetchSuppliers();

      await entriesProvider.fetchCustomer();

      provider.setFromDate(_toApiDate(defaultFromDate));
      provider.setToDate(_toApiDate(defaultToDate));

      await provider.fetchInitial();
    });
  }

  @override
  void dispose() {
    fromDateController.dispose();

    toDateController.dispose();

    super.dispose();
  }

  void _showBottomSheetSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 16,
        right: 16,
        bottom: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }

  Future<void> _applyFilters() async {
    final entriesProvider = context.read<EntriesProvider>();

    final provider = context.read<PurchaseProvider>();

    int? supplierId;

    int? customerId;

    if (selectedSupplier != null) {
      final supplier = entriesProvider.entries.firstWhere(
        (e) => e.supplierName == selectedSupplier,
      );

      supplierId = supplier.id?.toInt();
    }

    if (selectedCustomer != null) {
      final customer = entriesProvider.customerEntries.firstWhere(
        (e) => e.customerName == selectedCustomer,
      );

      customerId = customer.id?.toInt();
    }

    if (fromDateController.text.isNotEmpty) {
      provider.setFromDate(
        _toApiDate(fromDateController.text),
      );
    }

    if (toDateController.text.isNotEmpty) {
      provider.setToDate(
        _toApiDate(toDateController.text),
      );
    }

    provider.setSupplierId(supplierId);

    provider.setCustomerId(customerId);

    provider.setStaffId(selectedStaffId);

    setState(() {
      isFilterApplied = true;
    });

    await provider.refresh();
  }

  Future<void> _clearFilters() async {
    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10));
    final formatter = DateFormat("dd-MM-yyyy");
    setState(() {
      fromDateController.clear();
      toDateController.clear();
      selectedSupplier = null;
      selectedCustomer = null;
      selectedSupplierId = null;
      selectedCustomerId = null;
      selectedStaffId = null;
      isFilterApplied = false;
    });

    final provider = context.read<PurchaseProvider>();

    provider.setFromDate(
      _toApiDate(formatter.format(tenDaysAgo)),
    );

    provider.setToDate(
      _toApiDate(formatter.format(now)),
    );

    provider.setSupplierId(null);

    provider.setCustomerId(null);

    provider.setStaffId(null);

    await provider.refresh();
  }

  void _showFilterBottomSheet() {
    final entriesProvider = context.read<EntriesProvider>();

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
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: ReportingFilterSection(
                fromDateController: fromDateController,
                toDateController: toDateController,
                dropdowns: [
                  FilterDropdown(
                    label: "Supplier",
                    value: selectedSupplier,
                    items: entriesProvider.entries
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
                    items: entriesProvider.customerEntries
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

  Future<void> _resetPurchaseBeforeExit() async {
    final provider = context.read<PurchaseProvider>();

    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10));
    final formatter = DateFormat("dd-MM-yyyy");

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
    provider.setFromDate(_toApiDate(fromDate));
    provider.setToDate(_toApiDate(toDate));
    provider.setSupplierId(null);
    provider.setCustomerId(null);

    provider.clear();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final width = size.width;

    final height = size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        await _resetPurchaseBeforeExit();

        if (!context.mounted) return;

        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.bodyFillColor,

        appBar: CustomAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _resetPurchaseBeforeExit();

              if (!context.mounted) return;

              Navigator.pop(context);
            },
          ),
          title: "Purchases",
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
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
                      builder: (_) => const PurchaseEntryScreen(),
                    ),
                  );
                  log("Navigator returned: $refresh");
                  if (!context.mounted) {
                    return;
                  }
                  if (refresh == true) {
                    log("Navigator returned: $refresh");
                    await context.read<PurchaseProvider>().refresh();
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
              : const Icon(Iconsax.add, color: Colors.white, size: 34),
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: height * 0.015,
          ),
          child: Consumer<PurchaseProvider>(
            builder: (context, provider, child) {
              return PaginationWidget<Purchase>(
                pagination: provider.pagination,

                items: provider.data.items,

                loading: provider.loading,

                fetchPage: (page) async {
                  await provider.fetchPage(page);
                },

                refresh: () async {
                  await provider.refresh();
                },

                itemBuilder: (context, purchase) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: height * 0.015),
                    child: ReportingCard(
                      showHeader: false,

                      chips: [
                        ReportChip(
                          icon: Iconsax.calendar,
                          text: purchase.date ?? "",
                        ),
                      ],

                      fields: [
                        ReportField(
                          icon: Iconsax.profile_2user,
                          label: "Staff",
                          value: purchase.staffName ?? "",
                        ),

                        ReportField(
                          icon: Iconsax.shop,
                          label: "Supplier",
                          value: purchase.supplierName ?? "",
                        ),

                        ReportField(
                          icon: Iconsax.user,
                          label: "Customer",
                          value: purchase.customerName ?? "",
                        ),

                        ReportField(
                          icon: Iconsax.note,
                          label: "Remarks",
                          value: purchase.remarks ?? "",
                        ),
                      ],

                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PurchaseEntryScreen(
                              mode: FormMode.view,
                              id: purchase.id,
                            ),
                          ),
                        );
                      },

                      onEdit: () async {
                        final refresh = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PurchaseEntryScreen(
                              mode: FormMode.edit,
                              id: purchase.id,
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
                          isDelete: true,
                            body: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                "Are you sure you want to delete this Purchase?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                          saveButtonText: "Delete",

                          discardButtonText: "Cancel",

                          onDiscard: () {
                            Navigator.pop(context);
                          },

                          onSave: () async {
                            Navigator.pop(context);

                            final success = await provider.deletePurchase(
                              purchase.id!,
                            );

                            if (success) {
                              await provider.refresh();
                            }

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldSnackBar.show(
                              context,
                              success
                                  ? "Purchase deleted successfully"
                                  : "Failed to delete purchase",
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
      ),
    );
  }
}
