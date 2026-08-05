// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import '../constants/colors_used.dart';
// import '../customs/app_bar.dart';
// import '../model_classes/credits/search_credit.dart';
// import '../pop_ups/general_closing_popup.dart';
// import '../provider/entries_provider/entries_section_provider.dart';
// import '../services/update_credit_api.dart';
//
// class EditCreditBottomSheet extends StatefulWidget {
//   final SearchCreditEntry credit;
//
//   const EditCreditBottomSheet({super.key, required this.credit});
//
//   @override
//   State<EditCreditBottomSheet> createState() => _EditCreditBottomSheetState();
// }
//
// class _EditCreditBottomSheetState extends State<EditCreditBottomSheet> {
//   late TextEditingController invoiceController;
//   late TextEditingController dateController;
//   late TextEditingController referenceController;
//   late TextEditingController referenceDateController;
//   late TextEditingController slipController;
//   late TextEditingController amountController;
//   late TextEditingController remarkController;
//   bool isLoading = false;
//   String? paymentType;
//   String? drawType;
//   String? supplier;
//   String? customer;
//   int? supplierId;
//   int? customerId;
//   final paymentTypes = ["CASH", "UPI", "NEFT_RTGS", "CHEQUE"];
//
//   final drawTypes = ["DRAW", "CHEQUE"];
//
//   Widget _fieldContainer({required String label, required Widget child}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 14),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(5),
//           ),
//           child: child,
//         ),
//       ],
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     supplierId = widget.credit.supplierId;
//     customerId = widget.credit.customerId;
//     invoiceController = TextEditingController(
//       text: widget.credit.billNumber ?? "",
//     );
//
//     dateController = TextEditingController(text: widget.credit.date ?? "");
//
//     referenceController = TextEditingController(
//       text: widget.credit.referenceNumber ?? "",
//     );
//
//     referenceDateController = TextEditingController(
//       text: widget.credit.referenceDate ?? "",
//     );
//
//     slipController = TextEditingController(
//       text: widget.credit.slipNumber ?? "",
//     );
//
//     final amount = widget.credit.receivedAmount ?? 0;
//
//     amountController = TextEditingController(
//       text: amount % 1 == 0
//           ? amount.toInt().toString()
//           : amount.toString(),
//     );
//     remarkController = TextEditingController(text: widget.credit.remark ?? "");
//
//     paymentType = widget.credit.paymentType;
//     drawType = widget.credit.drawType;
//     supplier = widget.credit.supplierName;
//     customer = widget.credit.customerName;
//
//     final provider = Provider.of<EntriesProvider>(context, listen: false);
//     if (provider.entries.isEmpty) {
//       provider.fetchSuppliers();
//     }
//
//     if (provider.customerEntries.isEmpty) {
//       provider.fetchCustomer();
//     }
//   }
//
//   @override
//   void dispose() {
//     invoiceController.dispose();
//     dateController.dispose();
//     referenceController.dispose();
//     referenceDateController.dispose();
//     slipController.dispose();
//     amountController.dispose();
//     remarkController.dispose();
//     super.dispose();
//   }
//
//   Future<void> pickDate(TextEditingController controller) async {
//     final picked = await showDatePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//
//     if (picked != null) {
//       controller.text =
//           "${picked.year}-"
//           "${picked.month.toString().padLeft(2, '0')}-"
//           "${picked.day.toString().padLeft(2, '0')}";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bodyFillColor,
//       body: Scaffold(
//         backgroundColor: AppColors.bodyFillColor,
//         appBar: CustomAppBar(
//           title: "Edit Credit",
//           textStyle: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 25,
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.close),
//               onPressed: () {
//                 ExitConfirmationDialog.show(
//                   context,
//                   //bodyText: "",
//                   saveButtonText: "Stay",
//                   discardButtonText: "Leave",
//                   onSave: () async {
//                     Navigator.pop(context);
//                   },
//                   onDiscard: () {
//                     Navigator.pop(context);
//                     Navigator.pop(context,false);
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//         body: SafeArea(
//           child: Container(
//             color: AppColors.bodyFillColor,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(15),
//                 child: Column(
//                   children: [
//                     _fieldContainer(
//                       label: "Invoice Number",
//                       child: TextField(
//                         controller: invoiceController,
//                         readOnly: true,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 15),
//                     _dateField(dateController, "Date"),
//                     SizedBox(height: 15),
//                     _dropdownField("Payment Type", paymentType, paymentTypes, (
//                       v,
//                     ) {
//                       setState(() {
//                         paymentType = v;
//                       });
//                     }),
//                     SizedBox(height: 15),
//                     Consumer<EntriesProvider>(
//                       builder: (context, provider, child) {
//                         final suppliers = provider.entries
//                             .map((e) => e.supplierName ?? '')
//                             .toSet()
//                             .toList();
//
//                         return _fieldContainer(
//                           label: "Supplier",
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<String>(
//                               isExpanded: true,
//                               value: suppliers.contains(supplier)
//                                   ? supplier
//                                   : null,
//                               items: suppliers.map((name) {
//                                 return DropdownMenuItem<String>(
//                                   value: name,
//                                   child: Text(
//                                     name,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (value) {
//                                 final selected = provider.entries.firstWhere(
//                                   (e) => e.supplierName == value,
//                                 );
//
//                                 setState(() {
//                                   supplier = value;
//                                   supplierId = selected.id?.toInt();
//                                 });
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     SizedBox(height: 15),
//                     Consumer<EntriesProvider>(
//                       builder: (context, provider, child) {
//                         final customers = provider.customerEntries
//                             .map((e) => e.customerName ?? '')
//                             .toSet()
//                             .toList();
//
//                         return _fieldContainer(
//                           label: "Customer",
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<String>(
//                               isExpanded: true,
//                               value: customers.contains(customer)
//                                   ? customer
//                                   : null,
//                               items: customers.map((name) {
//                                 return DropdownMenuItem<String>(
//                                   value: name,
//                                   child: Text(
//                                     name,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (value) {
//                                 final selected = provider.customerEntries
//                                     .firstWhere((e) => e.customerName == value);
//
//                                 setState(() {
//                                   customer = value;
//                                   customerId = selected.id?.toInt();
//                                 });
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     SizedBox(height: 15),
//                     _textField(referenceController, "Reference Number"),
//                     SizedBox(height: 15),
//                     _dateField(referenceDateController, "Reference Date"),
//                     SizedBox(height: 15),
//                     _textField(slipController, "Slip Number"),
//                     SizedBox(height: 15),
//                     _dropdownField("Draw Type", drawType, drawTypes, (v) {
//                       setState(() {
//                         drawType = v;
//                       });
//                     }),
//                     SizedBox(height: 15),
//                     _textField(
//                       amountController,
//                       "Received Amount",
//                       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
//                       ],
//                     ),
//                     SizedBox(height: 15),
//                     _fieldContainer(
//                       label: "Remark",
//                       child: TextField(
//                         controller: remarkController,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 15),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primaryPurple,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5),
//                           ),
//                         ),
//                         onPressed: () async {
//                           try {
//                             await updateCredit(
//                               id: widget.credit.id!,
//                               date: dateController.text,
//                               supplierId: supplierId ?? 0,
//                               paymentType: paymentType ?? "",
//                               customerId: customerId,
//                               referenceNumber: referenceController.text,
//                               referenceDate: referenceDateController.text,
//                               slipNumber: slipController.text,
//                               drawType: drawType,
//                               receivedAmount:
//                                   double.tryParse(amountController.text) ?? 0,
//                               remark: remarkController.text,
//                             );
//
//                             if (!mounted) return;
//
//                             Navigator.pop(context, true);
//                           } catch (e) {
//                             if (!mounted) return;
//                             // Navigator.pop(context, true);
//
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text("Update Failed: $e")),
//                             );
//                           }
//                         },
//                         child: const Text(
//                           "Update",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ),
//       ),
//     );
//   }
//
//   Widget _textField(
//       TextEditingController controller,
//       String label,{
//   List<TextInputFormatter>? inputFormatters,
//   TextInputType? keyboardType,
//   }) {
//     return _fieldContainer(
//       label: label,
//       child: TextField(
//         controller: controller,
//         keyboardType: keyboardType,
//         inputFormatters: inputFormatters,
//         decoration: const InputDecoration(
//             border: InputBorder.none),
//       ),
//     );
//   }
//
//   Widget _dateField(TextEditingController controller, String label) {
//     return _fieldContainer(
//       label: label,
//       child: TextField(
//         controller: controller,
//         readOnly: true,
//         decoration: InputDecoration(
//           border: InputBorder.none,
//           suffixIcon: IconButton(
//             icon: const Icon(Icons.calendar_month),
//             onPressed: () => pickDate(controller),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _dropdownField(
//     String label,
//     String? value,
//     List<String> items,
//     Function(String?) onChanged,
//   ) {
//     final safeValue = items.contains(value) ? value : null;
//
//     return _fieldContainer(
//       label: label,
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           isExpanded: true,
//           value: safeValue,
//           items: items
//               .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//               .toList(),
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }
// }
