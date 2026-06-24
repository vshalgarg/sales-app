// import 'package:flutter/material.dart';
// import 'package:hisabio/screens/entry_screen/retail_entry.dart';
// import 'package:provider/provider.dart';
//
// import '../../constants/colors_used.dart';
// import '../../customs/app_bar.dart';
// import '../../provider/purchase_provider.dart';
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
//   String? selectedSupplier;
//   String? selectedCustomer;
//   List<String> suppliers = [];
//   List<String> customers = [];
//
//   bool isLoading = true;
//   @override
//   void dispose() {
//     fromDateController.dispose();
//     toDateController.dispose();
//     super.dispose();
//   }
//
//   void _applyFilters() {
//     print("From Date: ${fromDateController.text}");
//     print("To Date: ${toDateController.text}");
//     print("Supplier: $selectedSupplier");
//     print("Customer: $selectedCustomer");
//
//     //  Call API here
//   }
//
//   void _clearFilters() {
//     setState(() {
//       fromDateController.clear();
//       toDateController.clear();
//       selectedSupplier = null;
//       selectedCustomer = null;
//     });
//   }
//   void _showFilterBottomSheet() {
//     final provider = Provider.of<EntriesProvider>(
//       context,
//       listen: false,
//     );
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, bottomSheetSetState) {
//             return FractionallySizedBox(
//               heightFactor: 0.72,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFF7F6FF),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(32),
//                     topRight: Radius.circular(32),
//                   ),
//                 ),
//                 child: ReportingFilterSection(
//                   fromDateController: fromDateController,
//                   toDateController: toDateController,
//                   dropdowns: [
//                     FilterDropdown(
//                       label: "Supplier",
//                       value: selectedSupplier,
//                       items: provider.entries
//                           .map((e) => e.supplierName ?? '')
//                           .where((e) => e.isNotEmpty)
//                           .toList(),
//                       onChanged: (value) {
//                         bottomSheetSetState(() {
//                           selectedSupplier = value;
//                         });
//                         setState(() {
//                           selectedSupplier = value;
//                         });
//                       },
//                     ),
//
//                     FilterDropdown(
//                       label: "Customer",
//                       value: selectedCustomer,
//                       items: provider.customerEntries
//                           .map((e) => e.customerName ?? '')
//                           .where((e) => e.isNotEmpty)
//                           .toList(),
//                       onChanged: (value) {
//                         bottomSheetSetState(() {
//                           selectedCustomer = value;
//                         });
//
//                         setState(() {
//                           selectedCustomer = value;
//                         });
//                       },
//                     ),
//                   ],
//
//                   onApply: () {
//                     Navigator.pop(context);
//                     _applyFilters();
//                   },
//
//                   onClear: () {
//                     bottomSheetSetState(() {
//                       fromDateController.clear();
//                       toDateController.clear();
//                       selectedSupplier = null;
//                       selectedCustomer = null;
//                     });
//
//                     setState(() {
//                       fromDateController.clear();
//                       toDateController.clear();
//                       selectedSupplier = null;
//                       selectedCustomer = null;
//                     });
//                   },
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final width = size.width;
//     final height = size.height;
//     return Scaffold(
//       backgroundColor: AppColors.bodyFillColor,
//       appBar: CustomAppBar(
//         title: "Retailers",
//         textStyle: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w600,
//           fontSize: 25,
//         ),
//       ),
// floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.white,
//         child: const Icon(
//           Icons.add,
//           color: Color(0xFF9CA4DA),
//         ),
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => const RetailEntryScreen(),
//             ),
//           );
//         },
//       ),
//         body: Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: width * 0.04,
//               vertical: height * 0.015,
//             ),
//             child: Consumer<EntriesProvider>(
//                 builder: (context, provider, child) {
//                   if (provider.isLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   if (provider.error != null) {
//                     return Center(
//                       child: Text(
//                         provider.error!,
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     );
//                   }
//
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                     Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Purchases",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: width < 600
//                               ? 28
//                               : width < 900
//                               ? 32
//                               : 36,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//
//                       IconButton(
//                         icon: Icon(
//                           Icons.filter_alt_outlined,
//                           size: width * 0.075,
//                           color: Colors.white,
//                         ),
//                         onPressed: ()  {}
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: height * 0.02),
//                   Expanded(
//                   child: Consumer<PurchaseProvider>(
//                   builder: (context, purchaseProvider, child) {
//                   if (purchaseProvider.isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                   }
//
//                   if (purchaseProvider.purchaseEntries.isEmpty) {
//                   return Center(
//                   child: Text(
//                   "Apply filters to view purchase history",
//                   style: TextStyle(
//                   color: Colors.white,
//                   fontSize: width * 0.06,
//                   ),
//                   ),
//                   );
//                   }
//
//                   return ListView.builder(
//                   itemCount: purchaseProvider.purchaseEntries.length,
//                   itemBuilder: (context, index) {
//                   final purchase =
//                   purchaseProvider.purchaseEntries[index];
//
//                   return Padding(
//                   padding: EdgeInsets.only(bottom: height * 0.015),
//                   child: ReportingCard(
//                   fields: [
//                   MapEntry("Date", purchase.date),
//                   MapEntry("Staff", purchase.staffName),
//                   MapEntry("Supplier", purchase.supplierName),
//                   MapEntry("Customer", purchase.customerName),
//                   MapEntry("Remarks", purchase.remarks),
//                   ],
// onView(){},
//                   onEdit(){},
//                   onDelete(){},
//                   ),
//                   );
//                   },
//                   );
//                   },
//                   ),
//                   ),
//                     ],
//                   );
//                 },
//             ),
//         ),
//     );
//   }
// }
//
