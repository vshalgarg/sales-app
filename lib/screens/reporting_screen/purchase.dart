import 'package:flutter/material.dart';
import 'package:hisabio/screens/entry_screen/purchase_entry.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';

import '../../pop_ups/general_closing_popup.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/purchase_provider.dart';
import '../../reporting_widgets/edit_purchase_screen.dart';
import '../../reporting_widgets/purchase_details_screen.dart';
import '../../reporting_widgets/reporting_card.dart';
import '../../reporting_widgets/reporting_filter_section.dart';
import '../../services/purchase_details_api.dart';
import '../home_screen.dart';

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  State<Purchase> createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {
  final ScrollController _scrollController = ScrollController();

  int _page = 0;
  int _size = 20;

  bool _isFetchingMore = false;
  bool _hasMore = true;
  bool isDeleting = false;
  bool isOpeningView = false;
  bool isOpeningEdit = false;
  bool isOpening = false;
  bool _showGoToTop = false;
  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();

  String? selectedSupplier;
  String? selectedCustomer;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final entriesProvider = context.read<EntriesProvider>();
      final purchaseProvider = context.read<PurchaseProvider>();

      await Future.wait([
        entriesProvider.fetchSuppliers(),
        entriesProvider.fetchCustomer(),
      ]);

      _page = 0;
      _hasMore = true;

      await purchaseProvider.searchPurchases(page: _page, size: _size);
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
    final provider = context.read<PurchaseProvider>();

    if (provider.last) {
      setState(() => _hasMore = false);
      return;
    }

    _isFetchingMore = true;

    await provider.searchPurchases(
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

    final purchaseProvider = Provider.of<PurchaseProvider>(
      context,
      listen: false,
    );

    int? supplierId;
    int? customerId;

    if (selectedSupplier != null) {
      final supplier = provider.entries.firstWhere(
        (e) => e.supplierName == selectedSupplier,
      );

      supplierId = supplier.id?.toInt();
    }

    if (selectedCustomer != null) {
      final customer = provider.customerEntries.firstWhere(
        (e) => e.customerName == selectedCustomer,
      );
      customerId = customer.id?.toInt();
    }
    String? fromDate = fromDateController.text.isEmpty
        ? null
        : fromDateController.text;

    String? toDate = toDateController.text.isEmpty
        ? null
        : toDateController.text;
    await purchaseProvider.searchPurchases(
      fromDate: fromDate,
      toDate: toDate,
      supplierId: supplierId,
      customerId: customerId,
    );
  }

  void _clearFilters() async {
    setState(() {
      fromDateController.clear();
      toDateController.clear();
      selectedSupplier = null;
      selectedCustomer = null;
    });

    await context.read<PurchaseProvider>().searchPurchases();
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
              //height: 500,
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
                onClear: () async {
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        title: "Purchases",
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
                  color: Colors.white,),
              ),
            ),

          FloatingActionButton(
            heroTag: "add",
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
                MaterialPageRoute(builder: (_) => const PurchaseEntryScreen()),
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
                : const Icon(Iconsax.add, color: Colors.white),
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
                  child: Consumer<PurchaseProvider>(
                    builder: (context, purchaseProvider, child) {
                      if (purchaseProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (purchaseProvider.purchaseEntries.isEmpty) {
                        return Center(
                          child: Text(
                            "Apply filters to view purchase history",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.06,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            purchaseProvider.purchaseEntries.length +
                            (purchaseProvider.last ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (index ==
                              purchaseProvider.purchaseEntries.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final purchase =
                              purchaseProvider.purchaseEntries[index];

                          return Padding(
                            padding: EdgeInsets.only(bottom: height * 0.015),
                            child: ReportingCard(
                              showHeader: false,
                              chips: [
                                ReportChip(
                                  icon: Iconsax.calendar,
                                  text: purchase.date ?? "-",
                                ),
                              ],
                              fields: [
                                ReportField(
                                  icon: Iconsax.profile_2user,
                                  label: "Staff",
                                  value: purchase.staffName ?? "-",
                                ),
                                ReportField(
                                  icon: Iconsax.shop,
                                  label: "Supplier",
                                  value: purchase.supplierName
                                ),
                                ReportField(
                                  icon: Iconsax.user,
                                  label: "Customer",
                                  value: purchase.customerName
                                ),
                                ReportField(
                                  icon: Iconsax.note,
                                  label: "Remarks",
                                  value: purchase.remarks
                                ),
                              ],
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                try {
                                  final data = await getPurchaseDetails(
                                    purchase.id,
                                  );

                                  if (!mounted) return;

                                  Navigator.pop(context);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PurchaseDetailsScreen(
                                          purchaseData: data["data"],
                                        ),
                                      )
                                  );
                                } catch (e) {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text("$e")));
                                }
                              },
                              onEdit: () async {
                                final details = await getPurchaseDetails(
                                  purchase.id,
                                );

                                if (!context.mounted) return;

                              Navigator.push(
                                  context, MaterialPageRoute(
                                  builder: (_)=>EditPurchaseScreen(
                                      purchaseData: details["data"])));

                              },
                              onDelete: () async {
                                ExitConfirmationDialog.show(
                                  context,
                                  bodyText:
                                  "Are you sure you want to delete this purchase?",
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

                                    final bool success = await context
                                        .read<PurchaseProvider>()
                                        .deletePurchase(purchase.id);

                                    if (!mounted) return;

                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? "Purchase deleted successfully"
                                              : "Failed to delete credit",
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ));

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
