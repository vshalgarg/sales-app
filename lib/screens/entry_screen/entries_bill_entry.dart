import 'dart:core';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/elevated_button.dart';
import 'package:hisabio/entry_widgets/custom_container_entry.dart';
import 'package:hisabio/entry_widgets/custom_date_textfield.dart';
import 'package:hisabio/entry_widgets/custom_textfield.dart';
import 'package:hisabio/model_classes/entries_customer_model.dart';
import 'package:hisabio/model_classes/get_transportname_id_model.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/custom_icons.dart';
import '../../constants/view_image_method.dart';
import '../../dialog_boxes/entry_dialogboxes/add_new_bill_item.dart';
import '../../dialog_boxes/entry_dialogboxes/bill_section_upload_documents_dialog.dart';
import '../../entry_widgets/custom_api_textfield.dart';
import '../../enums/customer_mode.dart';
import '../../model_classes/bill_item_model.dart';
import '../../model_classes/entries_supplier.dart';
import '../../model_classes/reporting_get_bill.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/search_bill_provider.dart';
import '../reporting_screen/bills.dart';

class EntriesBillEntry extends StatefulWidget {
  final FormMode mode;
  final String? id;

  const EntriesBillEntry({super.key, this.mode = FormMode.add, this.id});

  @override
  State<EntriesBillEntry> createState() => _EntriesBillEntryState();
}

class _EntriesBillEntryState extends State<EntriesBillEntry> {
  final _formKey = GlobalKey<FormState>();

  bool get isViewMode => widget.mode == FormMode.view;
  bool isExpanded = true;
  List<String> existingFileNames = [];
  bool isAttachmentExpanded = false;
  bool isSupplierExpanded = false;
  bool isCustomerExpanded = false;
  bool isLogisticExpanded = false;
  List<PlatformFile> uploadedFiles = [];
  List<BillItem> billItems = [];
  EntriesModel? selectedSupplier;
  EntriesCustomerModel? selectedCustomer;
  GetTransportnameIdModel? selectedTransport;
  List<String> existingUrls = [];
  List<String> existingObjectKeys = [];
  List<String> removedObjectKeys = [];

  List<PlatformFile> newUploadedFiles = [];

  // List<File> uploadedFiles = [];
  final dateController = TextEditingController();
  final receivedDateController = TextEditingController();
  final invoiceController = TextEditingController();
  final supplierGroupController = TextEditingController();
  final supplierGstController = TextEditingController();
  final customerGroupController = TextEditingController();
  final customerGstController = TextEditingController();
  final lrNumberController = TextEditingController();
  final remarksController = TextEditingController();
  final supplierController = TextEditingController();

  List<dynamic> get allAttachments {
    return [...existingUrls, ...newUploadedFiles];
  }

  @override
  void dispose() {
    dateController.dispose();
    receivedDateController.dispose();
    invoiceController.dispose();
    supplierGroupController.dispose();
    supplierGstController.dispose();
    customerGroupController.dispose();
    customerGstController.dispose();
    lrNumberController.dispose();
    remarksController.dispose();
    supplierController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy/MM/dd').format(DateTime.now());
    Future.microtask(() async {
      final provider = context.read<EntriesProvider>();
      await Future.wait([
        provider.fetchSuppliers(),
        provider.fetchCustomer(),
        provider.fetchTransport(),
      ]);
      if (widget.mode == FormMode.view || widget.mode == FormMode.edit) {
        await context.read<BillsProvider>().fetchBillById(widget.id!);
        final bill = context.read<BillsProvider>().bill;
        if (bill != null) {
          fillBillData(bill);
        }
      }
    });
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
  void fillBillData(BillResponse bill) {
    dateController.text = bill.date ?? "";
    receivedDateController.text = bill.receivedDate ?? "";
    invoiceController.text = bill.invoiceNo ?? "";

    supplierGroupController.text = bill.supplierGroup ?? "";
    supplierGstController.text = bill.supplierGstNo ?? "";

    customerGroupController.text = bill.customerGroup ?? "";
    customerGstController.text = bill.customerGstNo ?? "";

    lrNumberController.text = bill.lrNumber ?? "";
    remarksController.text = bill.remarks ?? "";

    billItems = bill.items!.cast<BillItem>();

    final provider = context.read<EntriesProvider>();

    selectedSupplier = provider.entries.firstWhere(
      (e) => e.id == bill.supplierId,
    );

    selectedCustomer = provider.customerEntries.firstWhere(
      (e) => e.id == bill.customerId,
    );

    selectedTransport = provider.transportDetails.where(
          (e) => e.name == bill.transport,
    ).isNotEmpty
        ? provider.transportDetails.firstWhere(
          (e) => e.name == bill.transport,
    )
        : null;
    existingObjectKeys = List<String>.from(bill.objectKeys ?? []);

    existingUrls = List<String>.from(bill.publicUrls ?? []);
    existingFileNames = List<String>.from(bill.originalFileNames ?? []);
    setState(() {});
  }

  void clearFields() {
    invoiceController.clear();
    receivedDateController.clear();
    remarksController.clear();
    supplierGroupController.clear();
    supplierGstController.clear();
    customerGroupController.clear();
    customerGstController.clear();
    lrNumberController.clear();
    supplierController.clear();
    dateController.clear();
    setState(() {
      uploadedFiles = [];
      billItems = [];
      selectedSupplier = null;
      selectedCustomer = null;
      selectedTransport = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntriesProvider>();
    final bill = context.watch<BillsProvider>().bill;
    // final customerProvider=context.watch<EntriesProvider>();
    return Scaffold(
      backgroundColor: AppColors.bodyFillColor,
      appBar: CustomAppBar(
        title: widget.mode == FormMode.edit
            ? "Edit Bill Entry"
            : widget.mode == FormMode.view
            ? "Bill Details"
            : "Bill Entry",
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        ),
        leading:widget.mode == FormMode.view? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context
            );
          },
        ):null,
        actions: [
          if(widget.mode!=FormMode.view)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ExitConfirmationDialog.show(
                context,
                onSave: () async {
                  Navigator.pop(context);
                },
                saveButtonText: "Stay",
                discardButtonText: "Leave",
                onDiscard: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Bills()),
                  );
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    EntryContainer(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: TextField(
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                              enabled: false,
                              filled: true,
                              fillColor: AppColors.primaryPurple,
                              hintText: "Order Information",
                              hintStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        if (isExpanded) ...[
                          SizedBox(height: 10),
                          Text(
                            "Date",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          EntryDateTextField(
                            enabled: !isViewMode,
                            label: "Date",
                            controller: dateController,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Received Date",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          EntryDateTextField(
                            enabled: !isViewMode,
                            label: "Received Date",
                            controller: receivedDateController,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Invoice",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          EntryTextField(
                            enabled: !isViewMode,
                            controller: invoiceController,
                            hintText: "Invoice",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Invoice is required";
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 10),
                        ],
                      ],
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {},
                      child: EntryContainer(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isSupplierExpanded = !isSupplierExpanded;
                              });
                            },
                            child: TextField(
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  isSupplierExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                                enabled: false,
                                filled: true,
                                fillColor: AppColors.primaryPurple,
                                hintText: "Supplier Information",
                                hintStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          if (isSupplierExpanded) ...[
                            SizedBox(height: 10),
                            Text(
                              "Supplier",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            CustomApiTextField<EntriesModel>(
                              enabled: !isViewMode,
                              hintText: "Supplier",
                              value: selectedSupplier,
                              items: provider.entries,
                              itemLabel: (e) => e.supplierName ?? '',
                              validator: (value) {
                                if (value == null) {
                                  return "Supplier is required";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  selectedSupplier = value;
                                });

                                supplierGroupController.text =
                                    value?.supplierGroup ?? '';

                                supplierGstController.text =
                                    value?.supplierGstNo ?? '';
                              },
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Supplier Group",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryTextField(
                              enabled: false,
                              hintText: "Supplier Group",
                              controller: supplierGroupController,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "GSTIN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryTextField(
                              enabled: false,
                              hintText: "GSTIN",
                              controller: supplierGstController,
                            ),
                            SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 15),

                    GestureDetector(
                      onTap: () {},
                      child: EntryContainer(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isCustomerExpanded = !isCustomerExpanded;
                              });
                            },
                            child: TextField(
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  isCustomerExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                                enabled: false,
                                filled: true,
                                fillColor: AppColors.primaryPurple,
                                hintText: "Customer Information",
                                hintStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          if (isCustomerExpanded) ...[
                            SizedBox(height: 10),
                            Text(
                              "Customer",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            CustomApiTextField<EntriesCustomerModel>(
                              enabled: !isViewMode,
                              hintText: "Customer",
                              value: selectedCustomer,
                              items: provider.customerEntries,
                              itemLabel: (e) => e.customerName ?? '',
                              validator: (value) {
                                if (value == null) {
                                  return "Customer is required";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  selectedCustomer = value;
                                });

                                customerGroupController.text =
                                    value?.customerGroup ?? '';

                                customerGstController.text =
                                    value?.customerGstNo ?? '';
                              },
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Customer Group",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryTextField(
                              enabled: false,
                              hintText: "Customer Group",
                              controller: customerGroupController,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "GSTIN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryTextField(
                              enabled: false,
                              hintText: "GSTIN",
                              controller: customerGstController,
                            ),
                            SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {},
                      child: EntryContainer(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isLogisticExpanded = !isLogisticExpanded;
                              });
                            },
                            child: TextField(
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  isLogisticExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                                enabled: false,
                                filled: true,
                                fillColor: AppColors.primaryPurple,
                                hintText: "Logistic & Notes",
                                hintStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          if (isLogisticExpanded) ...[
                            SizedBox(height: 10),
                            Text(
                              "Transport",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            CustomApiTextField<GetTransportnameIdModel>(
                              enabled: !isViewMode,
                              hintText: "Transport",
                              value: selectedTransport,
                              items: provider.transportDetails,
                              itemLabel: (e) => e.name ?? '',
                              onChanged: (value) {
                                setState(() {
                                  selectedTransport = value;
                                });
                              },
                            ),
                            SizedBox(height: 10),
                            Text(
                              "LR Number",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryTextField(
                              enabled: !isViewMode,
                              hintText: "LR Number",
                              controller: lrNumberController,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Remarks",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            EntryTextField(
                              enabled: !isViewMode,
                              hintText: "Remarks",
                              controller: remarksController,
                            ),
                            SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                    if (!isViewMode) ...[
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final remainingSlots =
                                  3 -
                                  existingUrls.length -
                                  newUploadedFiles.length;

                              if (remainingSlots <= 0) {
                                ScaffoldSnackBar.show(
                                  context,
                                  "Maximum 3 files can be uploaded",
                                );
                                return;
                              }

                              final files =
                                  await showDialog<List<PlatformFile>>(
                                    context: context,
                                    builder: (context) =>
                                        BillEntryUploadDocuments(
                                          files: newUploadedFiles,
                                        ),
                                  );

                              if (files != null) {
                                if (files.length > remainingSlots) {
                                  ScaffoldSnackBar.show(
                                    context,
                                    "You can upload only $remainingSlots more file(s)",
                                  );

                                  return;
                                }

                                setState(() {
                                  newUploadedFiles = files;
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurpleLight,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Iconsax.document_upload,
                                      color: AppColors.primaryPurple,
                                    ),
                                    Text(
                                      "Upload Documents",
                                      style: TextStyle(
                                        color: AppColors.primaryPurple,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "${allAttachments.length} files",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                    if (!isViewMode) ...[
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () async {
                          final BillItem? item = await Navigator.push<BillItem>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddNewBillItem(),
                            ),
                          );

                          if (item != null) {
                            setState(() {
                              billItems.add(item);
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: AppColors.primaryPurple,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "+Add Bill Item",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 20),
                    if (billItems.isNotEmpty)
                      EntryContainer(
                        children: [
                          Text(
                            "Bill Details",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${billItems.length} Items",
                            style: TextStyle(color: Colors.white),
                          ),
                          ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: billItems.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = billItems[index];
                              final taxable =
                                  (item.grossAmount ?? 0) -
                                  (item.discountAmount ?? 0) +
                                  (item.addOnAmount ?? 0) +
                                  (item.ecrAmount ?? 0);

                              final total = taxable + (item.gstAmount ?? 0);
                              return Padding(
                                padding: const EdgeInsets.only(
                                 // left: 3.0,
                                  //right: 3,
                                ),
                                child: Card(
                                  elevation: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Pieces = ${item.pieces}"),
                                              Text(
                                                "Gross Amount = ${item.grossAmount}",
                                              ),
                                              Text("GST% = ${item.gstPercent}"),
                                              Text(
                                                "GST Amount = ${item.gstAmount}",
                                              ),
                                              Text(
                                                "Disc % = ${item.discountPercent}",
                                              ),
                                              Text(
                                                "Disc Amount = ${item.discountAmount}",
                                              ),
                                              Text(
                                                "Add-On = ${item.addOnAmount}",
                                              ),
                                              Text("ECR = ${item.ecrAmount}"),

                                              Text(
                                                "Taxable Value = ${item.taxableValue ?? taxable}",
                                              ),
                                              Text(
                                                "Bill Amount = ${item.totalAmount ?? total}",
                                              ),
                                            ],
                                          ),
                                          if (!isViewMode) ...[
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      billItems.removeAt(index);
                                                    });
                                                  },

                                                  child: customIcon(
                                                    iconColor: AppColors.binRed,
                                                    bgColor:
                                                        AppColors.binRedLight,
                                                    icon: Iconsax.trash,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                GestureDetector(
                                                  onTap: () async {
                                                    final BillItem?
                                                    updatedItem =
                                                        await showDialog<
                                                          BillItem
                                                        >(
                                                          context: context,
                                                          builder: (context) =>
                                                              AddNewBillItem(
                                                                billItem: item,
                                                              ),
                                                        );

                                                    if (updatedItem != null) {
                                                      setState(() {
                                                        billItems[index] =
                                                            updatedItem;
                                                      });
                                                    }
                                                  },
                                                  child: customIcon(
                                                    iconColor:
                                                        AppColors.editGreen,
                                                    bgColor: AppColors
                                                        .editGreenLight,
                                                    icon: Iconsax.edit,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20),

                        ],
                      ),
                    if(widget.mode!=FormMode.add)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isAttachmentExpanded = !isAttachmentExpanded;
                        });
                      },
                      child: TextField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            isAttachmentExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          enabled: false,
                          filled: true,
                          fillColor: AppColors.primaryPurple,
                          hintText: "Attachments",
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    if (isAttachmentExpanded) ...[
                      SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: AppColors.bodyFillColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Builder(
                          builder: (context) {
                            final attachments = allAttachments;

                            if (attachments.isEmpty) {
                              return Container(
                                alignment: Alignment.center,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 40,
                                      color: AppColors.primaryPurple,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "No Attachments Found",
                                      style: TextStyle(
                                        color: AppColors.primaryPurple,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            final totalCount = allAttachments.length;

                            return ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: totalCount,
                              separatorBuilder: (context, index) {
                                return SizedBox(height:5);
                                //  const Divider(
                                //   color: Colors.grey,
                                //   thickness: 0.5,
                                //   height: 1,
                                // );
                              },
                              itemBuilder: (context, index) {
                                String fileName;
                                String? imageUrl;

                                bool isOldFile = index < existingUrls.length;

                                if (isOldFile) {
                                  imageUrl = existingUrls[index];

                                  fileName = existingFileNames.length > index
                                      ? existingFileNames[index]
                                      : "Attachment ${index + 1}";
                                } else {
                                  final file =
                                      newUploadedFiles[index -
                                          existingUrls.length];
                                  fileName = file.name;
                                }
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          fileName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          child: IconButton(onPressed: ()async {await viewAttachment(imageUrl!, fileName);},
                                           icon: Icon(Icons.remove_red_eye),
                                            color: Colors.blue,
                                            //size: 22,
                                          ),
                                    ),
                                      InkWell(
                                        onTap: () async {
                                          await launchUrl(
                                            Uri.parse(imageUrl!),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          child: Icon(
                                            Icons.download,
                                            color: Colors.green,
                                           // size: 22,
                                          ),
                                        ),
                                      ),
                                      if (!isViewMode)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (isOldFile) {
                                                removedObjectKeys.add(
                                                  existingObjectKeys[index],
                                                );
                                                existingObjectKeys.removeAt(
                                                  index,
                                                );
                                                existingUrls.removeAt(index);
                                              } else {
                                                final newIndex =
                                                    index - existingUrls.length;
                                                newUploadedFiles.removeAt(
                                                  newIndex,
                                                );
                                              }
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                    if (widget.mode == FormMode.add) ...[
                      //SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: CustomElevatedButton(
                              text: "Reset",
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                              onPressed: () async {
                                clearFields();
                              },
                              borderRadius: 5,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: CustomElevatedButton(
                              borderRadius: 5,
                              color: AppColors.primaryPurple,
                              text: "Save",
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) {
                                  ScaffoldSnackBar.show(
                                    context,
                                    "Please fill all the required fields",
                                  );
                                  return;
                                }
                                if (billItems.isEmpty) {
                                  ScaffoldSnackBar.show(
                                    context,
                                    "Please add at least one bill item",
                                  );
                                  return;
                                }
                                if (invoiceController.text.isEmpty ||
                                    selectedSupplier == null ||
                                    selectedCustomer == null) {
                                  ScaffoldSnackBar.show(
                                    context,
                                    "Please fill all the required fields",
                                  );
                                  return;
                                }
                                final payload = {
                                  "date": dateController.text,
                                  "receivedDate":
                                      receivedDateController.text.isEmpty
                                      ? null
                                      : receivedDateController.text,
                                  "order": invoiceController.text,
                                  "supplierId": selectedSupplier?.id,
                                  "customerId": selectedCustomer?.id,
                                  "transportId": selectedTransport?.id,
                                  "transportName": selectedTransport?.name,
                                  // "transportCity": null,
                                  "lrNumber": lrNumberController.text,
                                  "remarks": remarksController.text,
                                  "taxableValue": billItems.fold(
                                    0.0,
                                    (sum, item) =>
                                        sum + item.taxableValue!.toDouble(),
                                  ),
                                  "billAmount": billItems.fold(
                                    0.0,
                                    (sum, item) =>
                                        sum + item.totalAmount!.toDouble(),
                                  ),
                                  "billItems": billItems
                                      .map(
                                        (item) => {
                                          "pieces": item.pieces,
                                          "grossAmount": item.grossAmount,
                                          "discountPercent": item.discountPercent,
                                          "discountAmount": item.discountAmount,
                                          "addOnAmount": item.addOnAmount,
                                          "ecrAmount": item.ecrAmount,
                                          "gstPercent": item.gstPercent,
                                          "gstAmount": item.gstAmount,
                                        },
                                      )
                                      .toList(),
                                };
                                final images = newUploadedFiles
                                    .where((e) => e.path != null)
                                    .map((e) => File(e.path!))
                                    .toList();
                                try {
                                  final message = await provider.saveBill(
                                    payload: payload,
                                    images: images,
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldSnackBar.show(
                                    context,
                                    message ?? "Bill Saved Successfully",
                                  );
                                  Navigator.pop(context, true);
                                } catch (e) {
                                  ScaffoldSnackBar.show(context, e.toString());
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.mode == FormMode.edit) ...[
                      const SizedBox(height: 10),
                      CustomElevatedButton(
                        text: "Update",
                        color: AppColors.primaryPurple,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        borderRadius: 5,
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            ScaffoldSnackBar.show(
                              context,
                              "Please fill all the required fields",
                            );
                            return;
                          }

                          if (billItems.isEmpty) {
                            ScaffoldSnackBar.show(
                              context,
                              "Please add at least one bill item",
                            );
                            return;
                          }

                          final payload = {
                            "date": dateController.text,
                            "receivedDate": receivedDateController.text.isEmpty
                                ? null
                                : receivedDateController.text,
                            "order": invoiceController.text,
                            "supplierId": selectedSupplier?.id,
                            "customerId": selectedCustomer?.id,
                            "transportId": selectedTransport?.id,
                            "transportName": selectedTransport?.name,
                            "lrNumber": lrNumberController.text.isEmpty
                                ? null
                                : lrNumberController.text,
                            "remarks": remarksController.text.isEmpty
                                ? null
                                : remarksController.text,

                            "taxableValue": billItems.fold<double>(0, (sum, item) {
                              final taxable =
                                  (item.grossAmount ?? 0) -
                                      (item.discountAmount ?? 0) +
                                      (item.addOnAmount ?? 0) +
                                      (item.ecrAmount ?? 0);

                              return sum + taxable;
                            }),

                            "billAmount": billItems.fold<double>(0, (sum, item) {
                              final taxable =
                                  (item.grossAmount ?? 0) -
                                      (item.discountAmount ?? 0) +
                                      (item.addOnAmount ?? 0) +
                                      (item.ecrAmount ?? 0);

                              final total = taxable + (item.gstAmount ?? 0);

                              return sum + total;
                            }),

                            "existingImageKeys": existingObjectKeys,

                            "billItems": billItems.map((item) {
                              return {
                                "pieces": item.pieces,
                                "grossAmount": item.grossAmount,
                                "discountPercent": item.discountPercent,
                                "discountAmount": item.discountAmount,
                                "addOnAmount": item.addOnAmount,
                                "ecrAmount": item.ecrAmount,
                                "gstPercent": item.gstPercent,
                                "gstAmount": item.gstAmount,
                              };
                            }).toList(),
                          };
                          final images = newUploadedFiles
                              .where((e) => e.path != null)
                              .map((e) => File(e.path!))
                              .toList();

                          try {
                            final message = await provider.updateBillEntry(
                              id: bill!.id ?? 0,
                              payload: payload,
                              images: images,
                            );
                            if (!context.mounted) return;
                            ScaffoldSnackBar.show(
                              context,
                              message ?? "Bill updated successfully",
                            );
                            Navigator.pop(context, true);
                          } catch (e) {
                            if (!context.mounted) return;

                            ScaffoldSnackBar.show(context, e.toString());
                          }
                        },
                      ),
                    ],

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          Consumer<EntriesProvider>(
            builder: (context, provider, child) {
              if (!provider.isLoading) {
                return const SizedBox.shrink();
              }

              return Container(
                color: Colors.black45,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ],
      ),
    );
  }
}
