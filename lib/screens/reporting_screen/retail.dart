import 'package:flutter/material.dart';
import 'package:hisabio/reporting_widgets/retail_details_bottom_sheet.dart';
import 'package:hisabio/screens/add_supplier.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/retail_provider.dart';
import '../../provider/staff_provider.dart';
import '../../reporting_widgets/edit_retail_bottom_sheet.dart';
import '../../reporting_widgets/reporting_card.dart';
import '../../reporting_widgets/reporting_filter_section.dart';
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

  bool _isFetchingMore = false;
  bool _hasMore = true;
  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();

  String? selectedSupplier;
  int? selectedCustomerId;
  int? selectedStaffId;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _page = 0;
      _hasMore = true;
      context.read<RetailProvider>().fetchRetails();
      await context.read<RetailProvider>().fetchRetails(
        page: _page,
        size: _size,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }
  void _scrollListener() {
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
  Future<void> _showRetailDetails(int retailId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) =>
          RetailDetailsBottomSheet(
            retailId: retailId,
          ),
    );
  }

  void _applyFilters()async {
    _page = 0;
    _hasMore = true;
  await  context.read<RetailProvider>().fetchRetails(
    page: _page,
    size: _size,
      fromDate: fromDateController.text.isEmpty
          ? null
          : fromDateController.text,
      toDate: toDateController.text.isEmpty
          ? null
          : toDateController.text,
    );
  }

  void _clearFilters() {
    fromDateController.clear();
    toDateController.clear();

    setState(() {
      selectedSupplier = null;
      selectedCustomerId = null;
      selectedStaffId = null;
    });

    context.read<RetailProvider>().fetchRetails();
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
              height: 600,
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
                      final customer = entriesProvider.customerEntries.firstWhere(
                            (e) => e.customerName == value,
                      );

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
                        .firstWhere(
                          (e) => e.staffId == selectedStaffId,
                    )
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
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Iconsax.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RetailEntryScreen()),
          );
        },
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
                    child:ListView.builder(
                      controller: _scrollController,
                      itemCount:
                      retailProvider.retailEntries.length +
                          (retailProvider.last ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index == retailProvider.retailEntries.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final retail = retailProvider.retailEntries[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: height * 0.015),
                          child: ReportingCard(
                            fields: [
                              MapEntry("Date", retail.date),
                              MapEntry("Retailer", retail.name),
                              MapEntry("Referred By", retail.customerName),
                              MapEntry("Staff", retail.staffName),
                            ],
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => ChangeNotifierProvider(
                                  create: (_) => RetailDetailsProvider(),
                                  child: RetailDetailsBottomSheet(
                                    retailId: retail.retailId,
                                  ),
                                ),
                              );
                            },
                            onAdd: () async {
                              await context.read<EntriesProvider>().fetchSuppliers();

                              showDialog(
                                context: context,
                                builder: (_) => const AddSupplier(),
                              );
                            },
                            onEdit: () async {
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) {
                                  return MultiProvider(
                                    providers: [
                                      ChangeNotifierProvider(
                                        create: (_) => RetailDetailsProvider(),
                                      ),
                                    ],
                                    child: EditRetailBottomSheet(
                                      retailId: retail.retailId,
                                    ),
                                  );
                                },
                              );

                              if (!mounted) return;

                              context.read<RetailProvider>().fetchRetails();
                            },
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Retail"),
                                  content: const Text(
                                    "Are you sure you want to delete this retail?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

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
