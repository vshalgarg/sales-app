import 'package:flutter/material.dart';
import 'package:hisabio/reporting_widgets/retail_details_screen.dart';
import 'package:hisabio/screens/add_supplier.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/retail_provider.dart';
import '../../provider/staff_provider.dart';
import '../../reporting_widgets/edit_retail_screen.dart';
import '../../reporting_widgets/reporting_filter_section.dart';
import '../../reporting_widgets/retail_card.dart';
import '../../screens/entry_screen/retail_entry.dart';
import '../home_screen.dart';

class Retail extends StatefulWidget {
  const Retail({super.key});

  @override
  State<Retail> createState() => _RetailState();
}

class _RetailState extends State<Retail> {
  final ScrollController _scrollController = ScrollController();

  int _page = 0;
  int _size = 20;

  String? selectedSupplier;
  String? selectedCustomer;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();
  int? selectedCustomerId;
  int? selectedStaffId;
  bool isOpening = false;
  bool _showGoToTop = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10));

    final formatter = DateFormat('yyyy-MM-dd');
    fromDateController.text = formatter.format(tenDaysAgo);
    toDateController.text = formatter.format(now);
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _page = 0;
      _hasMore = true;
      await context.read<StaffProvider>().fetchStaffs();
      await context.read<RetailProvider>().fetchRetails(
        page: _page,
        size: _size,
        fromDate: fromDateController.text,
        toDate: toDateController.text,
      );
    });
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.offset > 200) {
      if (!_showGoToTop) {
        setState(() => _showGoToTop = true);
      }
    } else {
      if (_showGoToTop) {
        setState(() => _showGoToTop = false);
      }
    }

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final provider = context.read<RetailProvider>();

    if (provider.last) {
      setState(() => _hasMore = false);
      return;
    }

    _isFetchingMore = true;

    await provider.fetchRetails(
      page: provider.page + 1,
      size: _size,
      isLoadMore: true,
    );

    _isFetchingMore = false;

    setState(() {
      _hasMore = !provider.last;
    });
  }

  void _applyFilters() async {
    final provider = Provider.of<EntriesProvider>(context, listen: false);

    int? supplierId;

    if (selectedSupplier != null) {
      final supplier = provider.entries.firstWhere(
            (e) => e.supplierName == selectedSupplier,
      );

      supplierId = supplier.id?.toInt();
    }
    await context.read<RetailProvider>().fetchRetails(
      page: 0,
      size: _size,
      fromDate: fromDateController.text.isEmpty
          ? null
          : fromDateController.text,
      toDate: toDateController.text.isEmpty
          ? null
          : toDateController.text,
      supplierId: supplierId,
      customerId: selectedCustomerId,
      staffId: selectedStaffId,
    );
    _clearFilters();
  }

  void _clearFilters() {
    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10));
    final formatter = DateFormat('yyyy-MM-dd');
      fromDateController.text = formatter.format(tenDaysAgo);
      toDateController.text = formatter.format(now);

    setState(() {
      selectedSupplier = null;
      selectedCustomerId = null;
      selectedStaffId = null;
    });

   // context.read<RetailProvider>().fetchRetails();
  }

  void _showFilterBottomSheet() {
    final entriesProvider = Provider.of<EntriesProvider>(
      context,
      listen: false,
    );
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, bottomSheetSetState) {
            return Container(
              // height: 600,
              decoration: BoxDecoration(
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
                    items: entriesProvider.entries
                        .map((e) => e.supplierName ?? '')
                        .where((e) => e.isNotEmpty)
                        .toSet()
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
                    label: "Referred By",
                    value: selectedCustomerId == null
                        ? null
                        : entriesProvider.customerEntries
                              .firstWhere(
                                (e) => e.id!.toInt() == selectedCustomerId,
                              )
                              .customerName,
                    items: entriesProvider.customerEntries
                        .map((e) => e.customerName ?? "")
                        .toSet()
                        .toList(),
                    onChanged: (value) {
                      final customer = entriesProvider.customerEntries
                          .firstWhere((e) => e.customerName == value);

                      bottomSheetSetState(() {
                        selectedCustomerId = customer.id!.toInt();
                      });

                      setState(() {
                        selectedCustomerId = customer.id!.toInt();
                      });
                    },
                  ),
                  FilterDropdown(
                    label: "Staff",
                    value: selectedStaffId == null
                        ? null
                        : staffProvider.staffs
                              .firstWhere((e) => e.staffId == selectedStaffId)
                              .staffName,
                    items: staffProvider.staffs
                        .map((e) => e.staffName)
                        .toSet()
                        .toList(),
                    onChanged: (value) {
                      final staff = staffProvider.staffs.firstWhere(
                        (e) => e.staffName == value,
                      );

                      bottomSheetSetState(() {
                        selectedStaffId = staff.staffId;
                      });

                      setState(() {
                        selectedStaffId = staff.staffId;
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
                    selectedCustomerId = null;
                  });

                  setState(() {
                    selectedSupplier = null;
                    selectedCustomerId = null;
                  });

                  Navigator.pop(context);

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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        title: "Retailers",
        textStyle: const TextStyle(
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
                child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
              ),
            ),

          FloatingActionButton(
            heroTag: "add",
            backgroundColor: AppColors.primaryPurple,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RetailEntryScreen(),
                ),
              );
            },
            child: const Icon(
              Iconsax.add,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.015,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Consumer<RetailProvider>(
                builder: (context, retailProvider, child) {
                  if (retailProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (retailProvider.error != null) {
                    return Center(
                      child: Text(
                        retailProvider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (retailProvider.retailEntries.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Retailers Found",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      await retailProvider.fetchRetails();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          retailProvider.retailEntries.length +
                          (retailProvider.last ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index == retailProvider.retailEntries.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final retail = retailProvider.retailEntries[index];
                        return Padding(
                          padding: EdgeInsets.all(5),
                          child: RetailCard(
                            fields: [
                              MapEntry("Date", retail.date),
                              MapEntry("Retailer", retail.name),
                              MapEntry("Referred By", retail.customerName),
                              MapEntry("Staff", retail.staffName),
                            ],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider(
                                    create: (_) => RetailDetailsProvider(),
                                    child: RetailDetailsScreen(
                                      retailId: retail.retailId,
                                    ),
                                  ),
                                ),
                              );
                            },
                            onAdd: () async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (_) =>
                                    AddSupplier(retailId: retail.retailId),
                              );

                              if (result == true && mounted) {
                                await context
                                    .read<RetailProvider>()
                                    .fetchRetails(page: 0, size: _size);
                              }
                            },
                            onEdit: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditRetailScreen(
                                    retailId: retail.retailId,
                                  ),
                                ),
                              );
                            },

                            onDelete: () async {
                              ExitConfirmationDialog.show(
                                context,
                                bodyText:
                                    "Are you sure you want to delete this retail?",
                                saveButtonText: "Yes",
                                discardButtonText: "No",
                                onDiscard: () {
                                  Navigator.pop(context);
                                },

                                onSave: () async {
                                  Navigator.pop(context);

                                  final success = await context
                                      .read<RetailProvider>()
                                      .deleteRetail(retail.retailId);

                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? "Retail deleted successfully"
                                            : "Failed to delete retail",
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
