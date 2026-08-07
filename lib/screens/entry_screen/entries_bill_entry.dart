import 'dart:core';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/customs/app_bar.dart';
import 'package:hisabio/customs/dropdown_test.dart';
import 'package:hisabio/customs/elevated_button.dart';
import 'package:hisabio/entry_widgets/custom_container_entry.dart';
import 'package:hisabio/entry_widgets/custom_date_textfield.dart';
import 'package:hisabio/entry_widgets/custom_textfield.dart';
import 'package:hisabio/model_classes/entries/entries_customer_model.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/custom_icons.dart';
import '../../constants/view_image_method.dart';
import '../../dialog_boxes/entry_dialogboxes/add_new_bill_item.dart';
import '../../dialog_boxes/entry_dialogboxes/bill_section_upload_documents_dialog.dart';
import '../../enums/customer_mode.dart';
import '../../model_classes/Transport/transport.dart';
import '../../model_classes/bills/bill_item_model.dart';
import '../../model_classes/entries/entries_supplier.dart';
import '../../model_classes/bills/bill_details.dart';
import '../../pop_ups/general_closing_popup.dart';
import '../../pop_ups/scafold_type.dart';
import '../../provider/entries_provider/entries_section_provider.dart';
import '../../provider/reporting_provider/bill_provider.dart';

class EntriesBillEntry extends StatefulWidget {
  final FormMode mode;
  final String? id;

  const EntriesBillEntry({super.key, this.mode = FormMode.add, this.id});

  @override
  State<EntriesBillEntry> createState() => _EntriesBillEntryState();
}

class _EntriesBillEntryState extends State<EntriesBillEntry> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  List<bool> billItemExpanded = [];

  bool get isViewMode => widget.mode == FormMode.view;
  bool isExpanded = true;
  List<String> existingFileNames = [];
  bool isBillItemsExpanded = false;
  bool isAttachmentExpanded = false;
  bool isSupplierExpanded = false;
  bool isCustomerExpanded = false;
  bool isLogisticExpanded = false;
  List<PlatformFile> uploadedFiles = [];
  List<BillItem> billItems = [];
  EntriesModel? selectedSupplier;
  String? selectedSupplierName;
  EntriesCustomerModel? selectedCustomer;
  String? selectedCustomerName;
  Transport? selectedTransport;
  String? selectedTransportName;
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
    _scrollController.dispose();
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

    if (widget.mode == FormMode.add) {
      dateController.text =
          DateFormat('yyyy-MM-dd').format(DateTime.now());
    }

    Future.microtask(() async {
      final entriesProvider = context.read<EntriesProvider>();
      final billsProvider = context.read<BillProvider>();

      if (widget.mode == FormMode.view || widget.mode == FormMode.edit) {
        // Fetch bill details immediately
        final success = await billsProvider.fetchBillDetails(widget.id!);

        if (!mounted || !success) return;

        final bill = billsProvider.billDetails;
        if (bill != null) {
          fillBillData(bill);
        }

        // Load dropdown data in the background
        entriesProvider.loadInitialData().then((_) {
          if (!mounted) return;

          final updatedBill = billsProvider.billDetails;
          if (updatedBill != null) {
            fillBillData(updatedBill);
          }
        });
      } else {
        // Add mode only
        await entriesProvider.loadInitialData();
        if (!mounted) return;
        setState(() {});
      }
    });
  }

  Widget _buildBillItemCard(BillItem item, int index) {
    final taxable =
        (item.taxableValue ??
                ((item.grossAmount ?? 0) -
                    (item.discountAmount ?? 0) +
                    (item.addOnAmount ?? 0) +
                    (item.ecrAmount ?? 0)))
            .toDouble();

    final total = (item.totalAmount ?? (taxable + (item.gstAmount ?? 0)))
        .toDouble();
    return Container(
      // margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      // margin: const EdgeInsets.only(
      //   left: 10,
      //   right: 10,
      //   top: 10,
      //   bottom: 4,
      // ),
      decoration: BoxDecoration(
        //  color:  AppColors.primaryPurpleLight, // Very light purple
        // borderRadius: BorderRadius.circular(5),
        //  boxShadow: [
        //    BoxShadow(
        // color: Colors.white,
        // blurRadius: 6,
        // offset: const Offset(0, 2),
        // ),
        // ],
        border: Border.all(color: AppColors.containerFillColor),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),

            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        billItemExpanded[index] = !billItemExpanded[index];
                      });
                    },
                    child: Text(
                      "Bill Item ${index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                if (!isViewMode) ...[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        billItems.removeAt(index);
                        billItemExpanded.removeAt(index);
                      });
                    },
                    child: customIcon(
                      icon: Iconsax.trash,
                      iconColor: Colors.red,
                      bgColor: Colors.transparent,
                    ),
                  ),

                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: () async {
                      final BillItem? updated = await showDialog<BillItem>(
                        context: context,
                        builder: (_) => AddNewBillItem(billItem: item),
                      );

                      if (updated != null) {
                        setState(() {
                          billItems[index] = updated;
                        });
                      }
                    },
                    child: customIcon(
                      icon: Iconsax.edit,
                      iconColor: Colors.green,
                      bgColor: Colors.transparent,
                    ),
                  ),

                  const SizedBox(width: 8),
                ],

                GestureDetector(
                  onTap: () {
                    setState(() {
                      billItemExpanded[index] = !billItemExpanded[index];
                    });
                  },
                  child: Icon(
                    billItemExpanded[index]
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
          // Body
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.bodyFillColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),

              crossFadeState: billItemExpanded[index]
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,

              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: Column(
                  children: [
                    _billField("Pieces", item.pieces),

                    _billField("Gross Amount", item.grossAmount),

                    _billField("Discount %", item.discountPercent),

                    _billField("Discount Amount", item.discountAmount),

                    _billField("Add-On Amount", item.addOnAmount),

                    _billField("ECR Amount", item.ecrAmount),

                    _billField("GST %", item.gstPercent),

                    _billField("GST Amount", item.gstAmount),

                    // const Divider(height: 20),
                    //
                    // _billField("Taxable Value", taxable),
                    //
                    // _billField("Bill Amount", total, isLast: true),
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _billField(String title, dynamic value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              value?.toString() ?? "-",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void fillBillData(BillDetails bill) {
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
    billItemExpanded = List.generate(billItems.length, (_) => true);
    final provider = context.read<EntriesProvider>();
    final supplier = provider.entries.where((e) => e.id == bill.supplierId);

    if (supplier.isNotEmpty) {
      selectedSupplier = supplier.first;
      selectedSupplierName = supplier.first.supplierName;
    }

    // selectedSupplier = provider.entries.firstWhere(
    //   (e) => e.id == bill.supplierId,
    // );
    selectedSupplierName = selectedSupplier?.supplierName;
    final customer = provider.customerEntries.where(
      (e) => e.id == bill.customerId,
    );

    if (customer.isNotEmpty) {
      selectedCustomer = customer.first;
      selectedCustomerName = customer.first.customerName;
    }
    // selectedCustomer = provider.customerEntries.firstWhere(
    //   (e) => e.id == bill.customerId,
    // );
    selectedCustomerName = selectedCustomer?.customerName;
    if (bill.transport != null) {
      final transport = provider.transportDetails.where(
        (e) => e.name == bill.transport,
      );

      if (transport.isNotEmpty) {
        selectedTransport = transport.first;
        selectedTransportName = selectedTransport?.name;
      }
    }
    existingObjectKeys = List<String>.from(bill.objectKeys ?? []);

    existingUrls = List<String>.from(bill.publicUrls ?? []);
    existingFileNames = List<String>.from(bill.originalFileNames ?? []);
    if (!mounted) return;
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
      selectedSupplierName = null;
      selectedCustomer = null;
      selectedCustomerName = null;
      selectedTransport = null;
      selectedTransportName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EntriesProvider>();
    final bill = context.watch<BillProvider>().billDetails;
    final totalTaxableValue = billItems.fold<double>(
      0,
      (sum, item) =>
          sum +
          ((item.taxableValue ??
                  ((item.grossAmount ?? 0) -
                      (item.discountAmount ?? 0) +
                      (item.addOnAmount ?? 0) +
                      (item.ecrAmount ?? 0)))
              .toDouble()),
    );

    final totalBillAmount = billItems.fold<double>(0, (sum, item) {
      final taxable =
          (item.taxableValue ??
                  ((item.grossAmount ?? 0) -
                      (item.discountAmount ?? 0) +
                      (item.addOnAmount ?? 0) +
                      (item.ecrAmount ?? 0)))
              .toDouble();

      final total = (item.totalAmount ?? (taxable + (item.gstAmount ?? 0)))
          .toDouble();

      return sum + total;
    });
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
                  saveButtonText: "Stay",
                  discardButtonText: "Leave",
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
                //  controller: _scrollController,
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

                            CustomDropdown(
                              isDisabled: isViewMode,
                              hintText: "Supplier",
                              items: provider.entries
                                  .map((e) => e.supplierName ?? '')
                                  .toList(),
                              initialValue: selectedSupplierName,
                              validator: (value) {
                                if (value == null) {
                                  return "Supplier is required";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  selectedSupplierName = value;
                                  selectedSupplier = provider.entries
                                      .firstWhere(
                                        (e) => e.supplierName == value,
                                      );
                                });

                                supplierGroupController.text =
                                    selectedSupplier?.supplierGroup ?? '';

                                supplierGstController.text =
                                    selectedSupplier?.supplierGstNo ?? '';
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
                            CustomDropdown(
                              isDisabled: isViewMode,
                              hintText: "Customer",
                              items: provider.customerEntries
                                  .map((e) => e.customerName ?? '')
                                  .toList(),
                              initialValue: selectedCustomerName,
                              validator: (value) {
                                if (value == null) {
                                  return "Customer is required";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  selectedCustomerName = value;

                                  selectedCustomer = provider.customerEntries
                                      .firstWhere(
                                        (e) => e.customerName == value,
                                      );
                                });

                                customerGroupController.text =
                                    selectedCustomer?.customerGroup ?? '';

                                customerGstController.text =
                                    selectedCustomer?.customerGstNo ?? '';
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
                            CustomDropdown(
                              isDisabled: isViewMode,
                              hintText: "Transport",
                              items: provider.transportDetails
                                  .map((e) => e.name ?? '')
                                  .toList(),
                              initialValue: selectedTransportName,
                              onChanged: (value) {
                                setState(() {
                                  selectedTransportName = value;

                                  selectedTransport = provider.transportDetails
                                      .firstWhere((e) => e.name == value);
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
                      const SizedBox(height: 15),

                      GestureDetector(
                        onTap: () async {
                          final remainingSlots =
                              3 - existingUrls.length - newUploadedFiles.length;

                          if (remainingSlots <= 0) {
                            ScaffoldSnackBar.show(
                              context,
                              "Maximum 3 files can be uploaded",
                            );
                            return;
                          }

                          final files = await showDialog<List<PlatformFile>>(
                            context: context,
                            builder: (_) => BillEntryUploadDocuments(
                              existingImageKeys: existingObjectKeys,
                              existingFileNames: existingFileNames,
                              existingUrls: existingUrls,
                              files: newUploadedFiles,
                            ),
                          );

                          if (files != null) {
                            setState(() {
                              newUploadedFiles = files;
                            });
                          }
                        },

                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE4D9FF),
                            ),
                          ),

                          child: Row(
                            children: [

                              Container(
                                height: 46,
                                width: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F0FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: AppColors.primaryPurple,
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    const Text(
                                      "Upload Documents",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryPurple,
                                      ),
                                    ),

                                    const SizedBox(height: 3),

                                    Text(
                                      "JPG, PNG, PDF • Max 3 files",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F0FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${allAttachments.length}/3",
                                  style: const TextStyle(
                                    color: AppColors.primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                              billItemExpanded.add(true);
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
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isBillItemsExpanded = !isBillItemsExpanded;
                              });
                            },
                            child: TextField(
                              enabled: false,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.primaryPurple,
                                hintText: "Bill Items",
                                hintStyle: const TextStyle(color: Colors.white),
                                suffixIcon: Icon(
                                  isBillItemsExpanded
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
                          ),

                          if (isBillItemsExpanded) ...[
                            const SizedBox(height: 12),

                            Column(
                              children: List.generate(
                                billItems.length,
                                (index) =>
                                    _buildBillItemCard(billItems[index], index),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.bodyFillColor,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: AppColors.containerFillColor
                                )
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 12,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryPurple,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5),
                                      ),
                                    ),
                                    child: const Text(
                                      "Summary",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      children: [
                                        _billField(
                                          "Taxable Value",
                                          totalTaxableValue.toStringAsFixed(2),
                                        ),

                                        _billField(
                                          "Bill Amount",
                                          totalBillAmount.toStringAsFixed(2),
                                          isLast: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    SizedBox(height: 20),
                    if (widget.mode != FormMode.add)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isAttachmentExpanded = !isAttachmentExpanded;
                          });
                          if (isAttachmentExpanded) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            });
                          }
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
                                return SizedBox(height: 5);
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
                                        child: IconButton(
                                          onPressed: () async {
                                            await viewAttachment(
                                              imageUrl!,
                                              fileName,
                                            );
                                          },
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
                                                existingFileNames.removeAt(
                                                  index,
                                                );
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
                                  "transport": selectedTransport?.name,
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
                                          "discountPercent":
                                              item.discountPercent,
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
                                    "Bill Saved Successfully",
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
                            //  "transportId": selectedTransport?.id,
                            "transport": selectedTransport?.name,
                            "lrNumber": lrNumberController.text.isEmpty
                                ? null
                                : lrNumberController.text,
                            "remarks": remarksController.text.isEmpty
                                ? null
                                : remarksController.text,

                            "taxableValue": billItems.fold<double>(0, (
                              sum,
                              item,
                            ) {
                              final taxable =
                                  (item.grossAmount ?? 0) -
                                  (item.discountAmount ?? 0) +
                                  (item.addOnAmount ?? 0) +
                                  (item.ecrAmount ?? 0);

                              return sum + taxable;
                            }),

                            "billAmount": billItems.fold<double>(0, (
                              sum,
                              item,
                            ) {
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
                              id: bill?.id?.toInt() ?? 0,
                              payload: payload,
                              images: images,
                            );
                            if (!context.mounted) return;
                            ScaffoldSnackBar.show(
                              context,
                              "Bill updated successfully",
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
              )
            ),
          ),
          // if (context.select<EntriesProvider, bool>((p) => p.isLoading))
          //   Container(
          //     color: Colors.black45,
          //     child: const Center(child: CircularProgressIndicator()),
          //   ),
          //},
          //),
        ],
      ),
    );
  }
}
