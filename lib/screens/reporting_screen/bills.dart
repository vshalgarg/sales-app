import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../provider/search_bill_provider.dart';
import '../../reporting_widgets/bill_details_screen.dart';
import '../../reporting_widgets/edit_bill_screen.dart';
import '../../reporting_widgets/reporting_card.dart';
import '../../customs/app_bar.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../reporting_widgets/reporting_filter_section.dart';
import '../../services/bills_detail_api.dart';
import '../entry_screen/entries_bill_entry.dart';
import '../home_screen.dart';

class Bills extends StatefulWidget {
  const Bills({super.key});

  @override
  State<Bills> createState() => _BillsState();
}

class _BillsState extends State<Bills> {
  final ScrollController _scrollController = ScrollController();
  bool _showGoToTop = false;
  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();
  int page = 0;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? selectedSupplier;
  String? selectedCustomer;
  bool isOpening = false;

  @override
  void initState() {
    super.initState();
    final billsProvider = context.read<BillsProvider>();
    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10));

    final formatter = DateFormat('yyyy-MM-dd');

    fromDateController.text = formatter.format(tenDaysAgo);
    toDateController.text = formatter.format(now);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await billsProvider.fetchBills(
        page: page,
        fromDate: fromDateController.text,
        toDate: toDateController.text,
      );
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (isLoadingMore || !hasMore) return;

    setState(() {
      isLoadingMore = true;
    });

    page++;

    final provider = context.read<BillsProvider>();

    final fetched = await provider.fetchBills(
      page: page,
      fromDate: fromDateController.text,
      toDate: toDateController.text,
      isLoadMore: true,
    );

    if (!fetched) {
      hasMore = false;
    }

    setState(() {
      isLoadingMore = false;
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.offset > 300) {
      if (!_showGoToTop) {
        setState(() => _showGoToTop = true);
      }
    } else {
      if (_showGoToTop) {
        setState(() => _showGoToTop = false);
      }
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _showBillDetails(String billNumber) async {
    final data = await getBillDetails(billNumber);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BillDetailsScreen(data: data),
      ),
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
    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10));
    final formatter = DateFormat('yyyy-MM-dd');

    setState(() {
      fromDateController.text = formatter.format(tenDaysAgo);
      toDateController.text = formatter.format(now);

      selectedSupplier = null;
      selectedCustomer = null;
    });
    context.read<BillsProvider>().fetchBills(
      fromDate: fromDateController.text,
      toDate: toDateController.text,
    );
  }

  void _showFilterBottomSheet() {
    final provider = Provider.of<EntriesProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, bottomSheetSetState) {
            return Container(
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

            _clearFilters();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        title: "Bills",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
            onPressed: () {
              _showFilterBottomSheet();
            },
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
                child: const Icon(Icons.keyboard_arrow_up,
                color: Color(0xFFFFFFFF),),
              ),
            ),

          FloatingActionButton(
            heroTag: "add",
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            backgroundColor: AppColors.primaryPurple,
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
                      MaterialPageRoute(
                        builder: (_) => const EntriesBillEntry(),
                      ),
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
                : const Icon(Iconsax.add, color: Colors.white, size: 40),
          ),
        ],
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
                        controller: _scrollController,
                        itemCount:
                            billProvider.bills.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= billProvider.bills.length) {
                            return billProvider.isLoadingMore
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }
                          final bill = billProvider.bills[index];

                          return Padding(
                            padding: EdgeInsets.only(bottom: height * 0.015),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return ReportingCard(
                                  leadingIcon: Iconsax.document,
                                  title: "Bill No : ",
                                  value: bill.billNumber ?? "-",

                                  chips: [
                                    ReportChip(
                                      icon: Iconsax.calendar,
                                      text: bill.date ?? "-",
                                    ),
                                  ],

                                  fields: [
                                    ReportField(
                                      icon: Iconsax.shop,
                                      label: "Supplier",
                                      value: bill.supplierName ?? "-",
                                    ),
                                    ReportField(
                                      icon: Iconsax.user,
                                      label: "Customer",
                                      value: bill.customerName ?? "-",
                                    ),
                                  ],

                                  amount: (bill.billAmount ?? 0).toString(),

                                  onTap: () async {
                                    await _showBillDetails(bill.billNumber);
                                  },

                                  onEdit: () async {
                                    try {
                                      final billDetails = await getBillDetails(bill.billNumber);

                                      if (!context.mounted) return;

                                      final billsProvider = context.read<BillsProvider>();
                                      final messenger = ScaffoldMessenger.of(context);

                                      final updated = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditBillScreen(
                                            billData: billDetails,
                                          ),
                                        ),
                                      );

                                      if (updated == true) {
                                        await billsProvider.fetchBills(
                                          page: 0,
                                          fromDate: fromDateController.text,
                                          toDate: toDateController.text,
                                        );

                                        if (!mounted) return;

                                        setState(() {});

                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text("Bill Updated Successfully"),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      debugPrint("REFRESH ERROR => $e");
                                    }
                                  },
                                  onDelete: () async {
                                    ExitConfirmationDialog.show(
                                      context,
                                      bodyText:
                                          "Are you sure you want to delete this bill?",
                                      saveButtonText: "Delete",
                                      discardButtonText: "Cancel",

                                      onClose: () {
                                        Navigator.pop(context);
                                      },

                                      onDiscard: () {
                                        Navigator.pop(context);
                                      },

                                      onSave: () async {
                                        Navigator.pop(context);

                                        final success = await context
                                            .read<BillsProvider>()
                                            .deleteBill(bill.billNumber);

                                        if (!mounted) return;

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success
                                                  ? "Bills deleted successfully"
                                                  : "Failed to delete retail",
                                            ),
                                          ),
                                        );
                                      },
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
              ],
            );
          },
        ),
      ),
    );
  }
}
