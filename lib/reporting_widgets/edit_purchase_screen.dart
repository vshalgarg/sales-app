// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:hisabio/reporting_widgets/pdf_preview_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../constants/colors_used.dart';
// import '../customs/app_bar.dart';
// import '../customs/dropdown_test.dart';
// import '../model_classes/get_purchase_model.dart';
// import '../pop_ups/general_closing_popup.dart';
// import '../provider/entries_provider/entries_section_provider.dart';
// import '../provider/staff_provider.dart';
// import '../provider/update_purchase_provider.dart';
// import '../reporting_documents_upload/reporting_upload_files.dart';
// import 'image_preview_screen.dart';
//
// class EditPurchaseScreen extends StatefulWidget {
//   final PurchaseDetails purchaseData;
//
//   const EditPurchaseScreen({super.key, required this.purchaseData});
//
//   @override
//   State<EditPurchaseScreen> createState() => _EditPurchaseScreenState();
// }
//
// class _EditPurchaseScreenState extends State<EditPurchaseScreen> {
//   final ScrollController _scrollController = ScrollController();
//   late TextEditingController remarksController;
//   late TextEditingController dateController;
//   bool basicInfoExpanded = true;
//   bool attachmentExpanded = false;
//   int? selectedCustomerId;
//   int? selectedSupplierId;
//   int? selectedStaffId;
//   String? selectedCustomerName;
//   String? selectedSupplierName;
//   String? selectedStaffName;
//   bool isLoading = false;
//   List<File> selectedFiles = [];
//
//   late List<String> existingImageKeys = [];
//   List<String> existingFileNames = [];
//   List<String> existingUrls = [];
//
//   Widget _sectionHeader({
//     required String title,
//     required bool isExpanded,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(5),
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
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18),
//               ),
//             ),
//             const Icon(Icons.keyboard_arrow_down,
//                 color: Colors.white),
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
//
//           Container(
//            width: double.infinity,
//            // padding: const EdgeInsets.symmetric(horizontal: 14),
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
//     final totalAttachments = existingFileNames.length + selectedFiles.length;
//
//     if (totalAttachments >= 3) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("You can attach a maximum of 3 files.")),
//       );
//       return;
//     }
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
//   @override
//   void initState() {
//     super.initState();
//
//     _initializeData();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         _loadData();
//       }
//     });
//   }
//
//   void _initializeData() {
//     final supplier = widget.purchaseData.supplier;
//
//     existingImageKeys = supplier.images.map((e) => e.key).toList();
//
//     existingUrls = supplier.images.map((e) => e.url).toList();
//     debugPrint(existingUrls.toString());
//     existingFileNames = supplier.images.map((e) => e.fileName).toList();
//
//     remarksController = TextEditingController(
//       text: widget.purchaseData.remarks,
//     );
//
//     dateController = TextEditingController(text: widget.purchaseData.date);
//
//     selectedCustomerId = widget.purchaseData.customerId;
//
//     selectedStaffId = widget.purchaseData.staffId;
//
//     selectedSupplierId = supplier.supplierId;
//     selectedCustomerName = widget.purchaseData.customerName;
//     selectedStaffName = widget.purchaseData.staffName;
//     selectedSupplierName = supplier.supplierName;
//   }
//
//   Future<void> _loadData() async {
//     try {
//       final entriesProvider = context.read<EntriesProvider>();
//
//       final staffProvider = context.read<StaffProvider>();
//
//       await Future.wait([
//         entriesProvider.fetchCustomer(),
//         entriesProvider.fetchSuppliers(),
//         staffProvider.fetchStaffs(),
//       ]);
//     } catch (e) {
//       debugPrint("Error loading dropdown data: $e");
//     }
//   }
//
//   Future<void> _previewFile(int index) async {
//     final url = existingUrls[index];
//     final lower = url.toLowerCase();
//
//     if (lower.endsWith(".png") ||
//         lower.endsWith(".jpg") ||
//         lower.endsWith(".jpeg") ||
//         lower.endsWith(".gif") ||
//         lower.endsWith(".webp")) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => ImagePreviewScreen(imageUrl: url)),
//       );
//     } else if (lower.endsWith(".pdf")) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => PdfPreviewScreen(pdfUrl: url)),
//       );
//     } else {
//       // DOC, DOCX, XLS, XLSX, PPT, etc.
//       final uri = Uri.parse(url);
//
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }
//
//   Future<void> _previewSelectedFile(File file) async {
//     final path = file.path.toLowerCase();
//
//     if (path.endsWith(".png") ||
//         path.endsWith(".jpg") ||
//         path.endsWith(".jpeg") ||
//         path.endsWith(".gif") ||
//         path.endsWith(".webp")) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => Scaffold(
//             backgroundColor: Colors.black,
//             appBar: AppBar(),
//             body: Center(child: Image.file(file)),
//           ),
//         ),
//       );
//     } else if (path.endsWith(".pdf")) {
//       await launchUrl(
//         Uri.file(file.path),
//         mode: LaunchMode.externalApplication,
//       );
//     } else {
//       await launchUrl(
//         Uri.file(file.path),
//         mode: LaunchMode.externalApplication,
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     remarksController.dispose();
//     dateController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _updatePurchase() async {
//     final provider = context.read<UpdatePurchaseProvider>();
//
//     final success = await provider.updatePurchaseEntry(
//       id: widget.purchaseData.id,
//       date: dateController.text,
//       customerId: selectedCustomerId!,
//       supplierId: selectedSupplierId!,
//       staffId: selectedStaffId!,
//       remarks: remarksController.text.trim(),
//       existingImageKeys: existingImageKeys,
//       supplierImages: selectedFiles,
//     );
//     print(existingImageKeys);
//     if (!mounted) return;
//
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             provider.successMessage ?? "Purchase updated successfully",
//           ),
//         ),
//       );
//
//       Navigator.pop(context, true);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(provider.errorMessage ?? "Failed to update purchase"),
//         ),
//       );
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
//           title: "Edit Purchase",
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
//                     Navigator.pop(context, false);
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
//               controller: _scrollController,
//               padding: const EdgeInsets.all(15),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _sectionHeader(
//                     title: "Basic Information",
//                     isExpanded: basicInfoExpanded,
//                     onTap: () {
//                       setState(() {
//                         basicInfoExpanded = !basicInfoExpanded;
//                       });
//                     },
//                   ),
//
//                   if (basicInfoExpanded) ...[
//                     SizedBox(height: 15),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: AppColors.bodyFillColor,
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           LayoutBuilder(
//                             builder: (context, constraints) {
//                               final isMobile = constraints.maxWidth < 700;
//
//                               Widget customerField = Consumer<EntriesProvider>(
//                                 builder: (_, provider, __) {
//                                   return _buildField(
//                                     label: "Customer",
//                                     child: CustomDropdown(
//                                       hintText: "Customer",
//                                       items: provider.customerEntries
//                                           .map((e) => e.customerName ?? '')
//                                           .toList(),
//                                       initialValue: selectedCustomerName,
//                                       onChanged: (value) {
//                                         final customer = provider.customerEntries.firstWhere(
//                                               (e) => e.customerName == value,
//                                         );
//
//                                         setState(() {
//                                           selectedCustomerName = value;
//                                           selectedCustomerId = customer.id?.toInt();
//                                         });
//                                       },
//                                     ),
//                                   );
//                                 },
//                               );
//
//                               Widget staffField = Consumer<StaffProvider>(
//                                 builder: (_, provider, __) {
//                                   return _buildField(
//                                     label: "Staff",
//                                     child: CustomDropdown(
//                                       hintText: "Staff",
//                                       items: provider.staffs
//                                           .map((e) => e.staffName)
//                                           .toList(),
//                                       initialValue: selectedStaffName,
//                                       onChanged: (value) {
//                                         final staff = provider.staffs.firstWhere(
//                                               (e) => e.staffName == value,
//                                         );
//
//                                         setState(() {
//                                           selectedStaffName = value;
//                                           selectedStaffId = staff.staffId;
//                                         });
//                                       },
//                                     ),
//                                   );
//                                 },
//                               );
//
//                               if (isMobile) {
//                                 return Column(
//                                   children: [customerField, staffField],
//                                 );
//                               }
//
//                               return Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Expanded(child: customerField),
//                                   const SizedBox(width: 20),
//                                   Expanded(child: staffField),
//                                 ],
//                               );
//                             },
//                           ),
//
//                           _buildField(
//                             label: "Transaction Date",
//                             child: TextFormField(
//                               controller: dateController,
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 15,
//                                   vertical: 15
//                               ),
//                             ),
//                           ),
//                           ),
//
//                           Consumer<EntriesProvider>(
//                             builder: (_, provider, __) {
//                               return _buildField(
//                                 label: "Supplier",
//                                 child:CustomDropdown(
//                                   hintText: "Supplier",
//                                   items: provider.entries
//                                       .map((e) => e.supplierName ?? '')
//                                       .toList(),
//                                   initialValue: selectedSupplierName,
//                                   onChanged: (value) {
//                                     final supplier = provider.entries.firstWhere(
//                                           (e) => e.supplierName == value,
//                                     );
//
//                                     setState(() {
//                                       selectedSupplierName = value;
//                                       selectedSupplierId = supplier.id?.toInt();
//                                     });
//                                   },
//                                 ),
//                               );
//                             },
//                           ),
//
//                           _buildField(
//                             label: "Remarks",
//                             child: TextFormField(
//                               controller: remarksController,
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 15,
//                                     vertical: 14
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//
//                   const SizedBox(height: 20),
//
//                   _sectionHeader(
//                     title: "Attachments",
//                     isExpanded: attachmentExpanded,
//                     onTap: () {
//                       setState(() {
//                         attachmentExpanded = !attachmentExpanded;
//                       });
//                       if (attachmentExpanded) {
//                         WidgetsBinding.instance.addPostFrameCallback((_) {
//                           _scrollController.animateTo(
//                             _scrollController.position.maxScrollExtent,
//                             duration: const Duration(milliseconds: 400),
//                             curve: Curves.easeInOut,
//                           );
//                         });
//                       }
//                     },
//                   ),
//
//                   if (attachmentExpanded) ...[
//                     Container(
//                       // padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: AppColors.bodyFillColor,
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(height: 10),
//                           Text(
//                             "Attachments (${existingFileNames.length + selectedFiles.length})",
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                             ),
//                           ),
//
//                           const SizedBox(height: 20),
//
//                           if (existingFileNames.isNotEmpty)
//                             ...List.generate(existingFileNames.length, (index) {
//                               return Padding(
//                                 padding: const EdgeInsets.only(bottom: 12),
//                                 child: Stack(
//                                   clipBehavior: Clip.none,
//                                   children: [
//                                     InkWell(
//                                       onTap: () => _previewFile(index),
//                                       child: Container(
//                                         width: double.infinity,
//                                         padding: const EdgeInsets.all(16),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(5,),
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     existingFileNames[index],
//                                                     maxLines: 1,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     style: const TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//
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
//                                               existingImageKeys.removeAt(index);
//
//                                               existingFileNames.removeAt(index);
//
//                                               existingUrls.removeAt(index);
//                                             });
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }),
//                           if (selectedFiles.isNotEmpty)
//                             ...List.generate(selectedFiles.length, (index) {
//                               final file = selectedFiles[index];
//
//                               return Padding(
//                                 padding: const EdgeInsets.only(bottom: 12),
//                                 child: Stack(
//                                   clipBehavior: Clip.none,
//                                   children: [
//                                     InkWell(
//                                       onTap: () => _previewSelectedFile(file),
//                                       child: Container(
//                                         width: double.infinity,
//                                         padding: const EdgeInsets.all(16),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(5,),
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     file.path.split('/').last,
//                                                     maxLines: 1,
//                                                     overflow: TextOverflow.ellipsis,
//                                                     style: const TextStyle(
//                                                       fontWeight: FontWeight.w600,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(height: 4),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
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
//                           if (existingFileNames.length + selectedFiles.length <
//                               3)
//                             InkWell(
//                               onTap: _pickAttachment,
//                               child: Container(
//                                 width: double.infinity,
//                                 padding: const EdgeInsets.all(20),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(5),
//                                 ),
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       Icons.cloud_upload_outlined,
//                                       size: 40,
//                                       color: AppColors.primaryPurple,
//                                     ),
//                                     SizedBox(height: 10),
//                                     Text(
//                                       "Upload a File",
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         color: AppColors.primaryPurple,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ]
//     ),
//     ),
//                           ],
//                           const SizedBox(height: 10),
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: _updatePurchase,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppColors.primaryPurple,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(5),
//                                 ),
//                               ),
//                               child: const Text(
//                                 "Update",
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
