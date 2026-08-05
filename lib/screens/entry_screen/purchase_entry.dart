import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/colors_used.dart';
import '../../customs/app_bar.dart';
import '../../customs/dropdown_test.dart';
import '../../customs/elevated_button.dart';
import '../../entry_widgets/custom_container_entry.dart';
import '../../entry_widgets/custom_date_textfield.dart';
import '../../entry_widgets/custom_textfield.dart';
import '../../dialog_boxes/entry_dialogboxes/bill_section_upload_documents_dialog.dart';
import '../../enums/customer_mode.dart';
import '../../model_classes/entries/entries_customer_model.dart';
import '../../model_classes/entries/entries_supplier.dart';
import '../../model_classes/entries/get_staff_entry.dart';
import '../../model_classes/purchases/add_purchase_request.dart';
import '../../model_classes/purchases/get_purchase_model.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/purchase_provider.dart';

class PurchaseEntryScreen extends StatefulWidget {
  final FormMode mode;
  final num? id;

  const PurchaseEntryScreen({super.key, this.mode = FormMode.add, this.id});

  @override
  State<PurchaseEntryScreen> createState() => _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends State<PurchaseEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final ScrollController _scrollController = ScrollController();

  bool isInformationExpanded = true;

  bool isSupplierExpanded = true;

  EntriesCustomerModel? selectedCustomer;

  GetStaffEntry? selectedStaff;

  final transactionController = TextEditingController();

  List<TextEditingController> remarksControllers = [TextEditingController()];
  List<String> existingUrls = [];
  List<EntriesModel?> selectedSuppliers = [null];

  List<List<PlatformFile>> uploadedFiles = [[]];

  bool get isViewMode => widget.mode == FormMode.view;

  bool get isEditMode => widget.mode == FormMode.edit;

  bool get isAddMode => widget.mode == FormMode.add;

  @override
  void initState() {
    super.initState();

    transactionController.text = DateFormat(
      "yyyy-MM-dd",
    ).format(DateTime.now());

    Future.microtask(() async {
      final purchaseProvider = context.read<PurchaseProvider>();

      if (isAddMode) {
        purchaseProvider.clearDetails();
      }

      final entriesProvider = context.read<EntriesProvider>();

      await Future.wait([
        entriesProvider.fetchCustomer(),
        entriesProvider.fetchSuppliers(),
        entriesProvider.fetchStaff(),
      ]);

      if (widget.id != null) {
        final success =
        await purchaseProvider.fetchPurchaseDetails(widget.id!);

        if (success && purchaseProvider.purchaseDetails != null) {
          _fillData(
            purchaseProvider.purchaseDetails!,
            entriesProvider,
          );
        }
      }
    });
  }

  void _fillData(PurchaseDetails purchase, EntriesProvider entriesProvider) {
    transactionController.text = purchase.date;

    selectedCustomer = entriesProvider.customerEntries.firstWhere(
      (e) => e.id == purchase.customerId,
    );

    selectedStaff = entriesProvider.staffList.firstWhere(
      (e) => e.staffId == purchase.staffId,
    );

    remarksControllers.clear();
    selectedSuppliers.clear();
    uploadedFiles.clear();

    remarksControllers.add(TextEditingController(text: purchase.remarks));

    if (purchase.supplier != null) {
      selectedSuppliers.add(
        entriesProvider.entries.firstWhere(
          (e) => e.id == purchase.supplier!.supplierId,
        ),
      );
      // } else {
      //   selectedSuppliers.add(null);
      // }
      uploadedFiles.add([]);

      setState(() {});
    }
  }

  void clearFields() {
    _formKey.currentState?.reset();

    transactionController.text = DateFormat(
      "yyyy-MM-dd",
    ).format(DateTime.now());

    setState(() {
      selectedCustomer = null;

      selectedStaff = null;

      remarksControllers = [TextEditingController()];

      selectedSuppliers = [null];

      uploadedFiles = [[]];
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    transactionController.dispose();

    for (final controller in remarksControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntriesProvider>();
    final purchaseProvider = context.watch<PurchaseProvider>();
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        title: widget.mode == FormMode.view
            ? "Purchase Details"
            : widget.mode == FormMode.edit
            ? "Edit Purchase"
            : "Add Purchase",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
        leading: widget.mode == FormMode.view
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : null,

        actions: [
          if (widget.mode != FormMode.view)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ExitConfirmationDialog.show(
                  context,
                  onSave: () async {
                    Navigator.pop(context);
                  },
                  discardButtonText: "Leave",
                  saveButtonText: "Stay",
                  onDiscard: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isInformationExpanded = !isInformationExpanded;
                        });
                      },
                      child: EntryContainer(
                        children: [
                          TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.primaryPurple,
                              hintText: "Information",
                              hintStyle: const TextStyle(color: Colors.white),
                              suffixIcon: Icon(
                                isInformationExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          if (isInformationExpanded) ...[
                            const SizedBox(height: 10),

                            const Text(
                              "Customer",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),

                            Consumer<EntriesProvider>(
                              builder: (context, provider, child) {
                                return CustomDropdown(
                                  isDisabled: isViewMode,
                                  hintText: "Customer *",
                                  isRequired: true,
                                  items: provider.customerEntries
                                      .map((e) => e.customerName ?? "")
                                      .toList(),
                                  initialValue: selectedCustomer?.customerName,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Customer is required";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCustomer = provider
                                          .customerEntries
                                          .firstWhere(
                                            (e) => e.customerName == value,
                                          );
                                    });
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "Staff",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),

                            Consumer<EntriesProvider>(
                              builder: (context, provider, child) {
                                return CustomDropdown(
                                  isDisabled: isViewMode,
                                  hintText: "Staff",
                                  items: provider.staffList
                                      .map((e) => e.staffName ?? "")
                                      .toList(),
                                  initialValue: selectedStaff?.staffName,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedStaff = provider.staffList
                                          .firstWhere(
                                            (e) => e.staffName == value,
                                          );
                                    });
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "Transaction Date",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),

                            EntryDateTextField(
                              enabled: !isViewMode,
                              label: "Transaction Date",
                              controller: transactionController,
                            ),

                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isSupplierExpanded = !isSupplierExpanded;
                        });
                      },
                      child: EntryContainer(
                        children: [
                          TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.primaryPurple,
                              hintText: "Suppliers",
                              hintStyle: const TextStyle(color: Colors.white),
                              suffixIcon: Icon(
                                isSupplierExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          if (isSupplierExpanded) ...[
                            const SizedBox(height: 10),

                            if (isAddMode)
                              CustomElevatedButton(
                                color: AppColors.primaryPurple,
                                text: "+ Add More Supplier",
                                textStyle: const TextStyle(color: Colors.white),
                                borderRadius: 5,
                                onPressed: () async {
                                  setState(() {
                                    remarksControllers.add(
                                      TextEditingController(),
                                    );

                                    selectedSuppliers.add(null);

                                    uploadedFiles.add([]);
                                  });
                                },
                              ),

                            const SizedBox(height: 10),

                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: selectedSuppliers.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 15),
                                  decoration: BoxDecoration(
                                    color: AppColors.bodyFillColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Supplier ${index + 1}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),

                                            if (!isAddMode &&
                                                selectedSuppliers.length > 1)
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    remarksControllers.removeAt(
                                                      index,
                                                    );

                                                    selectedSuppliers.removeAt(
                                                      index,
                                                    );

                                                    uploadedFiles.removeAt(
                                                      index,
                                                    );
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                              ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        Consumer<EntriesProvider>(
                                          builder: (context, provider, child) {
                                            return CustomDropdown(
                                              isDisabled: isViewMode,
                                              hintText: "Supplier *",
                                              isRequired: true,
                                              items: provider.entries
                                                  .map(
                                                    (e) => e.supplierName ?? "",
                                                  )
                                                  .toList(),
                                              initialValue:
                                                  selectedSuppliers[index]
                                                      ?.supplierName,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Supplier is required";
                                                }

                                                return null;
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedSuppliers[index] =
                                                      provider.entries
                                                          .firstWhere(
                                                            (e) =>
                                                                e.supplierName ==
                                                                value,
                                                          );
                                                });
                                              },
                                            );
                                          },
                                        ),

                                        const SizedBox(height: 10),

                                        const Text(
                                          "Remarks",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),

                                        EntryTextField(
                                          enabled: !isViewMode,
                                          controller: remarksControllers[index],
                                          hintText: "Remarks",
                                        ),

                                        const SizedBox(height: 10),
                                        if (isViewMode)
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Documents",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),

                                              const SizedBox(height: 10),

                                              if ((purchaseProvider.purchaseDetails?.supplier?.images.isEmpty ?? true))
                                                Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.all(14),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "No Documents Uploaded",
                                                      style: TextStyle(color: Colors.grey),
                                                    ),
                                                  ),
                                                )
                                              else
                                                Column(
                                                  children:
                                                  purchaseProvider.purchaseDetails!.supplier!.images.map((image) {
                                                    return Container(
                                                      margin: const EdgeInsets.only(bottom: 10),
                                                      padding: const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: InkWell(
                                                        onTap: () async {
                                                          final uri = Uri.parse(image.url ?? "");

                                                          await launchUrl(
                                                            uri,
                                                            mode: LaunchMode.externalApplication,
                                                          );
                                                        },
                                                        child: Row(
                                                          children: [

                                                            Expanded(
                                                              child: Text(
                                                                image.fileName ?? "",
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: const TextStyle(
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                            ],
                                          )
                                        else
                                          GestureDetector(
                                            onTap: isViewMode
                                                ? null
                                                : () async {
                                                    final remainingSlots =
                                                        3 -
                                                        existingUrls.length -
                                                        uploadedFiles[index]
                                                            .length;

                                                    if (remainingSlots <= 0) {
                                                      ScaffoldSnackBar.show(
                                                        context,
                                                        "Maximum 3 files can be uploaded",
                                                      );
                                                      return;
                                                    }

                                                    final files =
                                                        await showDialog<
                                                          List<PlatformFile>
                                                        >(
                                                          context: context,
                                                          builder: (_) => BillEntryUploadDocuments(
                                                            files: uploadedFiles[index],

                                                            existingFileNames: isEditMode
                                                                ? purchaseProvider.purchaseDetails?.supplier.images
                                                                .map((e) => e.fileName)
                                                                .toList() ??
                                                                []
                                                                : [],
                                                            existingUrls: isEditMode
                                                                ? purchaseProvider.purchaseDetails?.supplier.images
                                                                .map((e) => e.url)
                                                                .toList() ??
                                                                []
                                                                : [],

                                                            isViewMode: isViewMode,
                                                            isEditMode: isEditMode,
                                                          ),
                                                        );

                                                    if (files != null) {
                                                      setState(() {
                                                        uploadedFiles[index] =
                                                            files;
                                                      });
                                                    }
                                                  },
                                            child: Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 14,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFE4D9FF,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 46,
                                                    width: 46,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFF4F0FF,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons
                                                          .cloud_upload_outlined,
                                                      color: AppColors
                                                          .primaryPurple,
                                                    ),
                                                  ),

                                                  const SizedBox(width: 14),

                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          "Upload Documents",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .primaryPurple,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 3,
                                                        ),
                                                        Text(
                                                          "JPG, PNG, PDF • Max 3 files",
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFF4F0FF,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                "${(isEditMode
                                ? purchaseProvider.purchaseDetails?.supplier?.images.length ?? 0
                                    : 0) + uploadedFiles[index].length}/3",
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .primaryPurple,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                        //           Row(
                                        //             children: [
                                        //               GestureDetector(
                                        //                 onTap: () async {
                                        //                   final files =
                                        //                   await showDialog<
                                        //                       List<PlatformFile>
                                        //                   >(
                                        //                     context: context,
                                        //                     builder: (_) => BillEntryUploadDocuments(
                                        //                       files: uploadedFiles[index],
                                        //                       existingFileNames:
                                        //                       purchaseProvider.purchaseDetails?.supplier?.images
                                        //                           .map((e) => e.fileName ?? "")
                                        //                           .toList() ??
                                        //                           [],
                                        //                       existingUrls:
                                        //                       purchaseProvider.purchaseDetails?.supplier?.images
                                        //                           .map((e) => e.url ?? "")
                                        //                           .toList() ??
                                        //                           [],
                                        //                     ),
                                        //                   );
                                        //
                                        //                   if (files != null) {
                                        //                     setState(() {
                                        //                       uploadedFiles[index] =
                                        //                           files;
                                        //                     });
                                        //                   }
                                        //                 },
                                        //                 child: Container(
                                        //                   padding:
                                        //                   const EdgeInsets.symmetric(
                                        //                     horizontal: 10,
                                        //                     vertical: 8,
                                        //                   ),
                                        //                   decoration: BoxDecoration(
                                        //                     color: AppColors
                                        //                         .primaryPurpleLight,
                                        //                     borderRadius:
                                        //                     BorderRadius.circular(
                                        //                       10,
                                        //                     ),
                                        //                   ),
                                        //                   child: Row(
                                        //                     mainAxisSize:
                                        //                     MainAxisSize.min,
                                        //                     children: const [
                                        //                       Icon(
                                        //                         Icons.upload_file,
                                        //                         color: AppColors
                                        //                             .primaryPurple,
                                        //                       ),
                                        //
                                        //                       SizedBox(width: 6),
                                        //
                                        //                       Text(
                                        //                         "Upload Documents",
                                        //                         style: TextStyle(
                                        //                           color: AppColors
                                        //                               .primaryPurple,
                                        //                         ),
                                        //                       ),
                                        //                     ],
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //
                                        //               const SizedBox(width: 12),
                                        //
                                        //               Text(
                                        //                 "${uploadedFiles[index].length} Files",
                                        //                 style: const TextStyle(
                                        //                   color: Colors.white,
                                        //                 ),
                                        //               ),
                                        //             ],
                                        //           ),
                                        //
                                        //         if (isViewMode &&
                                        // (purchaseProvider.purchaseDetails?.supplier.images.isNotEmpty ?? false))
                                        //           Padding(
                                        //             padding: const EdgeInsets.only(
                                        //               top: 8,
                                        //             ),
                                        //             child: Text(
                                        // "${purchaseProvider.purchaseDetails?.supplier.images.length ?? 0} Documents",
                                        //               style: const TextStyle(
                                        //                 color: Colors.white,
                                        //               ),
                                        //             ),
                                        //           ),
                                        //       ],
                                        //     ),
                                        //   ),
                                        // );
                                        //           },
                                        //         ),
                                        //       ],
                                        //     ],
                                        //   ),
                                        // ),
                                        const SizedBox(height: 20),
                                        if (isAddMode)
                                          Row(
                                            children: [
                                              Expanded(
                                                child: CustomElevatedButton(
                                                  text: "Reset",
                                                  textStyle: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                  ),
                                                  borderRadius: 5,
                                                  onPressed: () async {
                                                    clearFields();
                                                  },
                                                ),
                                              ),

                                              const SizedBox(width: 20),

                                              Expanded(
                                                child: CustomElevatedButton(
                                                  color:
                                                      AppColors.primaryPurple,
                                                  text: "Save",
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                  ),
                                                  borderRadius: 5,
                                                  onPressed: () async {
                                                    if (!_formKey.currentState!
                                                        .validate()) {
                                                      ScaffoldSnackBar.show(
                                                        context,
                                                        "Please fill all the required fields",
                                                      );
                                                      return;
                                                    }

                                                    if (selectedCustomer ==
                                                        null) {
                                                      ScaffoldSnackBar.show(
                                                        context,
                                                        "Please select customer",
                                                      );
                                                      return;
                                                    }

                                                    if (selectedSuppliers.any(
                                                      (e) => e == null,
                                                    )) {
                                                      ScaffoldSnackBar.show(
                                                        context,
                                                        "Please select all suppliers",
                                                      );
                                                      return;
                                                    }

                                                    final request = AddPurchaseRequest(
                                                      date:
                                                          transactionController
                                                              .text,
                                                      staffId: selectedStaff
                                                          ?.staffId,
                                                      customerId:
                                                          selectedCustomer!.id!,
                                                      suppliers: List.generate(
                                                        selectedSuppliers
                                                            .length,
                                                        (
                                                          index,
                                                        ) => PurchaseSupplierRequest(
                                                          supplierId:
                                                              selectedSuppliers[index]!
                                                                  .id!,
                                                          remarks:
                                                              remarksControllers[index]
                                                                  .text
                                                                  .trim(),
                                                        ),
                                                      ),
                                                    );

                                                    final success = await context
                                                        .read<
                                                          PurchaseProvider
                                                        >()
                                                        .addPurchase(
                                                          request: request,
                                                          uploadedFiles:
                                                              uploadedFiles,
                                                          selectedSuppliers:
                                                              selectedSuppliers,
                                                        );

                                                    // if (!mounted) return;
                                                    //
                                                    // ScaffoldSnackBar.show(
                                                    // context,
                                                    // success
                                                    // ? "Purchase saved successfully"
                                                    //     : "Failed to save purchase",
                                                    // );

                                                    if (success) {
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "Failed to add purchase",
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),

                                        if (isEditMode)
                                          CustomElevatedButton(
                                            color: AppColors.primaryPurple,
                                            text: "Update",
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                            borderRadius: 5,
                                            onPressed: () async {
                                              if (!_formKey.currentState!
                                                  .validate()) {
                                                ScaffoldSnackBar.show(
                                                  context,
                                                  "Please fill all the required fields",
                                                );
                                                return;
                                              }

                                              final success = await context
                                                  .read<PurchaseProvider>()
                                                  .updatePurchase(
                                                    id: widget.id!,
                                                    date: transactionController
                                                        .text,
                                                    customerId:
                                                        selectedCustomer!.id!,
                                                    supplierId:
                                                        selectedSuppliers
                                                            .first!
                                                            .id!,
                                                    staffId:
                                                        selectedStaff
                                                            ?.staffId ??
                                                        0,
                                                    remarks: remarksControllers
                                                        .first
                                                        .text,
                                                    existingImageKeys:
                                                        purchaseProvider
                                                            .purchaseDetails
                                                            ?.supplier
                                                            ?.images
                                                            .map(
                                                              (e) =>
                                                                  e.key ?? "",
                                                            )
                                                            .where(
                                                              (e) =>
                                                                  e.isNotEmpty,
                                                            )
                                                            .toList() ??
                                                        [],
                                                    supplierImages:
                                                        uploadedFiles.first
                                                            .where(
                                                              (e) =>
                                                                  e.path !=
                                                                  null,
                                                            )
                                                            .map(
                                                              (e) =>
                                                                  File(e.path!),
                                                            )
                                                            .toList(),
                                                  );

                                              if (!success) {
                                                if (!mounted) return;

                                                ScaffoldSnackBar.show(
                                                  context,
                                                  "Failed to update purchase",
                                                );
                                                return;
                                              }

                                              if (!mounted) return;

                                              ScaffoldSnackBar.show(
                                                context,
                                                "Purchase updated successfully",
                                              );
                                              await context
                                                  .read<PurchaseProvider>()
                                                  .refreshPurchases();
                                              Navigator.pop(context, true);
                                            },
                                          ),

                                        const SizedBox(height: 40),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Consumer<PurchaseProvider>(
                            // builder: (context, provider, child) {
                            // if (!provider.actionLoading) {
                            // return const SizedBox.shrink();
                            // }
                            //
                            // return Container(
                            // color: Colors.black45,
                            // child: const Center(
                            // child: CircularProgressIndicator(),
                            //            ),
                            //           );
                            //         },
                            //       ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:hisabio/customs/app_bar.dart';
// import 'package:hisabio/customs/elevated_button.dart';
// import 'package:hisabio/entry_widgets/custom_container_entry.dart';
// import 'package:hisabio/entry_widgets/custom_textfield.dart';
// import 'package:hisabio/model_classes/entries/get_staff_entry.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors_used.dart';
// import '../../customs/dropdown_test.dart';
// import '../../dialog_boxes/entry_dialogboxes/bill_section_upload_documents_dialog.dart';
//
// import '../../entry_widgets/custom_date_textfield.dart';
// import '../../model_classes/entries/entries_customer_model.dart';
// import '../../model_classes/entries/entries_supplier.dart';
// import '../../pop_ups/general_closing_popup.dart';
// import '../../pop_ups/scafold_type.dart';
// import '../../provider/entries_provider/entries_section_provider.dart';
//
// class PurchaseEntryScreen extends StatefulWidget {
//   const PurchaseEntryScreen({super.key});
//
//   @override
//   State<PurchaseEntryScreen> createState() => _PurchaseEntryScreenState();
// }
//
// class _PurchaseEntryScreenState extends State<PurchaseEntryScreen> {
//   final _formKey = GlobalKey<FormState>();
//   bool isExpanded = true;
//   bool isSupplierExpanded = false;
//   EntriesCustomerModel? selectedCustomer;
//   String? selectedCustomerName;
//   GetStaffEntry? selectedStaff;
//   String? selectedStaffName;
//   List<int> suppliers = [0];
//   final transactionController = TextEditingController();
//   List<TextEditingController> remarksControllers = [TextEditingController()];
//
//   List<EntriesModel?> selectedSuppliers = [null];
//   List<List<PlatformFile>> uploadedFiles = [[]];
//
//   void clearFields() {
//     transactionController.clear();
//     setState(() {
//       selectedStaff = null;
//       suppliers = [0];
//       selectedCustomer = null;
//       remarksControllers = [TextEditingController()];
//       selectedSuppliers = [null];
//       uploadedFiles = [];
//       uploadedFiles.add([]);
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     transactionController.text = DateFormat(
//       'yyyy-MM-dd',
//     ).format(DateTime.now());
//
//     Future.microtask(() async {
//       final provider = context.read<EntriesProvider>();
//
//       await provider.fetchCustomer();
//       await provider.fetchSuppliers();
//       await provider.fetchStaff();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<EntriesProvider>();
//     return Scaffold(
//       backgroundColor: AppColors.bodyFillColor,
//       appBar: CustomAppBar(
//         title: "Purchase Entry",
//         textStyle: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w600,
//           fontSize: 25,
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () {
//               ExitConfirmationDialog.show(
//                 context,
//                 onSave: () async {
//                   Navigator.pop(context);
//                 },discardButtonText: "Leave",
//                 saveButtonText: "Stay",
//                 onDiscard: () {
//                   Navigator.pop(context);
//                   Navigator.pop(context,true);
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children:[ Form(
//           key: _formKey,
//           child: Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         isExpanded = !isExpanded;
//                       });
//                     },
//                     child: EntryContainer(
//                       children: [
//                         TextField(
//                           decoration: InputDecoration(
//                             suffixIcon: Icon(
//                               isExpanded
//                                   ? Icons.keyboard_arrow_up
//                                   : Icons.keyboard_arrow_down,
//                               color: Colors.white,
//                             ),
//                             enabled: false,
//                             filled: true,
//                             fillColor: AppColors.primaryPurple,
//                             hintText: "Information",
//                             hintStyle: TextStyle(color: Colors.white),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(5),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                         ),
//                         if (isExpanded) ...[
//                           SizedBox(height: 10),
//                           Text(
//                             "Customer",
//                             style: TextStyle(color: Colors.white, fontSize: 18),
//                           ),
//                           CustomDropdown(
//                            // label: "Customer",
//                             hintText: "Customer *",
//                             isRequired: true,
//                             items: provider.customerEntries
//                                 .map((e) => e.customerName ?? "")
//                                 .toList(),
//                             initialValue: selectedCustomer?.customerName,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return "Customer is required";
//                               }
//                               return null;
//                             },
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedCustomer = provider.customerEntries.firstWhere(
//                                       (e) => e.customerName == value,
//                                 );
//                               });
//                             },
//                           ),
//                           SizedBox(height: 10),
//                           Text(
//                             "Staff",
//                             style: TextStyle(color: Colors.white, fontSize: 18),
//                           ),
//                           CustomDropdown(
//                           //  label: "Staff",
//                             hintText: "Staff",
//                             items: provider.staffList
//                                 .map((e) => e.staffName ?? "")
//                                 .toList(),
//                             initialValue: selectedStaff?.staffName,
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedStaff = provider.staffList.firstWhere(
//                                       (e) => e.staffName == value,
//                                 );
//                               });
//                             },
//                           ),
//                           SizedBox(height: 10),
//                           Text(
//                             "Transaction Date",
//                             style: TextStyle(color: Colors.white, fontSize: 18),
//                           ),
//                           EntryDateTextField(
//                             label: "Transaction Date",
//                             controller: transactionController,
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 15),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         isSupplierExpanded = !isSupplierExpanded;
//                       });
//                     },
//                     child: EntryContainer(
//                       children: [
//                         TextField(
//                           decoration: InputDecoration(
//                             suffixIcon: Icon(
//                               isSupplierExpanded
//                                   ? Icons.keyboard_arrow_up
//                                   : Icons.keyboard_arrow_down,
//                               color: Colors.white,
//                             ),
//                             enabled: false,
//                             filled: true,
//                             fillColor: AppColors.primaryPurple,
//                             hintText: "Suppliers",
//                             hintStyle: TextStyle(color: Colors.white),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(5),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                         ),
//                         if (isSupplierExpanded) ...[
//                           SizedBox(height: 10),
//                           CustomElevatedButton(
//                             color: AppColors.primaryPurple,
//                             text: "+ Add More Supplier",
//                             textStyle: TextStyle(color: Colors.white),
//                             onPressed: () async {
//                               setState(() {
//                                 suppliers.add(suppliers.length);
//                                 remarksControllers.add(TextEditingController());
//                                 selectedSuppliers.add(null);
//                                 uploadedFiles.add([]);
//                               });
//                             },
//                             borderRadius: 5,
//                           ),
//                           ListView.builder(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemCount: suppliers.length,
//                             itemBuilder: (context, index) => Container(
//                               decoration: BoxDecoration(
//                                 color: AppColors.bodyFillColor,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(5.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     SizedBox(height:5),
//                                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           "Supplier ${index+1}",
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 18,
//                                           ),
//                                         ),
//                                         if(suppliers.length>1)
//                                         GestureDetector(onTap:(){ setState(() {
//                                           suppliers.removeAt(index);
//                                         });},
//                                             child: Icon(Iconsax.trash,color:Colors.red))
//                                       ],
//                                     ),
//                                     CustomDropdown(
//                                      // label: "Supplier",
//                                       hintText: "Supplier *",
//                                       isRequired: true,
//                                       items: provider.entries
//                                           .map((e) => e.supplierName ?? "")
//                                           .toList(),
//                                       initialValue: selectedSuppliers[index]?.supplierName,
//                                       validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                           return "Supplier is required";
//                                         }
//                                         return null;
//                                       },
//                                       onChanged: (value) {
//                                         setState(() {
//                                           selectedSuppliers[index] = provider.entries.firstWhere(
//                                                 (e) => e.supplierName == value,
//                                           );
//                                         });
//                                       },
//                                     ),
//                                     SizedBox(height: 10),
//                                     Text(
//                                       "Remarks",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 18,
//                                       ),
//                                     ),
//                                     EntryTextField(
//                                       controller: remarksControllers[index],
//                                       hintText: "Remarks",
//                                     ),
//                                     SizedBox(height: 10),
//                                     Row(
//                                       children: [
//                                         GestureDetector(
//                                           onTap: () async {
//                                             final files =
//                                                 await showDialog<
//                                                   List<PlatformFile>
//                                                 >(
//                                                   context: context,
//                                                   builder: (context) =>
//                                                       BillEntryUploadDocuments(
//                                                         files:
//                                                             uploadedFiles[index],
//                                                       ),
//                                                 );
//
//                                             if (files != null) {
//                                               setState(() {
//                                                 uploadedFiles[index] = files;
//                                               });
//                                             }
//                                           },
//                                           child: Container(
//                                             decoration: BoxDecoration(
//                                               color: AppColors.primaryPurpleLight,
//                                               borderRadius: BorderRadius.circular(
//                                                 10,
//                                               ),
//                                             ),
//                                             child: Padding(
//                                               padding: const EdgeInsets.all(8.0),
//                                               child: Row(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 children: [
//                                                   Icon(
//                                                     Iconsax.document_upload,
//                                                     color:
//                                                         AppColors.primaryPurple,
//                                                   ),
//                                                   Text(
//                                                     "Upload Documents",
//                                                     style: TextStyle(
//                                                       color:
//                                                           AppColors.primaryPurple,
//                                                       fontSize: 15,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(width: 10),
//                                         Text(
//                                           "${uploadedFiles[index].length} Files",
//                                           style: TextStyle(color: Colors.white),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: CustomElevatedButton(
//                           text: "Reset",
//                           textStyle: TextStyle(color: Colors.black, fontSize: 20),
//                           onPressed: () async {
//                             clearFields();
//                           },
//                           borderRadius: 5,
//                         ),
//                       ),
//                       SizedBox(width: 20),
//                       Expanded(
//                         child: CustomElevatedButton(
//                           color: AppColors.primaryPurple,
//                           text: "Save",
//                           textStyle: TextStyle(color: Colors.white, fontSize: 20),
//                           onPressed: () async {
//                             if (!_formKey.currentState!.validate()) {
//                               ScaffoldSnackBar.show(
//                                 context,
//                                 "Please fill all the required fields",
//                               );
//                               return;
//                             }
//
//                             if (selectedCustomer == null ||
//                                 selectedSuppliers.isEmpty) {
//                               ScaffoldSnackBar.show(
//                                 context,
//                                 "Please select  customer and supplier",
//                               );
//                               return;
//                             }
//                             final payload = {
//                               "date": transactionController.text,
//                               "staffId": selectedStaff?.staffId,
//                               "customerId": selectedCustomer?.id,
//                               "suppliers": List.generate(
//                                 selectedSuppliers.length,
//                                 (index) => {
//                                   "supplierId": selectedSuppliers[index]?.id,
//                                   "remarks": remarksControllers[index].text,
//                                 },
//                               ),
//                             };
//                             // final images = uploadedFiles
//                             //     .expand((files) => files)
//                             //     .where((e) => e.path != null)
//                             //     .map((e) => File(e.path!))
//                             //     .toList();
//
//                             try {
//                               final message = await provider.savePurchase(
//                                 payload: payload,
//                                 uploadedFiles:uploadedFiles,
//                                 selectedSuppliers:selectedSuppliers
//                               );
//                               if (!context.mounted) return;
//                               ScaffoldSnackBar.show(
//                                 context,
//                                 message ?? "Purchase Saved Successfully",
//                               );
//                               Navigator.pop(context,true);
//                               // Navigator.push(
//                               //   context,
//                               //   MaterialPageRoute(builder: (context) => Purchase()),
//                               // );
//                             } catch (e) {
//                               ScaffoldSnackBar.show(context, e.toString());
//                             }
//                           },
//                           borderRadius: 5,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ),Consumer<EntriesProvider>(
//           builder: (context, provider, child) {
//             if (!provider.isLoading) {
//               return const SizedBox.shrink();
//             }
//
//             return Container(
//               color: Colors.black45,
//               child: const Center(
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           },
//         )],
//       ),
//     );
//   }
// }
