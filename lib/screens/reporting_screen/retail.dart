import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';
import '../../model_classes/retailers/retail_model.dart' as retail_model;
import '../../pagination/pagination_widget.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/reporting_provider/retail_provider.dart';
import '../../provider/master_provider/staff_provider.dart';
import '../../reporting_widgets/edit_retail_screen.dart';
import '../../reporting_widgets/reporting_filter_section.dart';
import '../../reporting_widgets/retail_card.dart';
import '../../reporting_widgets/retail_details_screen.dart';
import 'add_supplier.dart';
import '../entry_screen/retail_entry.dart';

class Retail extends StatefulWidget {
  const Retail({super.key});

  @override
  State<Retail> createState() => _RetailState();
}

class _RetailState extends State<Retail> {
  final TextEditingController fromDateController =
  TextEditingController();

  final TextEditingController toDateController =
  TextEditingController();

  bool isOpening = false;

  bool isFilterApplied = false;

  String? selectedSupplier;

  int? selectedCustomerId;

  int? selectedStaffId;

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
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(entry);

    Future.delayed(
      const Duration(seconds: 3),
          () => entry.remove(),
    );
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    final tenDaysAgo =
    now.subtract(const Duration(days: 10));

    final formatter =
    DateFormat("yyyy-MM-dd");

    fromDateController.text =
        formatter.format(tenDaysAgo);

    toDateController.text =
        formatter.format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final entriesProvider =
      context.read<EntriesProvider>();

      await entriesProvider.fetchSuppliers();

      await entriesProvider.fetchCustomer();

      await context
          .read<StaffProvider>()
          .refreshStaffs();

      final provider =
      context.read<RetailProvider>();

      provider.applyFilters(
        fromDate: fromDateController.text,
        toDate: toDateController.text,
      );

      await provider.refresh();
    });
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  Future<void> _applyFilters() async {
    final entriesProvider =
    context.read<EntriesProvider>();

    int? supplierId;

    if (selectedSupplier != null) {
      final supplier = entriesProvider.entries.firstWhere(
            (e) => e.supplierName == selectedSupplier,
      );

      supplierId = supplier.id?.toInt();
    }

    final provider =
    context.read<RetailProvider>();

    provider.applyFilters(
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

    setState(() {
      isFilterApplied = true;
    });

    await provider.refresh();
  }

  Future<void> _clearFilters() async {
    setState(() {
      fromDateController.clear();
      toDateController.clear();
      selectedSupplier = null;
      selectedCustomerId = null;
      selectedStaffId = null;
      isFilterApplied = false;
    });

    final provider =
    context.read<RetailProvider>();

    provider.clearFilters();

    provider.applyFilters(
      fromDate: fromDateController.text,
      toDate: toDateController.text,
    );

    await provider.refresh();
  }

  void _showFilterBottomSheet() {
    final entriesProvider =
    context.read<EntriesProvider>();

    final staffProvider =
    context.read<StaffProvider>();

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
                fromDateController:
                fromDateController,
                toDateController:
                toDateController,
                dropdowns: [
                  FilterDropdown(
                    label: "Supplier",
                    value: selectedSupplier,
                    items: entriesProvider.entries
                        .map(
                          (e) =>
                      e.supplierName ?? "",
                    )
                        .where(
                          (e) => e.isNotEmpty,
                    )
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
                    label: "Referred By",
                    value: selectedCustomerId ==
                        null
                        ? null
                        : entriesProvider
                        .customerEntries
                        .firstWhere(
                          (e) =>
                      e.id?.toInt() ==
                          selectedCustomerId,
                    )
                        .customerName,
                    items: entriesProvider
                        .customerEntries
                        .map(
                          (e) =>
                      e.customerName ??
                          "",
                    )
                        .where(
                          (e) => e.isNotEmpty,
                    )
                        .toList(),
                    onChanged: (value) {
                      final customer =
                      entriesProvider
                          .customerEntries
                          .firstWhere(
                            (e) =>
                        e.customerName ==
                            value,
                      );

                      setBottomState(() {
                        selectedCustomerId =
                            customer.id
                                ?.toInt();
                      });

                      setState(() {
                        selectedCustomerId =
                            customer.id
                                ?.toInt();
                      });
                    },
                  ),

                  FilterDropdown(
                    label: "Staff",
                    value: selectedStaffId ==
                        null
                        ? null
                        : staffProvider
                        .data
                        .items
                        .firstWhere(
                          (e) =>
                      e.id ==
                          selectedStaffId,
                    )
                        .staffName,
                    items: staffProvider.data.items
                        .map((e) => e.staffName ?? "")
                        .where((e) => e.isNotEmpty)
                        .toList(),
                    onChanged: (value) {
                      final staff =
                      staffProvider
                          .data
                          .items
                          .firstWhere(
                            (e) =>
                        e.staffName ==
                            value,
                      );

                      setBottomState(() {
                        selectedStaffId =
                            staff.id;
                      });

                      setState(() {
                        selectedStaffId =
                            staff.id;
                      });
                    },
                  ),
                ],
                onApply: () async {
                  final hasFilter =
                      fromDateController
                          .text
                          .isNotEmpty ||
                          toDateController
                              .text
                              .isNotEmpty ||
                          selectedSupplier !=
                              null ||
                          selectedCustomerId !=
                              null ||
                          selectedStaffId !=
                              null;

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;

    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,

      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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
              builder: (_) =>
              const RetailEntryScreen(),
            ),
          );

          if (!mounted) return;

          if (refresh == true) {
            await context
                .read<RetailProvider>()
                .refresh();
          }

          setState(() {
            isOpening = false;
          });
        },
        child: isOpening
            ? const SizedBox(
          width: 20,
          height: 20,
          child:
          CircularProgressIndicator(
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
        child: Consumer<RetailProvider>(
          builder: (context,
              provider,
              child,) {
            return PaginationWidget<
                retail_model.Retail>(
              pagination:
              provider.pagination,

              items:
              provider.data.items,

              loading:
              provider.loading,

              fetchPage: (page) async {
                await provider.fetchPage(
                  page,
                );
              },

              refresh: () async {
                await provider.refresh();
              },

              itemBuilder:
                  (context,
                  retail,) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: height * 0.015,
                  ),
                  child: RetailCard(
                    fields: [
                      MapEntry(
                        "Date",
                        DateFormat("yyyy-MM-dd")
                            .format(retail.date),
                      ),

                      MapEntry(
                        "Retailer",
                        retail.name,
                      ),

                      MapEntry(
                        "Referred By",
                        retail.customerName,
                      ),

                      MapEntry(
                        "Staff",
                        retail.staffName ?? "-",
                      ),
                    ],
                    onTap: () async {
                      final refresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RetailDetailsScreen(
                            retailId: retail.id,
                          ),
                        ),
                      );

                      if (!mounted) return;

                      if (refresh == true) {
                        await provider.refresh();
                      }
                    },

                    onEdit: () async {
                      final refresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditRetailScreen(
                            retailId: retail.id,
                          ),
                        ),
                      );

                      if (!mounted) return;

                      if (refresh == true) {
                        await provider.refresh();
                      }
                    },

                    onAdd: () async {
                      final refresh =
                      await showDialog<bool>(
                        context: context,
                        builder: (_) =>
                            AddSupplier(
                              retailId: retail.id,
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
                        "Are you sure you want to delete this retail?",

                        saveButtonText: "Yes",

                        discardButtonText: "No",

                        onDiscard: () {
                          Navigator.pop(context);
                        },

                        onSave: () async {
                          Navigator.pop(context);

                          final success =
                          await provider.deleteRetail(
                            retail.id,
                          );

                          if (success) {
                            await provider.refresh();
                          }

                          if (!mounted) return;

                          ScaffoldSnackBar.show(
                            context,
                            success
                                ? "Retail deleted successfully"
                                : "Failed to delete retail",
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
    );
  }
}










// import 'package:flutter/material.dart';
// import 'package:hisabio/constants/colors_used.dart';
// import 'package:hisabio/customs/app_bar.dart';
// import 'package:hisabio/pop_ups/general_closing_popup.dart';
// import 'package:hisabio/pop_ups/scafold_type.dart';
// import 'package:hisabio/provider/entries_provider/entries_section_provider.dart';
// import 'package:hisabio/provider/retail_provider.dart';
// import 'package:hisabio/provider/staff_provider.dart';
// import 'package:hisabio/reporting_widgets/reporting_filter_section.dart';
// import 'package:hisabio/screens/entry_screen/retail_entry.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../model_classes/retailers/retail_model.dart' as retail_model;
// import '../../pagination/pagination_widget.dart';
// import '../../reporting_widgets/retail_card.dart';
// import '../add_supplier.dart';
//
// class Retail extends StatefulWidget {
//   const Retail({super.key});
//
//   @override
//   State<Retail> createState() => _RetailState();
// }
//
// class _RetailState extends State<Retail> {
//   final TextEditingController fromDateController =
//   TextEditingController();
//
//   final TextEditingController toDateController =
//   TextEditingController();
//
//   bool isFilterApplied = false;
//
//   bool isOpening = false;
//
//   String? selectedSupplier;
//
//   int? selectedCustomerId;
//
//   int? selectedStaffId;
//
//   void _showBottomSheetSnackBar(BuildContext context,
//       String message,) {
//     final overlay = Overlay.of(context);
//
//     late OverlayEntry entry;
//
//     entry = OverlayEntry(
//       builder: (_) =>
//           Positioned(
//             left: 16,
//             right: 16,
//             bottom: 20,
//             child: Material(
//               color: Colors.transparent,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.containerFillColor,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   message,
//                   style: const TextStyle(
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//     );
//
//     overlay.insert(entry);
//
//     Future.delayed(
//       const Duration(seconds: 3),
//           () => entry.remove(),
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     final now = DateTime.now();
//
//     final tenDaysAgo =
//     now.subtract(const Duration(days: 10));
//
//     final formatter =
//     DateFormat("yyyy-MM-dd");
//
//     fromDateController.text =
//         formatter.format(tenDaysAgo);
//
//     toDateController.text =
//         formatter.format(now);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       if (!mounted) return;
//
//       final entriesProvider =
//       context.read<EntriesProvider>();
//
//       await entriesProvider.fetchSuppliers();
//
//       await entriesProvider.fetchCustomer();
//
//       await context
//           .read<StaffProvider>()
//           .fetchStaffs();
//
//       final provider =
//       context.read<RetailProvider>();
//
//       provider.applyFilters(
//         fromDate: fromDateController.text,
//         toDate: toDateController.text,
//       );
//
//       await provider.refresh();
//     });
//   }
//
//   @override
//   void dispose() {
//     fromDateController.dispose();
//     toDateController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _applyFilters() async {
//     final entriesProvider =
//     context.read<EntriesProvider>();
//
//     int? supplierId;
//
//     if (selectedSupplier != null) {
//       final supplier =
//       entriesProvider.entries.firstWhere(
//             (e) =>
//         e.supplierName ==
//             selectedSupplier,
//       );
//
//       supplierId = supplier.id?.toInt();
//     }
//
//     final provider =
//     context.read<RetailProvider>();
//
//     provider.applyFilters(
//       fromDate: fromDateController.text.isEmpty
//           ? null
//           : fromDateController.text,
//       toDate: toDateController.text.isEmpty
//           ? null
//           : toDateController.text,
//       supplierId: supplierId,
//       customerId: selectedCustomerId,
//       id: selectedStaffId,
//     );
//
//     setState(() {
//       isFilterApplied = true;
//     });
//
//     await provider.refresh();
//   }
//
//   Future<void> _clearFilters() async {
//     final now = DateTime.now();
//
//     final formatter =
//     DateFormat("yyyy-MM-dd");
//
//     fromDateController.text = formatter.format(
//       now.subtract(
//         const Duration(days: 10),
//       ),
//     );
//
//     toDateController.text =
//         formatter.format(now);
//
//     setState(() {
//       selectedSupplier = null;
//       selectedCustomerId = null;
//       selectedStaffId = null;
//       isFilterApplied = false;
//     });
//
//     final provider =
//     context.read<RetailProvider>();
//
//     provider.clearFilters();
//
//     provider.applyFilters(
//       fromDate: fromDateController.text,
//       toDate: toDateController.text,
//     );
//
//     await provider.refresh();
//   }
//
//   void _showFilterBottomSheet() {
//     final entriesProvider =
//     context.read<EntriesProvider>();
//
//     final staffProvider =
//     context.read<StaffProvider>();
//
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setBottomState) {
//             return Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(
//                   top: Radius.circular(40),
//                 ),
//               ),
//               child: ReportingFilterSection(
//                 fromDateController: fromDateController,
//                 toDateController: toDateController,
//                 dropdowns: [
//                   FilterDropdown(
//                     label: "Supplier",
//                     value: selectedSupplier,
//                     items: entriesProvider.entries
//                         .map((e) => e.supplierName ?? "")
//                         .where((e) => e.isNotEmpty)
//                         .toSet()
//                         .toList(),
//                     onChanged: (value) {
//                       setBottomState(() {
//                         selectedSupplier = value;
//                       });
//
//                       setState(() {
//                         selectedSupplier = value;
//                       });
//                     },
//                   ),
//
//                   FilterDropdown(
//                     label: "Referred By",
//                     value: selectedCustomerId == null
//                         ? null
//                         : entriesProvider.customerEntries
//                         .firstWhere(
//                           (e) =>
//                       e.id?.toInt() ==
//                           selectedCustomerId,
//                     )
//                         .customerName,
//                     items: entriesProvider.customerEntries
//                         .map((e) => e.customerName ?? "")
//                         .where((e) => e.isNotEmpty)
//                         .toList(),
//                     onChanged: (value) {
//                       final customer =
//                       entriesProvider.customerEntries
//                           .firstWhere(
//                             (e) =>
//                         e.customerName == value,
//                       );
//
//                       setBottomState(() {
//                         selectedCustomerId =
//                             customer.id?.toInt();
//                       });
//
//                       setState(() {
//                         selectedCustomerId =
//                             customer.id?.toInt();
//                       });
//                     },
//                   ),
//
//                   FilterDropdown(
//                     label: "Staff",
//                     value: selectedStaffId == null
//                         ? null
//                         : staffProvider.data.items
//                         .firstWhere(
//                           (e) =>
//                       e.staffId ==
//                           selectedStaffId,
//                     )
//                         .staffName,
//                     items: staffProvider.data.items
//                         .map((e) => e.staffName)
//                         .toList(),
//                     onChanged: (value) {
//                       final staff =
//                       staffProvider.staffs.firstWhere(
//                             (e) =>
//                         e.staffName == value,
//                       );
//
//                       setBottomState(() {
//                         selectedStaffId =
//                             staff.staffId;
//                       });
//
//                       setState(() {
//                         selectedStaffId =
//                             staff.staffId;
//                       });
//                     },
//                   ),
//                 ],
//                 onApply: () async {
//                   final hasFilter =
//                       fromDateController.text.isNotEmpty ||
//                           toDateController
//                               .text.isNotEmpty ||
//                           selectedSupplier !=
//                               null ||
//                           selectedCustomerId !=
//                               null ||
//                           selectedStaffId !=
//                               null;
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
//
//                   await _applyFilters();
//                 },
//                 onClear: () async {
//                   Navigator.pop(context);
//
//                   await _clearFilters();
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
//     final size = MediaQuery
//         .of(context)
//         .size;
//
//     return Scaffold(
//       backgroundColor:
//       AppColors.bodyFillColor,
//
//       appBar: CustomAppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: "Retailers",
//         textStyle: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w600,
//           fontSize: 25,
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.filter_alt_outlined,
//               color: Colors.white,
//             ),
//             onPressed:
//             _showFilterBottomSheet,
//           ),
//         ],
//       ),
//
//       floatingActionButton:
//       FloatingActionButton(
//         backgroundColor:
//         AppColors.primaryPurple,
//         shape:
//         RoundedRectangleBorder(
//           borderRadius:
//           BorderRadius.circular(50),
//         ),
//         onPressed: isOpening
//             ? null
//             : () async {
//           setState(() {
//             isOpening = true;
//           });
//
//           final refresh =
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) =>
//               const RetailEntryScreen(),
//             ),
//           );
//
//           if (!mounted) return;
//
//           if (refresh == true) {
//             await context
//                 .read<
//                 RetailProvider>()
//                 .refresh();
//           }
//
//           setState(() {
//             isOpening = false;
//           });
//         },
//         child: isOpening
//             ? const SizedBox(
//           width: 20,
//           height: 20,
//           child:
//           CircularProgressIndicator(
//             strokeWidth: 2,
//             color: Colors.white,
//           ),
//         )
//             : const Icon(
//           Iconsax.add,
//           color: Colors.white,
//           size: 34,
//         ),
//       ),
//
//       body: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: size.width * 0.04,
//           vertical: size.height * 0.015,
//         ),
//         child: Consumer<RetailProvider>(
//           builder: (context,
//               provider,
//               child,) {
//             return PaginationWidget<retail_model.Retail>(
//               pagination: provider.pagination,
//
//               items: provider.data.items,
//
//               loading: provider.loading,
//
//               fetchPage: (page) async {
//                 await provider.fetchPage(page);
//               },
//
//               refresh: () async {
//                 await provider.refresh();
//               },
//
//               itemBuilder: (
//                   BuildContext context,
//                   retail_model.Retail retail,
//                   ) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 10),
//                   child: RetailCard(
//                     fields: [
//                       MapEntry(
//                         "Date",
//                         DateFormat("yyyy-MM-dd").format(retail.date),
//                       ),
//                       MapEntry("Retailer", retail.name),
//                       MapEntry("Referred By", retail.customerName),
//                       MapEntry("Staff", retail.staffName ?? "-"),
//                     ],
//
//                     onTap: () async {
//                       await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => RetailDetailsScreen(
//                             retailId: retail.id,
//                           ),
//                         ),
//                       );
//
//                       if (!mounted) return;
//
//                       await provider.refresh();
//                     },
//
//                     onAdd: () async {
//                       final refresh = await showDialog<bool>(
//                         context: context,
//                         builder: (_) => AddSupplier(
//                           retailId: retail.id,
//                         ),
//                       );
//
//                       if (refresh == true && mounted) {
//                         await provider.refresh();
//                       }
//                     },
//
//                     onEdit: () async {
//                       final refresh = await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => EditRetailScreen(
//                             retailId: retail.id,
//                           ),
//                         ),
//                       );
//
//                       if (!mounted) return;
//
//                       if (refresh == true) {
//                         await provider.refresh();
//                       }
//                     },
//
//                     onDelete: () async {
//                       ExitConfirmationDialog.show(
//                         context,
//                         bodyText:
//                         "Are you sure you want to delete this retail?",
//
//                         saveButtonText: "Yes",
//                         discardButtonText: "No",
//
//                         onDiscard: () {
//                           Navigator.pop(context);
//                         },
//
//                         onSave: () async {
//                           Navigator.pop(context);
//
//                           final success =
//                           await provider.deleteRetail(retail.id);
//
//                           if (!mounted) return;
//
//                           ScaffoldSnackBar.show(
//                             context,
//                             success
//                                 ? "Retail deleted successfully"
//                                 : "Failed to delete retail",
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:hisabio/reporting_widgets/retail_details_screen.dart';
// // import 'package:hisabio/screens/add_supplier.dart';
// // import 'package:iconsax/iconsax.dart';
// // import 'package:intl/intl.dart';
// // import 'package:provider/provider.dart';
// // import '../../constants/colors_used.dart';
// // import '../../customs/app_bar.dart';
// // import '../../pop_ups/general_closing_popup.dart';
// // import '../../pop_ups/scafold_type.dart';
// // import '../../provider/entries_provider/entries_section_provider.dart';
// // import '../../provider/retail_provider.dart';
// // import '../../provider/staff_provider.dart';
// // import '../../reporting_widgets/edit_retail_screen.dart';
// // import '../../reporting_widgets/reporting_filter_section.dart';
// // import '../../reporting_widgets/retail_card.dart';
// // import '../../screens/entry_screen/retail_entry.dart';
// //
// // class Retail extends StatefulWidget {
// //   const Retail({super.key});
// //
// //   @override
// //   State<Retail> createState() => _RetailState();
// // }
// //
// // class _RetailState extends State<Retail> {
// //   final ScrollController _scrollController = ScrollController();
// //
// //   int _page = 0;
// //   int _size = 20;
// //   List<String> supplierItems = [];
// //   List<String> customerItems = [];
// //   String? selectedSupplier;
// //   String? selectedCustomer;
// //   bool isFilterApplied = false;
// //   bool _isFetchingMore = false;
// //   bool _hasMore = true;
// //   final TextEditingController fromDateController = TextEditingController();
// //
// //   final TextEditingController toDateController = TextEditingController();
// //   int? selectedCustomerId;
// //   int? selectedStaffId;
// //   bool isOpening = false;
// //   bool _showGoToTop = false;
// //
// //   void _showBottomSheetSnackBar(BuildContext context, String message) {
// //     final overlay = Overlay.of(context);
// //
// //     late OverlayEntry entry;
// //
// //     entry = OverlayEntry(
// //       builder: (context) => Positioned(
// //         left: 16,
// //         right: 16,
// //         bottom: 20,
// //         child: Material(
// //           color: Colors.transparent,
// //           child: Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// //             decoration: BoxDecoration(
// //               color: AppColors.containerFillColor,
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             child: Row(
// //               children: [
// //                 const SizedBox(width: 10),
// //                 Expanded(
// //                   child: Text(
// //                     message,
// //                     style: const TextStyle(
// //                       //color: Colors.black,
// //                       fontSize: 14,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //
// //     overlay.insert(entry);
// //
// //     Future.delayed(const Duration(seconds: 3), () {
// //       entry.remove();
// //     });
// //   }
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     final now = DateTime.now();
// //     final tenDaysAgo = now.subtract(const Duration(days: 10));
// //
// //     final formatter = DateFormat('yyyy-MM-dd');
// //     fromDateController.text = formatter.format(tenDaysAgo);
// //     toDateController.text = formatter.format(now);
// //     _scrollController.addListener(_scrollListener);
// //
// //     WidgetsBinding.instance.addPostFrameCallback((_) async {
// //       _page = 0;
// //       _hasMore = true;
// //       final entriesProvider = context.read<EntriesProvider>();
// //
// //       await entriesProvider.fetchSuppliers();
// //       await entriesProvider.fetchCustomer();
// //       await context.read<StaffProvider>().fetchStaffs();
// //       await context.read<RetailProvider>().fetchRetails(
// //         page: _page,
// //         size: _size,
// //         fromDate: fromDateController.text,
// //         toDate: toDateController.text,
// //       );
// //     });
// //   }
// //
// //   void _scrollListener() {
// //     if (!_scrollController.hasClients) return;
// //
// //     if (_scrollController.offset > 200) {
// //       if (!_showGoToTop) {
// //         setState(() => _showGoToTop = true);
// //       }
// //     } else {
// //       if (_showGoToTop) {
// //         setState(() => _showGoToTop = false);
// //       }
// //     }
// //
// //     if (_scrollController.position.pixels >=
// //             _scrollController.position.maxScrollExtent - 200 &&
// //         !_isFetchingMore &&
// //         _hasMore) {
// //       _loadMore();
// //     }
// //   }
// //
// //   Future<void> _loadMore() async {
// //     final provider = context.read<RetailProvider>();
// //
// //     if (provider.last) {
// //       setState(() => _hasMore = false);
// //       return;
// //     }
// //
// //     _isFetchingMore = true;
// //
// //     await provider.fetchRetails(
// //       page: provider.page + 1,
// //       size: _size,
// //       isLoadMore: true,
// //     );
// //
// //     _isFetchingMore = false;
// //
// //     setState(() {
// //       _hasMore = !provider.last;
// //     });
// //   }
// //
// //   void _applyFilters() async {
// //     if (fromDateController.text.isEmpty &&
// //         toDateController.text.isEmpty &&
// //         selectedSupplier == null &&
// //         selectedCustomerId == null &&
// //         selectedStaffId == null) {
// //       ScaffoldSnackBar.show(context, "Please select at least one filter.");
// //       return;
// //     }
// //     final provider = Provider.of<EntriesProvider>(context, listen: false);
// //
// //     int? supplierId;
// //
// //     if (selectedSupplier != null) {
// //       final supplier = provider.entries.firstWhere(
// //         (e) => e.supplierName == selectedSupplier,
// //       );
// //
// //       supplierId = supplier.id?.toInt();
// //     }
// //     setState(() {
// //       isFilterApplied = true;
// //     });
// //     await context.read<RetailProvider>().fetchRetails(
// //       page: 0,
// //       size: _size,
// //       fromDate: fromDateController.text.isEmpty
// //           ? null
// //           : fromDateController.text,
// //       toDate: toDateController.text.isEmpty ? null : toDateController.text,
// //       supplierId: supplierId,
// //       customerId: selectedCustomerId,
// //       staffId: selectedStaffId,
// //     );
// //     // _clearFilters();
// //   }
// //
// //   void _clearFilters() {
// //     // final now = DateTime.now();
// //     // final tenDaysAgo = now.subtract(const Duration(days: 10));
// //     // final formatter = DateFormat('yyyy-MM-dd');
// //     //   fromDateController.text = formatter.format(tenDaysAgo);
// //     //   toDateController.text = formatter.format(now);
// //
// //     setState(() {
// //       isFilterApplied = false;
// //       selectedSupplier = null;
// //       selectedCustomerId = null;
// //       selectedStaffId = null;
// //     });
// //
// //     // context.read<RetailProvider>().fetchRetails();
// //   }
// //
// //   void _showFilterBottomSheet() {
// //     String? errorMessage;
// //     final entriesProvider = Provider.of<EntriesProvider>(
// //       context,
// //       listen: false,
// //     );
// //     final staffProvider = Provider.of<StaffProvider>(context, listen: false);
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (context) {
// //         return StatefulBuilder(
// //           builder: (context, bottomSheetSetState) {
// //             return Container(
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.only(
// //                   topLeft: Radius.circular(40),
// //                   topRight: Radius.circular(40),
// //                 ),
// //               ),
// //               child: ReportingFilterSection(
// //                 fromDateController: fromDateController,
// //                 toDateController: toDateController,
// //                 dropdowns: [
// //                   FilterDropdown(
// //                     label: "Supplier",
// //                     value: selectedSupplier,
// //                     items: entriesProvider.entries
// //                         .map((e) => e.supplierName ?? '')
// //                         .where((e) => e.isNotEmpty)
// //                         .toSet()
// //                         .toList(),
// //                     onChanged: (value) {
// //                       bottomSheetSetState(() {
// //                         selectedSupplier = value;
// //                       });
// //
// //                       setState(() {
// //                         selectedSupplier = value;
// //                       });
// //                     },
// //                   ),
// //                   FilterDropdown(
// //                     label: "Referred By",
// //                     value: selectedCustomerId == null
// //                         ? null
// //                         : entriesProvider.customerEntries
// //                               .firstWhere(
// //                                 (e) => e.id!.toInt() == selectedCustomerId,
// //                               )
// //                               .customerName,
// //                     items: entriesProvider.customerEntries
// //                         .map((e) => e.customerName ?? "")
// //                         .toSet()
// //                         .toList(),
// //                     onChanged: (value) {
// //                       final customer = entriesProvider.customerEntries
// //                           .firstWhere((e) => e.customerName == value);
// //
// //                       bottomSheetSetState(() {
// //                         selectedCustomerId = customer.id!.toInt();
// //                       });
// //
// //                       setState(() {
// //                         selectedCustomerId = customer.id!.toInt();
// //                       });
// //                     },
// //                   ),
// //                   FilterDropdown(
// //                     label: "Staff",
// //                     value: selectedStaffId == null
// //                         ? null
// //                         : staffProvider.staffs
// //                               .firstWhere((e) => e.staffId == selectedStaffId)
// //                               .staffName,
// //                     items: staffProvider.staffs
// //                         .map((e) => e.staffName)
// //                         .toSet()
// //                         .toList(),
// //                     onChanged: (value) {
// //                       final staff = staffProvider.staffs.firstWhere(
// //                         (e) => e.staffName == value,
// //                       );
// //
// //                       bottomSheetSetState(() {
// //                         selectedStaffId = staff.staffId;
// //                       });
// //
// //                       setState(() {
// //                         selectedStaffId = staff.staffId;
// //                       });
// //                     },
// //                   ),
// //                 ],
// //                 onApply: () async {
// //                   final hasFilter =
// //                       fromDateController.text.isNotEmpty ||
// //                       toDateController.text.isNotEmpty ||
// //                       selectedSupplier != null ||
// //                       selectedCustomerId != null ||
// //                       selectedStaffId != null;
// //
// //                   if (!hasFilter) {
// //                     _showBottomSheetSnackBar(
// //                       context,
// //                       "Please select at least one filter.",
// //                     );
// //                     return;
// //                   }
// //
// //                   Navigator.pop(context);
// //                   _applyFilters();
// //                 },
// //                 onClear: () {
// //                   bottomSheetSetState(() {
// //                     errorMessage = null;
// //                     fromDateController.clear();
// //                     toDateController.clear();
// //                     selectedSupplier = null;
// //                     selectedCustomerId = null;
// //                   });
// //
// //                   setState(() {
// //                     selectedSupplier = null;
// //                     selectedCustomerId = null;
// //                   });
// //
// //                   _clearFilters();
// //                 },
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final size = MediaQuery.of(context).size;
// //
// //     final width = size.width;
// //     final height = size.height;
// //
// //     return Scaffold(
// //       backgroundColor: AppColors.bodyFillColor,
// //       appBar: CustomAppBar(
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back),
// //           onPressed: () {
// //             Navigator.pop(context);
// //           },
// //         ),
// //         title: "Retailers",
// //         textStyle: const TextStyle(
// //           color: Colors.white,
// //           fontWeight: FontWeight.w600,
// //           fontSize: 25,
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
// //             onPressed: () {
// //               _showFilterBottomSheet();
// //             },
// //           ),
// //         ],
// //       ),
// //       floatingActionButton: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         crossAxisAlignment: CrossAxisAlignment.end,
// //         children: [
// //           if (_showGoToTop)
// //             Padding(
// //               padding: const EdgeInsets.only(bottom: 12),
// //               child: FloatingActionButton.small(
// //                 heroTag: "top",
// //                 backgroundColor: AppColors.primaryPurple,
// //                 onPressed: () {
// //                   _scrollController.animateTo(
// //                     0,
// //                     duration: const Duration(milliseconds: 500),
// //                     curve: Curves.easeInOut,
// //                   );
// //                 },
// //                 child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
// //               ),
// //             ),
// //
// //           FloatingActionButton(
// //             heroTag: "add",
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(50),
// //             ),
// //             backgroundColor: AppColors.primaryPurple,
// //             onPressed: () async {
// //               final bool? refresh = await Navigator.push(
// //                 context,
// //                 MaterialPageRoute(builder: (_) => const RetailEntryScreen()),
// //               );
// //
// //               if (refresh == true && mounted) {
// //                 _page = 0;
// //                 _hasMore = true;
// //
// //                 await context.read<RetailProvider>().fetchRetails(
// //                   page: 0,
// //                   size: _size,
// //                   fromDate: fromDateController.text,
// //                   toDate: toDateController.text,
// //                 );
// //               }
// //             },
// //             child: const Icon(Iconsax.add, color: Colors.white, size: 40),
// //           ),
// //         ],
// //       ),
// //       body: Padding(
// //         padding: EdgeInsets.symmetric(
// //           horizontal: width * 0.04,
// //           vertical: height * 0.015,
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Expanded(
// //               child: Consumer<RetailProvider>(
// //                 builder: (context, retailProvider, child) {
// //                   if (retailProvider.isLoading) {
// //                     return const Center(child: CircularProgressIndicator());
// //                   }
// //
// //                   if (retailProvider.error != null) {
// //                     return Center(
// //                       child: Text(
// //                         retailProvider.error!,
// //                         style: const TextStyle(color: Colors.red),
// //                       ),
// //                     );
// //                   }
// //
// //                   if (retailProvider.retailEntries.isEmpty) {
// //                     return const Center(
// //                       child: Text(
// //                         "No Retailers Found",
// //                         style: TextStyle(color: Colors.white, fontSize: 18),
// //                       ),
// //                     );
// //                   }
// //                   return RefreshIndicator(
// //                     onRefresh: () async {
// //                       await retailProvider.fetchRetails();
// //                     },
// //                     child: ListView.builder(
// //                       controller: _scrollController,
// //                       itemCount:
// //                           retailProvider.retailEntries.length +
// //                           (retailProvider.last ? 0 : 1),
// //                       itemBuilder: (context, index) {
// //                         if (index == retailProvider.retailEntries.length) {
// //                           return const Padding(
// //                             padding: EdgeInsets.all(16),
// //                             child: Center(child: CircularProgressIndicator()),
// //                           );
// //                         }
// //                         final retail = retailProvider.retailEntries[index];
// //                         return Padding(
// //                           padding: EdgeInsets.all(5),
// //                           child: RetailCard(
// //                             fields: [
// //                               MapEntry("Date", retail.date),
// //                               MapEntry("Retailer", retail.name),
// //                               MapEntry("Referred By", retail.customerName),
// //                               MapEntry("Staff", retail.staffName),
// //                             ],
// //                             onTap: () {
// //                               Navigator.push(
// //                                 context,
// //                                 MaterialPageRoute(
// //                                   builder: (_) => ChangeNotifierProvider(
// //                                     create: (_) => RetailDetailsProvider(),
// //                                     child: RetailDetailsScreen(
// //                                       retailId: retail.retailId,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               );
// //                             },
// //                             onAdd: () async {
// //                               final result = await showDialog<bool>(
// //                                 context: context,
// //                                 builder: (_) =>
// //                                     AddSupplier(retailId: retail.retailId),
// //                               );
// //
// //                               if (result == true && mounted) {
// //                                 await context
// //                                     .read<RetailProvider>()
// //                                     .fetchRetails(page: 0, size: _size);
// //                               }
// //                             },
// //                             onEdit: () async {
// //                               final bool? refresh = await Navigator.push(
// //                                 context,
// //                                 MaterialPageRoute(
// //                                   builder: (_) => EditRetailScreen(
// //                                     retailId: retail.retailId,
// //                                   ),
// //                                 ),
// //                               );
// //                               if (refresh == true && mounted) {
// //                                 _page = 0;
// //
// //                                 await context
// //                                     .read<RetailProvider>()
// //                                     .fetchRetails(
// //                                       page: 0,
// //                                       size: _size,
// //                                       fromDate: fromDateController.text,
// //                                       toDate: toDateController.text,
// //                                     );
// //                               }
// //                             },
// //
// //                             onDelete: () async {
// //                               ExitConfirmationDialog.show(
// //                                 context,
// //                                 bodyText:
// //                                     "Are you sure you want to delete this retail?",
// //                                 saveButtonText: "Yes",
// //                                 discardButtonText: "No",
// //                                 onDiscard: () {
// //                                   Navigator.pop(context);
// //                                 },
// //
// //                                 onSave: () async {
// //                                   Navigator.pop(context);
// //
// //                                   final success = await context
// //                                       .read<RetailProvider>()
// //                                       .deleteRetail(retail.retailId);
// //
// //                                   if (!mounted) return;
// //
// //                                   ScaffoldSnackBar.show(
// //                                     context,
// //                                     success
// //                                         ? "Retail deleted successfully"
// //                                         : "Failed to delete retail",
// //                                   );
// //                                 },
// //                               );
// //                             },
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
