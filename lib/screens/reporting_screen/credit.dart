import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../constants/colors_used.dart';
import '../../../../customs/app_bar.dart';
import '../../../../enums/customer_mode.dart';
import '../../../../pop_ups/general_closing_popup.dart';
import '../../../../pop_ups/scafold_type.dart';
import '../../../../reporting_widgets/reporting_card.dart';
import '../../../../reporting_widgets/reporting_filter_section.dart';
import '../../../../screens/home_screen.dart';
import '../../model_classes/credits/credit.dart';
import '../../pagination/pagination_widget.dart';
import '../../provider/reporting_provider/credit_provider.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../entry_screen/credit_entry.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();

  List<String> supplierItems = [];
  List<String> customerItems = [];

  String? selectedSupplier;
  String? selectedCustomer;

  bool isFilterApplied = false;

  bool _showGoToTop = false;

  bool isOpening = false;

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

    fromDateController.clear();
    toDateController.clear();

    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final entriesProvider = context.read<EntriesProvider>();

      final creditProvider = context.read<CreditProvider>();

      creditProvider.setFromDate(_toApiDate(defaultFromDate));
      creditProvider.setToDate(_toApiDate(defaultToDate));

      await creditProvider.refreshCredits();

      await Future.wait([
        entriesProvider.fetchSuppliers(),
        entriesProvider.fetchCustomer(),
      ]);

      supplierItems = entriesProvider.entries
          .map((e) => e.supplierName ?? "")
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();

      customerItems = entriesProvider.customerEntries
          .map((e) => e.customerName ?? "")
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();

      if (mounted) {
        setState(() {});
      }
    });
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.offset > 200) {
      if (!_showGoToTop) {
        setState(() {
          _showGoToTop = true;
        });
      }
    } else {
      if (_showGoToTop) {
        setState(() {
          _showGoToTop = false;
        });
      }
    }

    final provider = context.read<CreditProvider>();

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      provider.fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
                  child: Text(message, style: const TextStyle(fontSize: 14)),
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

    final creditProvider = context.read<CreditProvider>();

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
      creditProvider.setFromDate(
        _toApiDate(fromDateController.text),
      );
    }

    if (toDateController.text.isNotEmpty) {
      creditProvider.setToDate(
        _toApiDate(toDateController.text),
      );
    }

    creditProvider.setSupplierId(supplierId);

    creditProvider.setCustomerId(customerId);

    setState(() {
      isFilterApplied = true;
    });

    await creditProvider.refreshCredits();
  }

  Future<void> _clearFilters() async {
    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10));
    final formatter = DateFormat("dd-MM-yyyy");
    final creditProvider = context.read<CreditProvider>();

    setState(() {
      selectedSupplier = null;
      selectedCustomer = null;

      fromDateController.clear();
      toDateController.clear();

      isFilterApplied = false;
    });

    creditProvider.setFromDate(
      _toApiDate(formatter.format(tenDaysAgo)),
    );

    creditProvider.setToDate(
      _toApiDate(formatter.format(now)),
    );
    creditProvider.setSupplierId(null);
    creditProvider.setCustomerId(null);

    await creditProvider.refreshCredits();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
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
                    items: supplierItems,
                    onChanged: (value) {
                      setBottomState(() {
                        selectedSupplier = value;
                      });
                    },
                  ),

                  FilterDropdown(
                    label: "Customer",
                    value: selectedCustomer,
                    items: customerItems,
                    onChanged: (value) {
                      setBottomState(() {
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

  Future<void> _resetCreditsBeforeExit() async {
    final provider = context.read<CreditProvider>();

    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10));
    final formatter = DateFormat("dd-MM-yyyy");

    final fromDate = formatter.format(tenDaysAgo);
    final toDate = formatter.format(now);

    // Reset screen filter values
    selectedSupplier = null;
    selectedCustomer = null;
    selectedSupplier = null;
    selectedCustomer = null;
    isFilterApplied = false;

    fromDateController.text = fromDate;
    toDateController.text = toDate;

    // Reset provider filter values
    provider.setFromDate(_toApiDate(fromDate));
    provider.setToDate(_toApiDate(toDate));
    provider.setSupplierId(null);
    provider.setCustomerId(null);

    // Remove the currently filtered cards
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

        await _resetCreditsBeforeExit();

        if (!context.mounted) return;

        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.bodyFillColor,

        appBar: CustomAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              );
            },
          ),
          title: "Credits",
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

        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_showGoToTop)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FloatingActionButton.small(
                  heroTag: "top",
                  backgroundColor: AppColors.primaryPurple,
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white,
                  ),
                ),
              ),

            FloatingActionButton(
              heroTag: "add",
              backgroundColor: AppColors.primaryPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              onPressed: () async {
                if (isOpening) return;

                setState(() {
                  isOpening = true;
                });

                try {
                  final refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreditEntry(),
                    ),
                  );

                  if (refresh == true && mounted) {
                    final creditProvider = context.read<CreditProvider>();

                    log("========== CREDIT AUTO REFRESH ==========");
                    log("Before refresh: ${creditProvider.data.items.length}");

                    await creditProvider.refreshCredits();

                    if (!mounted) return;

                    log("After refresh: ${creditProvider.data.items.length}");
                    log(
                      "Cards: ${creditProvider.data.items.map((e) => e.billNumber).toList()}",
                    );
                    log("==========================================");
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      isOpening = false;
                    });
                  }
                }
              },
              child: isOpening
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Iconsax.add, color: Colors.white, size: 40),
            ),
          ],
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: height * 0.015,
          ),
          child: Consumer<CreditProvider>(
            builder: (context, provider, child) {
              return PaginationWidget<Credit>(
                pagination: provider.pagination,

                items: provider.data.items,

                loading: provider.loading,

                fetchPage: (page) async {
                  await provider.fetchPage(page);
                },

                refresh: () async {
                  await provider.refresh();
                },

                itemBuilder: (context, credit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ReportingCard(
                      leadingIcon: Iconsax.card,

                      title: "Invoice :",

                      value: credit.billNumber ?? "",

                      chips: [
                        ReportChip(
                          icon: Iconsax.calendar,
                          text: credit.date ?? "",
                        ),
                      ],

                      fields: [
                        ReportField(
                          icon: Iconsax.shop,
                          label: "Supplier",
                          value: credit.supplierName ?? "",
                        ),
                        ReportField(
                          icon: Iconsax.user,
                          label: "Customer",
                          value: credit.customerName ?? "",
                        ),
                      ],

                      amount: credit.receivedAmount.toString(),

                      deleteWithAmount: true,

                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreditEntry(
                              mode: FormMode.view,
                              credit: credit,
                            ),
                          ),
                        );
                      },

                      onEdit: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreditEntry(
                              mode: FormMode.edit,
                              credit: credit,
                            ),
                          ),
                        );
                        if (context.mounted) {
                          await context.read<CreditProvider>().refreshCredits();
                        }
                      },

                      onDelete: () async {
                        ExitConfirmationDialog.show(
                          context,
                          isDelete: true,
                          body: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (credit.billNumber != null &&
                                  credit.billNumber!.trim().isNotEmpty)
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text:
                                            "Are you sure you want to delete Credit :  ",
                                      ),
                                      TextSpan(
                                        text: credit.billNumber,
                                        style: const TextStyle(
                                          color: AppColors.orangeColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(text: "?"),
                                    ],
                                  ),
                                )
                              else
                                const Text(
                                  "Are you sure you want to delete this credit?",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                            ],
                          ),
                          saveButtonText: "Delete",
                          discardButtonText: "Cancel",
                          onDiscard: () {
                            Navigator.pop(context);
                          },
                          onSave: () async {
                            Navigator.pop(context);

                            final success = await provider.deleteCredit(
                              credit.id!.toInt(),
                            );

                            if (!context.mounted) return;

                            ScaffoldSnackBar.show(
                              context,
                              success
                                  ? "Credit deleted successfully"
                                  : "Failed to delete credit",
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
