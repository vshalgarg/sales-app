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
import '../../provider/credit_provider.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../services/delete_credit_api.dart';
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

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10));

    final formatter = DateFormat("yyyy-MM-dd");

    fromDateController.text = formatter.format(tenDaysAgo);

    toDateController.text = formatter.format(now);

    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final entriesProvider = context.read<EntriesProvider>();

      final creditProvider = context.read<CreditProvider>();

      creditProvider.setFromDate(fromDateController.text);

      creditProvider.setToDate(toDateController.text);

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

    creditProvider.setFromDate(
      fromDateController.text.isEmpty ? null : fromDateController.text,
    );

    creditProvider.setToDate(
      toDateController.text.isEmpty ? null : toDateController.text,
    );

    creditProvider.setSupplierId(supplierId);

    creditProvider.setCustomerId(customerId);

    setState(() {
      isFilterApplied = true;
    });

    await creditProvider.refreshCredits();
  }

  Future<void> _clearFilters() async {
    final creditProvider = context.read<CreditProvider>();

    setState(() {
      selectedSupplier = null;
      selectedCustomer = null;

      fromDateController.clear();
      toDateController.clear();

      isFilterApplied = false;
    });

    creditProvider.setFromDate(null);
    creditProvider.setToDate(null);
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
          builder: (context, bottomSheetSetState) {
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
                      bottomSheetSetState(() {
                        selectedSupplier = value;
                      });
                    },
                  ),

                  FilterDropdown(
                    label: "Customer",
                    value: selectedCustomer,
                    items: customerItems,
                    onChanged: (value) {
                      bottomSheetSetState(() {
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
                  Navigator.pop(context);

                  await _clearFilters();
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
                child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
              ),
            ),

          FloatingActionButton(
            heroTag: "add",
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
                      MaterialPageRoute(builder: (_) => const CreditEntry()),
                    );

                    if (refresh == true && mounted) {
                      await context.read<CreditProvider>().refreshCredits();
                    }

                    if (mounted) {
                      setState(() {
                        isOpening = false;
                      });
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
                          builder: (_) =>
                              CreditEntry(mode: FormMode.view, credit: credit),
                        ),
                      );
                    },

                    onEdit: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CreditEntry(
                                  mode: FormMode.edit,
                                  credit: credit),
                        ),
                      );
                      if (context.mounted) {
                        await context.read<CreditProvider>().refreshCredits();
                      }
                    },

                    onDelete: () async {
                      ExitConfirmationDialog.show(
                        context,
                        bodyText:
                            "Are you sure you want to delete this credit?",
                        saveButtonText: "Yes",
                        discardButtonText: "No",

                        onDiscard: () {
                          Navigator.pop(context);
                        },

                        onSave: () async {
                          Navigator.pop(context);

                          final success = await provider.deleteCredit(
                            credit.id!.toInt(),
                          );

                          if (!mounted) return;

                          ScaffoldSnackBar.show(
                            context,
                            success
                                ? "Credit deleted successfully"
                                : "Failed to delete credit",
                          );
                        },
                      );
                    },

                    // deleteWithAmount: true,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:hisabio/screens/entry_screen/credit_entry.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors_used.dart';
// import '../../customs/app_bar.dart';
// import '../../enums/customer_mode.dart';
// import '../../pop_ups/general_closing_popup.dart';
// import '../../pop_ups/scafold_type.dart';
// import '../../provider/credit_provider.dart';
// import '../../provider/entries_provider/entries_section_provider.dart';
// import '../../reporting_widgets/reporting_card.dart';
// import '../../reporting_widgets/reporting_filter_section.dart';
// import '../home_screen.dart';
//
// class Credit extends StatefulWidget {
//   const Credit({super.key});
//
//   @override
//   State<Credit> createState() => _CreditState();
// }
//
// class _CreditState extends State<Credit> {
//   final ScrollController _scrollController = ScrollController();
//   List<String> supplierItems = [];
//   List<String> customerItems = [];
//   bool isFilterApplied = false;
//   int _page = 0;
//   final int _size = 20;
//   bool _isFetchingMore = false;
//   bool _hasMore = true;
//   bool isDeleting = false;
//   bool isOpeningView = false;
//   bool isOpeningEdit = false;
//   bool isOpening = false;
//   bool _showGoToTop = false;
//   final TextEditingController fromDateController = TextEditingController();
//
//   final TextEditingController toDateController = TextEditingController();
//   int? selectedCustomerId;
//   int? selectedStaffId;
//   String? selectedSupplier;
//   String? selectedCustomer;
//   void _showBottomSheetSnackBar(
//       BuildContext context,
//       String message,
//       ) {
//     final overlay = Overlay.of(context);
//
//     late OverlayEntry entry;
//
//     entry = OverlayEntry(
//       builder: (context) => Positioned(
//         left: 16,
//         right: 16,
//         bottom: 20,
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 14,
//             ),
//             decoration: BoxDecoration(
//               color: AppColors.containerFillColor,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     message,
//                     style: const TextStyle(
//                       //color: Colors.black,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//
//     overlay.insert(entry);
//
//     Future.delayed(const Duration(seconds: 3), () {
//       entry.remove();
//     });
//   }
//   @override
//   void initState() {
//     super.initState();
//
//     final now = DateTime.now();
//     final tenDaysAgo = now.subtract(const Duration(days: 10));
//
//     final formatter = DateFormat('yyyy-MM-dd');
//
//     fromDateController.text = formatter.format(tenDaysAgo);
//     toDateController.text = formatter.format(now);
//
//     _scrollController.addListener(_scrollListener);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       if (!mounted) return;
//
//       final entriesProvider = context.read<EntriesProvider>();
//       final creditProvider = context.read<CreditProvider>();
//
//       _page = 0;
//       _hasMore = true;
//
//       await creditProvider.fetchCredits(
//         page: 0,
//         size: _size,
//         fromDate: fromDateController.text,
//         toDate: toDateController.text,
//       );
//       setState(() {
//         _hasMore = !creditProvider.last;
//       });
//       await Future.wait([
//         entriesProvider.fetchSuppliers(),
//         entriesProvider.fetchCustomer(),
//       ]);
//
//       supplierItems = entriesProvider.entries
//           .map((e) => e.supplierName ?? '')
//           .where((e) => e.isNotEmpty)
//           .toSet()
//           .toList();
//
//       customerItems = entriesProvider.customerEntries
//           .map((e) => e.customerName ?? '')
//           .where((e) => e.isNotEmpty)
//           .toSet()
//           .toList();
//     });
//   }
//
//   void _scrollListener() {
//     if (!_scrollController.hasClients) return;
//
//     if (_scrollController.offset > 200) {
//       if (!_showGoToTop) {
//         setState(() => _showGoToTop = true);
//       }
//     } else {
//       if (_showGoToTop) {
//         setState(() => _showGoToTop = false);
//       }
//     }
//
//     if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent - 200 &&
//         !_isFetchingMore &&
//         _hasMore) {
//       _loadMore();
//     }
//   }
//
//   Future<void> _loadMore() async {
//     if (_isFetchingMore || !_hasMore) return;
//
//     setState(() {
//       _isFetchingMore = true;
//     });
//
//     _page++;
//
//     final provider = context.read<CreditProvider>();
//
//     await provider.fetchCredits(
//       page: _page,
//       size: _size,
//       isLoadMore: true,
//       fromDate: fromDateController.text,
//       toDate: toDateController.text,
//     );
//
//     setState(() {
//       _hasMore = !provider.last;
//       _isFetchingMore = false;
//     });
//   }
//
//   void _applyFilters() async {
//     final provider = Provider.of<EntriesProvider>(context, listen: false);
//
//     final creditProvider = Provider.of<CreditProvider>(context, listen: false);
//
//     int? supplierId;
//     int? customerId;
//
//     if (selectedSupplier != null) {
//       final supplier = provider.entries.firstWhere(
//         (e) => e.supplierName == selectedSupplier,
//       );
//
//       supplierId = supplier.id?.toInt();
//     }
//
//     if (selectedCustomer != null) {
//       final customer = provider.customerEntries.firstWhere(
//         (e) => e.customerName == selectedCustomer,
//       );
//       customerId = customer.id?.toInt();
//     }
//     String? fromDate = fromDateController.text.isEmpty
//         ? null
//         : fromDateController.text;
//
//     String? toDate = toDateController.text.isEmpty
//         ? null
//         : toDateController.text;
//
//     _page = 0;
//     _hasMore = true;
//     setState(() {
//       isFilterApplied = true;
//     });
//     await creditProvider.fetchCredits(
//       page: 0,
//       size: _size,
//       fromDate: fromDate,
//       toDate: toDate,
//       supplierId: supplierId,
//       customerId: customerId,
//     );
//     setState(() {
//       fromDateController.clear();
//       toDateController.clear();
//       selectedSupplier = null;
//       selectedCustomer = null;
//     });
//     setState(() {
//       _hasMore = !creditProvider.last;
//     });
//   }
//
//   void _clearFilters() {
//     // final now = DateTime.now();
//     // final tenDaysAgo = now.subtract(const Duration(days: 10));
//     // final formatter = DateFormat('yyyy-MM-dd');
//     setState(() {
//       // fromDateController.text = formatter.format(tenDaysAgo);
//       // toDateController.text = formatter.format(now);
//       selectedSupplier = null;
//       selectedCustomer = null;
//     });
//     // context.read<CreditProvider>().fetchCredits(
//     //   fromDate: fromDateController.text,
//     //   toDate: toDateController.text,
//     // );
//   }
//
//   void _showFilterBottomSheet() {
//     final provider = Provider.of<EntriesProvider>(context, listen: false);
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, bottomSheetSetState) {
//             return Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(40),
//                   topRight: Radius.circular(40),
//                 ),
//               ),
//               child: ReportingFilterSection(
//                 fromDateController: fromDateController,
//                 toDateController: toDateController,
//
//                 dropdowns: [
//                   FilterDropdown(
//                     label: "Supplier",
//                     value: selectedSupplier,
//                     items: supplierItems,
//                   onChanged: (value) {
//                     bottomSheetSetState(() {
//                       selectedSupplier = value;
//                     });
//                     },
//                   ),
//
//                   FilterDropdown(
//                     label: "Customer",
//                     value: selectedCustomer,
//                     items: customerItems,
//                     onChanged: (value) {
//                       bottomSheetSetState(() {
//                         selectedCustomer = value;
//                       });
//                     },
//                   ),
//                 ],
//
//                 onApply: () async {
//                   final hasFilter =
//                       fromDateController.text.isNotEmpty ||
//                           toDateController.text.isNotEmpty ||
//                           selectedSupplier != null ||
//                           selectedCustomerId != null ||
//                           selectedStaffId != null;
//
//                   if (!hasFilter) {
//                     _showBottomSheetSnackBar(
//                       context,
//                       "Please select at least one filter.",
//                     );
//                     return;
//                   }
//
//                   Navigator.pop(context);
//                   _applyFilters();
//                 },
//
//                 onClear: () {
//                   bottomSheetSetState(() {
//                     fromDateController.clear();
//                     toDateController.clear();
//                     selectedSupplier = null;
//                     selectedCustomer = null;
//                   });
//
//                   _clearFilters();
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final width = size.width;
//     final height = size.height;
//     return Scaffold(
//       backgroundColor: AppColors.bodyFillColor,
//
//       appBar: CustomAppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => HomeScreen()),
//             );
//           },
//         ),
//         title: "Credits",
//         textStyle: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w600,
//           fontSize: 25,
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
//             onPressed: () {
//               _showFilterBottomSheet();
//             },
//           ),
//         ],
//       ),
//       floatingActionButton: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (_showGoToTop)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: FloatingActionButton.small(
//                 heroTag: "top",
//                 backgroundColor: AppColors.primaryPurple,
//                 onPressed: () {
//                   _scrollController.animateTo(
//                     0,
//                     duration: const Duration(milliseconds: 500),
//                     curve: Curves.easeInOut,
//                   );
//                 },
//                 child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
//               ),
//             ),
//
//           FloatingActionButton(
//             heroTag: "add",
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(50),
//             ),
//             backgroundColor: AppColors.primaryPurple,
//             onPressed: isOpening
//                 ? null
//                 : () async {
//                     setState(() {
//                       isOpening = true;
//                     });
//                     await Future.delayed(const Duration(milliseconds: 100));
//                     if (!mounted) return;
//
//                     final bool? refresh = await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const CreditEntry(),
//                       ),
//                     );
//
//                     if (refresh == true && mounted) {
//                       _page = 0;
//                       _hasMore = true;
//
//                       await context.read<CreditProvider>().fetchCredits(
//                         page: 0,
//                         size: _size,
//                         fromDate: fromDateController.text,
//                         toDate: toDateController.text,
//                       );
//                     }
//
//                     if (mounted) {
//                       setState(() {
//                         isOpening = false;
//                       });
//                     }
//                   },
//             child: isOpening
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : const Icon(Iconsax.add, color: Colors.white,size: 40,),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: width * 0.04,
//           vertical: height * 0.015,
//         ),
//         child: Consumer<EntriesProvider>(
//           builder: (context, provider, child) {
//             if (provider.isLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (provider.error != null) {
//               return Center(
//                 child: Text(
//                   provider.error!,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               );
//             }
//
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Consumer<CreditProvider>(
//                     builder: (context, creditProvider, child) {
//                       if (creditProvider.isLoading) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//
//                       if (creditProvider.credits.isEmpty) {
//                         return Center(
//                           child: Text(
//                             isFilterApplied
//                                 ? "No data found"
//                                 : "Apply filters to view credit history",
//                             style: TextStyle(
//                               fontSize: width * 0.06,
//                               color: Colors.white,
//                             ),
//                           ),
//                         );
//                       }
//
//                       return ListView.builder(
//                         controller: _scrollController,
//                         itemCount:
//                             creditProvider.credits.length + (_hasMore ? 1 : 0),
//                         itemBuilder: (context, index) {
//                           if (index == creditProvider.credits.length) {
//                             return const Padding(
//                               padding: EdgeInsets.all(16),
//                               child: Center(child: CircularProgressIndicator()),
//                             );
//                           }
//                           final credit = creditProvider.credits[index];
//                           return Padding(
//                             padding: EdgeInsets.only(bottom: height * 0.015),
//                             child: LayoutBuilder(
//                               builder: (context, constraints) {
//                                 return ReportingCard(
//                                   leadingIcon: Iconsax.document,
//                                   title: "Invoice : ",
//                                   value: credit.billNumber ?? "-",
//                                   chips: [
//                                     ReportChip(
//                                       icon: Iconsax.calendar,
//                                       text: credit.date ?? "-",
//                                     ),
//                                     ReportChip(
//                                       icon: Iconsax.card,
//                                       text: credit.paymentType ?? "-",
//                                     ),
//                                   ],
//                                    fields: [
//                                     ReportField(
//                                       icon: Iconsax.shop,
//                                       label: "Supplier",
//                                       value: credit.supplierName ?? "-",
//                                     ),
//                                     ReportField(
//                                       icon: Iconsax.user,
//                                       label: "Customer",
//                                       value: credit.customerName ?? "-",
//                                     ),
//                                   ],
//
//                                   amount: (credit.receivedAmount ?? 0)
//                                       .toString(),
//                                   onTap: () async {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (_) =>
//                                             CreditEntry(
//                                                 mode:FormMode.view,
//                                                 id:credit.id),
//                                       ),
//                                     );
//                                   },
//
//                                   onEdit: () async {
//                                     final bool? refresh = await   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (_) => CreditEntry(
//                                             mode:FormMode.edit,
//                                             id:credit.id),
//                                         ),
//                                       );
//                                     if (refresh == true && mounted) {
//                                       _page = 0;
//                                       _hasMore = true;
//
//                                       await context.read<CreditProvider>().fetchCredits(
//                                         page: 0,
//                                         size: _size,
//                                         fromDate: fromDateController.text,
//                                         toDate: toDateController.text,
//                                       );
//                                     }
//                                   },
//                                   onDelete: () async {
//                                     ExitConfirmationDialog.show(
//                                       context,
//                                       bodyText:
//                                           "Are you sure you want to delete this credit?",
//                                       saveButtonText: "Yes",
//                                       discardButtonText: "No",
//
//                                       onDiscard: () {
//                                         Navigator.pop(context);
//                                       },
//
//                                       onSave: () async {
//                                         Navigator.pop(context);
//
//                                         final bool success = await context
//                                             .read<CreditProvider>()
//                                             .deleteCredit(credit.id!);
//
//                                         if (!mounted) return;
//
//                                         ScaffoldSnackBar.show(context,success
//                                                   ? "Credit deleted successfully"
//                                                   : "Failed to delete credit",
//                                         );
//                                       },
//                                     );
//                                   },
//                                   deleteWithAmount: true,
//                                 );
//                               },
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
