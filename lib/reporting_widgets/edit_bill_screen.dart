// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:hisabio/customs/app_bar.dart';
// import 'package:hisabio/pop_ups/general_closing_popup.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:provider/provider.dart';
// import '../constants/colors_used.dart';
// import '../provider/entries_provider/entries_section_provider.dart';
// import '../reporting_documents_upload/reporting_upload_files.dart';
// import '../services/update_bills_api.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class EditBillScreen extends StatefulWidget {
//   final Map<String, dynamic> billData;
//
//   const EditBillScreen({super.key, required this.billData});
//
//   @override
//   State<EditBillScreen> createState() => _EditBillScreenState();
// }
// class _EditBillScreenState extends State<EditBillScreen> {
//   bool showBillInfo = true;
//   bool showSupplierInfo = false;
//   bool showCustomerInfo = false;
//   bool showBillItems = false;
//   bool showAttachments = false;
//   bool showTransportInfo = false;
//   late TextEditingController invoiceController;
//   late TextEditingController lrController;
//   late TextEditingController remarksController;
//   late TextEditingController dateController;
//   late TextEditingController receivedDateController;
//   int? selectedSupplierId;
//   int? selectedCustomerId;
//   String? selectedTransport;
//   bool isLoading = false;
//   List<File> selectedFiles = [];
//   List<Map<String, dynamic>> items = [];
//   List<String> existingImageKeys = [];
//   List<String> existingFileNames = [];
//   List<String> existingPublicUrls = [];
//
//   Widget _sectionHeader({
//     required String title,
//     required bool expanded,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: AppColors.primaryPurple,
//           borderRadius: BorderRadius.circular(5),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ),
//             Icon(
//               expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
//               color: Colors.white,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildField({required String label, required Widget child}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(color: Colors.white, fontSize: 18),
//           ),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 14),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(5),
//             ),
//             child: child,
//           ),
//           SizedBox(height: 15),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _pickAttachment() async {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.photo),
//                 title: const Text("Gallery"),
//                 onTap: () async {
//                   Navigator.pop(context);
//
//                   final file = await AttachmentPicker.pickFromGallery();
//
//                   if (file != null) {
//                     setState(() {
//                       selectedFiles.add(file);
//                     });
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.description),
//                 title: const Text("Document / PDF"),
//                 onTap: () async {
//                   Navigator.pop(context);
//
//                   final file = await AttachmentPicker.pickDocument();
//
//                   if (file != null) {
//                     setState(() {
//                       selectedFiles.add(file);
//                     });
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _editableItemField(
//     String label,
//     Map<String, dynamic> item,
//     String key,
//   ) {
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
//
//         const SizedBox(height: 8),
//
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(5),
//           ),
//           child: TextFormField(
//             initialValue: item[key]?.toString() ?? "",
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 12,
//                 vertical: 14,
//               ),
//             ),
//             onChanged: (value) {
//               item[key] = value;
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     selectedSupplierId = widget.billData['supplierId']?.toInt();
//     selectedCustomerId = widget.billData['customerId']?.toInt();
//     existingImageKeys = List<String>.from(widget.billData['objectKeys'] ?? []);
//
//     existingPublicUrls = List<String>.from(widget.billData['publicUrls'] ?? []);
//
//     existingFileNames = existingImageKeys
//         .map((e) => e.split('/').last)
//         .toList();
//     items = List<Map<String, dynamic>>.from(widget.billData['items'] ?? []);
//     if (items.isEmpty) {
//       items.add({
//         "pieces": "",
//         "grossAmount": "",
//         "discountPercent": "",
//         "discountAmount": "",
//         "addOnAmount": "",
//         "ecrAmount": "",
//         "gstPercent": "",
//         "gstAmount": "",
//       });
//     }
//
//     Future.microtask(() async {
//       final provider = Provider.of<EntriesProvider>(context, listen: false);
//
//       await Future.wait([
//         provider.fetchSuppliers(),
//         provider.fetchCustomer(),
//         provider.fetchTransport(),
//       ]);
//
//       if (!mounted) return;
//
//       setState(() {
//         selectedSupplierId = widget.billData['supplierId']?.toInt();
//
//         selectedCustomerId = widget.billData['customerId']?.toInt();
//       });
//     });
//     selectedTransport = widget.billData['transport'];
//     dateController = TextEditingController(text: widget.billData['date'] ?? '');
//
//     receivedDateController = TextEditingController(
//       text: widget.billData['receivedDate'] ?? '',
//     );
//
//     invoiceController = TextEditingController(
//       text: widget.billData['invoiceNo'] ?? '',
//     );
//
//     lrController = TextEditingController(
//       text: widget.billData['lrNumber'] ?? '',
//     );
//
//     remarksController = TextEditingController(
//       text: widget.billData['remarks'] ?? '',
//     );
//
//     selectedTransport = widget.billData['transport'];
//   }
//
//   Future<void> _previewFile(int index) async {
//     if (index >= existingPublicUrls.length) return;
//
//     final uri = Uri.parse(existingPublicUrls[index]);
//
//     await launchUrl(uri, mode: LaunchMode.externalApplication);
//   }
//
//   @override
//   void dispose() {
//     invoiceController.dispose();
//     lrController.dispose();
//     remarksController.dispose();
//     dateController.dispose();
//     receivedDateController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _updateBill() async {
//     try {
//       setState(() {
//         isLoading = true;
//       });
//
//       await updateBill(
//         id: widget.billData['id'],
//
//         date: dateController.text,
//         receivedDate: receivedDateController.text,
//
//         supplierId: selectedSupplierId ?? 0,
//         customerId: selectedCustomerId ?? 0,
//
//         transport: selectedTransport ?? '',
//
//         lrNumber: lrController.text,
//
//         remarks: remarksController.text,
//
//         taxableValue: (widget.billData['taxableValue'] ?? 0).toDouble(),
//
//         billAmount: (widget.billData['billAmount'] ?? 0).toDouble(),
//
//         billItems: items,
//
//         existingImageKeys: existingImageKeys,
//
//         files: selectedFiles,
//       );
//       if (!mounted) return;
//       Navigator.pop(context, true);
//
//       return;
//     } catch (e) {
//       debugPrint("Update Error => $e");
//
//       if (!mounted) return;
//
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }
//
//   Widget sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
//
//   Widget readOnlyField(String label, String value) {
//     return TextFormField(
//       initialValue: value,
//       enabled: false,
//       decoration: InputDecoration(
//         labelText: label,
//         filled: true,
//         fillColor: const Color(0xFFF1F3F6),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
//         disabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(6),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bodyFillColor,
//       body: Scaffold(
//         backgroundColor: AppColors.bodyFillColor,
//         appBar: CustomAppBar(
//           title: "Edit Bill",
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
//
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
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(15),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _sectionHeader(
//                     title: "Bill Information",
//                     expanded: showBillInfo,
//                     onTap: () {
//                       setState(() {
//                         showBillInfo = !showBillInfo;
//                       });
//                     },
//                   ),
//
//                   const SizedBox(height: 15),
//
//                   if (showBillInfo) ...[
//                     LayoutBuilder(
//                       builder: (context, constraints) {
//                         final isMobile = constraints.maxWidth < 700;
//
//                         Widget billNumberField = _buildField(
//                           label: "Bill Number",
//                           child: TextFormField(
//                             initialValue: widget.billData['billNumber'] ?? '',
//                             enabled: false,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         );
//
//                         Widget dateField = _buildField(
//                           label: "Date",
//                           child: TextFormField(
//                             controller: dateController,
//                             readOnly: true,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                               suffixIcon: Icon(Icons.calendar_today),
//                             ),
//                             onTap: () async {
//                               final pickedDate = await showDatePicker(
//                                 context: context,
//                                 firstDate: DateTime(2000),
//                                 lastDate: DateTime.now(),
//                               );
//
//                               if (pickedDate != null) {
//                                 dateController.text =
//                                     "${pickedDate.year}-"
//                                     "${pickedDate.month.toString().padLeft(2, '0')}-"
//                                     "${pickedDate.day.toString().padLeft(2, '0')}";
//                               }
//                             },
//                           ),
//                         );
//
//                         if (isMobile) {
//                           return Column(children: [billNumberField, dateField]);
//                         }
//
//                         return Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(child: billNumberField),
//                             const SizedBox(width: 20),
//                             Expanded(child: dateField),
//                           ],
//                         );
//                       },
//                     ),
//                     LayoutBuilder(
//                       builder: (context, constraints) {
//                         final isMobile = constraints.maxWidth < 700;
//
//                         Widget receivedField = _buildField(
//                           label: "Received Date",
//                           child: TextFormField(
//                             controller: receivedDateController,
//                             readOnly: true,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                               suffixIcon: Icon(Icons.calendar_today),
//                             ),
//                             onTap: () async {
//                               final pickedDate = await showDatePicker(
//                                 context: context,
//                                 firstDate: DateTime(2000),
//                                 lastDate: DateTime(2100),
//                               );
//
//                               if (pickedDate != null) {
//                                 receivedDateController.text =
//                                     "${pickedDate.year}-"
//                                     "${pickedDate.month.toString().padLeft(2, '0')}-"
//                                     "${pickedDate.day.toString().padLeft(2, '0')}";
//                               }
//                             },
//                           ),
//                         );
//
//                         Widget invoiceField = _buildField(
//                           label: "Invoice Number",
//                           child: TextFormField(
//                             controller: invoiceController,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         );
//
//                         if (isMobile) {
//                           return Column(
//                             children: [receivedField, invoiceField],
//                           );
//                         }
//
//                         return Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(child: receivedField),
//                             const SizedBox(width: 20),
//                             Expanded(child: invoiceField),
//                           ],
//                         );
//                       },
//                     ),
//                   ],
//
//                   //const SizedBox(height: 15),
//                   _sectionHeader(
//                     title: "Supplier Information",
//                     expanded: showSupplierInfo,
//                     onTap: () {
//                       setState(() {
//                         showSupplierInfo = !showSupplierInfo;
//                       });
//                     },
//                   ),
//
//                   const SizedBox(height: 15),
//                   if (showSupplierInfo) ...[
//                     LayoutBuilder(
//                       builder: (context, constraints) {
//                         final isMobile = constraints.maxWidth < 700;
//
//                         Widget supplierField = Consumer<EntriesProvider>(
//                           builder: (context, provider, child) {
//                             return _buildField(
//                               label: "Supplier",
//                               child: DropdownButtonHideUnderline(
//                                 child: DropdownButton<int>(
//                                   isExpanded: true,
//
//                                   value:
//                                       provider.entries.any(
//                                         (e) => e.id == selectedSupplierId,
//                                       )
//                                       ? selectedSupplierId
//                                       : null,
//
//                                   items: provider.entries.map((supplier) {
//                                     return DropdownMenuItem<int>(
//                                       value: supplier.id?.toInt(),
//                                       child: Text(
//                                         supplier.supplierName ?? "",
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     );
//                                   }).toList(),
//
//                                   onChanged: (value) {
//                                     setState(() {
//                                       selectedSupplierId = value;
//                                     });
//                                   },
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//
//                         Widget groupField = _buildField(
//                           label: "Supplier Group",
//                           child: TextFormField(
//                             initialValue:
//                                 widget.billData['supplierGroup'] ?? '',
//                             enabled: false,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         );
//
//                         if (isMobile) {
//                           return Column(children: [supplierField, groupField]);
//                         }
//
//                         return Row(
//                           children: [
//                             Expanded(child: supplierField),
//                             const SizedBox(width: 20),
//                             Expanded(child: groupField),
//                           ],
//                         );
//                       },
//                     ),
//
//                     LayoutBuilder(
//                       builder: (context, constraints) {
//                         final isMobile = constraints.maxWidth < 700;
//
//                         Widget msmeField = _buildField(
//                           label: "MSME",
//                           child: TextFormField(
//                             initialValue: widget.billData['supplierMsme'] ?? '',
//                             enabled: false,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         );
//
//                         Widget gstField = _buildField(
//                           label: "GSTIN",
//                           child: TextFormField(
//                             initialValue:
//                                 widget.billData['supplierGstNo'] ?? '',
//                             enabled: false,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         );
//
//                         if (isMobile) {
//                           return Column(children: [msmeField, gstField]);
//                         }
//
//                         return Row(
//                           children: [
//                             Expanded(child: msmeField),
//                             const SizedBox(width: 20),
//                             Expanded(child: gstField),
//                           ],
//                         );
//                       },
//                     ),
//                   ],
//
//                   _sectionHeader(
//                     title: "Customer Information",
//                     expanded: showCustomerInfo,
//                     onTap: () {
//                       setState(() {
//                         showCustomerInfo = !showCustomerInfo;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 15),
//                   if (showCustomerInfo) ...[
//                     LayoutBuilder(
//                       builder: (context, constraints) {
//                         final isMobile = constraints.maxWidth < 700;
//
//                         Widget customerField = Consumer<EntriesProvider>(
//                           builder: (context, provider, child) {
//                             return _buildField(
//                               label: "Customer",
//                               child: DropdownButtonHideUnderline(
//                                 child: DropdownButton<int>(
//                                   isExpanded: true,
//
//                                   value:
//                                       provider.customerEntries.any(
//                                         (e) => e.id == selectedCustomerId,
//                                       )
//                                       ? selectedCustomerId
//                                       : null,
//
//                                   items: provider.customerEntries.map((
//                                     customer,
//                                   ) {
//                                     return DropdownMenuItem<int>(
//                                       value: customer.id?.toInt(),
//                                       child: Text(
//                                         customer.customerName ?? "",
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     );
//                                   }).toList(),
//
//                                   onChanged: (value) {
//                                     setState(() {
//                                       selectedCustomerId = value;
//                                     });
//                                   },
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                         Widget groupField = _buildField(
//                           label: "Customer Group",
//                           child: TextFormField(
//                             initialValue:
//                                 widget.billData['customerGroup'] ?? '',
//                             enabled: false,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         );
//
//                         if (isMobile) {
//                           return Column(children: [customerField, groupField]);
//                         }
//
//                         return Row(
//                           children: [
//                             Expanded(child: customerField),
//                             const SizedBox(width: 20),
//                             Expanded(child: groupField),
//                           ],
//                         );
//                       },
//                     ),
//
//                     LayoutBuilder(
//                       builder: (context, constraints) {
//                         final isMobile = constraints.maxWidth < 700;
//
//                         Widget msmeField = _buildField(
//                           label: "MSME",
//                           child: TextFormField(
//                             initialValue: widget.billData['customerMsme'] ?? '',
//                             enabled: false,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         );
//
//                         Widget gstField = _buildField(
//                           label: "GSTIN",
//                           child: TextFormField(
//                             initialValue:
//                                 widget.billData['customerGstNo'] ?? '',
//                             enabled: false,
//                             decoration: const InputDecoration(
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         );
//
//                         if (isMobile) {
//                           return Column(children: [msmeField, gstField]);
//                         }
//
//                         return Row(
//                           children: [
//                             Expanded(child: msmeField),
//                             const SizedBox(width: 20),
//                             Expanded(child: gstField),
//                           ],
//                         );
//                       },
//                     ),
//                   ],
//
//                   _sectionHeader(
//                     title: "Bill Items",
//                     expanded: showBillItems,
//                     onTap: () {
//                       setState(() {
//                         showBillItems = !showBillItems;
//                       });
//                     },
//                   ),
//
//                   const SizedBox(height: 15),
//
//                   if (showBillItems) ...[
//                     Container(
//                       width: double.infinity,
//                       // height: 55,
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryPurple,
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: TextButton.icon(
//                         onPressed: () {
//                           setState(() {
//                             items.add({
//                               "pieces": "",
//                               "grossAmount": "",
//                               "discountPercent": "",
//                               "discountAmount": "",
//                               "addOnAmount": "",
//                               "ecrAmount": "",
//                               "gstPercent": "",
//                               "gstAmount": "",
//                             });
//                           });
//                         },
//                         icon: const Icon(Icons.add, color: Colors.white),
//                         label: const Text(
//                           "Add Bill Item",
//                           style: TextStyle(color: Colors.white, fontSize: 18),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     ...List.generate(items.length, (index) {
//                       final item = items[index];
//
//                       return Container(
//                         // margin: const EdgeInsets.only(bottom: 16),
//                         //padding: const EdgeInsets.all(15),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               width: double.infinity,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColors.primaryPurple,
//                                 borderRadius: BorderRadius.circular(5),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       "Item ${index + 1}",
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 18,
//                                       ),
//                                     ),
//                                   ),
//
//                                   IconButton(
//                                     icon: const Icon(
//                                       Iconsax.trash,
//                                       color: Colors.white,
//                                     ),
//                                     onPressed: () {
//                                       setState(() {
//                                         items.removeAt(index);
//                                       });
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                             const SizedBox(height: 16),
//
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _editableItemField(
//                                     "Pieces",
//                                     item,
//                                     "pieces",
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: _editableItemField(
//                                     "Gross Amount",
//                                     item,
//                                     "grossAmount",
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             const SizedBox(height: 12),
//
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _editableItemField(
//                                     "Disc %",
//                                     item,
//                                     "discountPercent",
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: _editableItemField(
//                                     "Disc Amount",
//                                     item,
//                                     "discountAmount",
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             const SizedBox(height: 12),
//
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _editableItemField(
//                                     "Add-On",
//                                     item,
//                                     "addOnAmount",
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: _editableItemField(
//                                     "ECR",
//                                     item,
//                                     "ecrAmount",
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             const SizedBox(height: 12),
//
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: _editableItemField(
//                                     "GST %",
//                                     item,
//                                     "gstPercent",
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: _editableItemField(
//                                     "GST Amount",
//                                     item,
//                                     "gstAmount",
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     }),
//                     const SizedBox(height: 20),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: AppColors.bodyFillColor,
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 "Taxable Value",
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                               Text(
//                                 "₹${widget.billData['taxableValue'] ?? 0}",
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           const Divider(color: Colors.white38, height: 24),
//
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 "Bill Amount",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               Text(
//                                 "₹${widget.billData['billAmount'] ?? 0}",
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                   _sectionHeader(
//                     title: "Attachments",
//                     expanded: showAttachments,
//                     onTap: () {
//                       setState(() {
//                         showAttachments = !showAttachments;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 15),
//                   if (showAttachments) ...[
//                     Container(
//                       decoration: BoxDecoration(
//                         color: AppColors.bodyFillColor,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Attachments (${existingFileNames.length})",
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//
//                           const SizedBox(height: 20),
//
//                           ...List.generate(existingFileNames.length, (index) {
//                             return Padding(
//                               padding: const EdgeInsets.only(bottom: 12),
//                               child: Stack(
//                                 clipBehavior: Clip.none,
//                                 children: [
//                                   InkWell(
//                                     onTap: () => _previewFile(index),
//                                     child: Container(
//                                       width: double.infinity,
//                                       padding: const EdgeInsets.all(16),
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           const Icon(
//                                             Icons.description_outlined,
//                                           ),
//
//                                           const SizedBox(width: 12),
//
//                                           Expanded(
//                                             child: Text(
//                                               existingFileNames[index],
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//
//                                   Positioned(
//                                     right: -8,
//                                     top: -8,
//                                     child: CircleAvatar(
//                                       radius: 14,
//                                       backgroundColor: Colors.white,
//                                       child: IconButton(
//                                         padding: EdgeInsets.zero,
//                                         iconSize: 18,
//                                         icon: const Icon(
//                                           Icons.close,
//                                           color: Colors.red,
//                                         ),
//                                         onPressed: () {
//                                           setState(() {
//                                             existingImageKeys.removeAt(index);
//
//                                             existingFileNames.removeAt(index);
//
//                                             existingPublicUrls.removeAt(index);
//                                           });
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }),
//
//                           InkWell(
//                             onTap: _pickAttachment,
//                             child: Container(
//                               width: double.infinity,
//                               height: 140,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Center(
//                                 child: Text(
//                                   "+ Add Attachment",
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     color: Color(0xFF666666),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           const SizedBox(height: 16),
//
//                           if (selectedFiles.isNotEmpty)
//                             ...List.generate(selectedFiles.length, (index) {
//                               return Padding(
//                                 padding: const EdgeInsets.only(bottom: 12),
//                                 child: Stack(
//                                   clipBehavior: Clip.none,
//                                   children: [
//                                     Container(
//                                       width: double.infinity,
//                                       padding: const EdgeInsets.all(16),
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           const Icon(Icons.attach_file),
//
//                                           const SizedBox(width: 12),
//
//                                           Expanded(
//                                             child: Text(
//                                               selectedFiles[index].path
//                                                   .split('/')
//                                                   .last,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Positioned(
//                                       right: -8,
//                                       top: -8,
//                                       child: CircleAvatar(
//                                         radius: 14,
//                                         backgroundColor: Colors.white,
//                                         child: IconButton(
//                                           padding: EdgeInsets.zero,
//                                           iconSize: 18,
//                                           icon: const Icon(
//                                             Icons.close,
//                                             color: Colors.red,
//                                           ),
//                                           onPressed: () {
//                                             setState(() {
//                                               selectedFiles.removeAt(index);
//                                             });
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }),
//                           SizedBox(height: 15),
//                         ],
//                       ),
//                     ),
//                   ],
//
//                   _sectionHeader(
//                     title: "Transport & Logistics Information",
//                     expanded: showTransportInfo,
//                     onTap: () {
//                       setState(() {
//                         showTransportInfo = !showTransportInfo;
//                       });
//                     },
//                   ),
//
//                   const SizedBox(height: 15),
//                   if (showTransportInfo) ...[
//                     Consumer<EntriesProvider>(
//                       builder: (context, provider, child) {
//                         return _buildField(
//                           label: "Transport",
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<String>(
//                               isExpanded: true,
//                               value: selectedTransport,
//                               items: provider.transportDetails
//                                   .map(
//                                     (transport) => DropdownMenuItem<String>(
//                                       value: transport.name,
//                                       child: Text(
//                                         transport.name ?? "",
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   )
//                                   .toList(),
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedTransport = value;
//                                 });
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//
//                     _buildField(
//                       label: "LR Number",
//                       child: TextFormField(
//                         controller: lrController,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//
//                     _buildField(
//                       label: "Remarks",
//                       child: TextFormField(
//                         controller: remarksController,
//                         //maxLines: 3,
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 15),
//
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: isLoading ? null : _updateBill,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primaryPurple,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(5),
//                             ),
//                           ),
//                           child: isLoading
//                               ? const SizedBox(
//                                   height: 18,
//                                   width: 18,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                   ),
//                                 )
//                               : const Text(
//                                   "Update",
//                                   style: TextStyle(color: Color(0xFFFFFFFF)),
//                                 ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
