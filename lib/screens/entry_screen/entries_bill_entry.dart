import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:public_file_saver/public_file_saver.dart';
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
  static const MethodChannel _channel = MethodChannel('file_opener');
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  List<bool> billItemExpanded = [];
  List<GlobalKey> billItemKeys = [];
  bool showBillItemError = false;

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
  String? _toApiDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    try {
      return DateFormat('yyyy-MM-dd')
          .format(DateFormat('dd-MM-yyyy').parse(value.trim()));
    } catch (_) {
      return value;
    }
  }
  Widget _requiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
        children: !isViewMode
            ? const [
          TextSpan(
            text: ' * ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]
            : [],
      ),
    );
  }
  String _formatAmount(dynamic value) {
    if (value == null) return "-";

    final number = double.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    return NumberFormat('#,##0.00').format(number);
  }

  Future<void> _downloadAttachment(String url, String fileName) async {
    try {
      if (url.isEmpty) {
        if (!mounted) return;

        ScaffoldSnackBar.show(context, 'Download URL not available');
        return;
      }

      final response = await Dio().get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      final bytes = response.data;

      if (bytes == null || bytes.isEmpty) {
        throw Exception('Downloaded file is empty');
      }

      String safeFileName = fileName.trim();

      if (safeFileName.isEmpty) {
        safeFileName =
            'attachment_${DateTime.now().millisecondsSinceEpoch}.jpg';
      }

      final extension = safeFileName.contains('.')
          ? safeFileName.split('.').last.toLowerCase()
          : 'jpg';

      final mimeType = extension == 'pdf'
          ? 'application/pdf'
          : extension == 'png'
          ? 'image/png'
          : extension == 'webp'
          ? 'image/webp'
          : 'image/jpeg';

      final fileSaver = PublicFileSaver();

      final result = await fileSaver.saveBytes(
        bytes: Uint8List.fromList(bytes),
        fileName: safeFileName,
        mimeType: mimeType,
      );

      if (result == null || !result.isSuccess) {
        throw Exception('Unable to save file');
      }

      debugPrint('Downloaded file: ${result.fileName}');
      debugPrint('Downloaded URI: ${result.uri}');
      debugPrint('Downloaded path: ${result.path}');
      if (!mounted) return;
      ScaffoldSnackBar.show(context, 'File downloaded successfully');
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      final uri = result.uri;

      if (uri == null || uri.isEmpty) {
        ScaffoldSnackBar.show(
          context,
          'File downloaded, but could not open it',
        );
        return;
      }

      await _channel.invokeMethod(
        'openFile',
        {
          'uri': result.uri,
          'mimeType': mimeType,
        },
      );
    } catch (e) {
      debugPrint('Download error: $e');

      if (!mounted) return;

      ScaffoldSnackBar.show(context, 'Download failed: $e');
    }
  }

  void _toggleBillItem(int index) {
    if (index < 0 || index >= billItemExpanded.length) return;

    final opening = !billItemExpanded[index];

    setState(() {
      billItemExpanded[index] = opening;
    });

    if (opening && index < billItemKeys.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final targetContext = billItemKeys[index].currentContext;
        if (targetContext == null) return;

        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 350),
        );
      });
    }
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
      dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    }

    final entriesProvider = context.read<EntriesProvider>();
    final billsProvider = context.read<BillProvider>();

    Future.microtask(() async {
      if (widget.mode == FormMode.view || widget.mode == FormMode.edit) {
        final success = await billsProvider.fetchBillDetails(widget.id!);

        if (!mounted || !success) return;

        final bill = billsProvider.billDetails;
        if (bill != null) {
          fillBillData(bill);
        }

        entriesProvider.loadInitialData().then((_) {
          if (!mounted) return;

          final updatedBill = billsProvider.billDetails;
          if (updatedBill != null) {
            fillBillData(updatedBill);
          }
        });
      } else {

        await entriesProvider.loadInitialData();
        if (!mounted) return;
        setState(() {});
      }
    });
  }

  Widget _buildBillItemCard(BillItem item, int index) {
    return Container(
      key: billItemKeys[index],
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
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
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _toggleBillItem(index),
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        "Bill Item ${index + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                //  Edit
                if (!isViewMode) ...[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final updated = await Navigator.push<BillItem>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddNewBillItem(billItem: item),
                        ),
                      );
                      if (updated != null && mounted) {
                        setState(() => billItems[index] = updated);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Iconsax.edit_2,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        billItems.removeAt(index);
                        billItemExpanded.removeAt(index);
                        billItemKeys.removeAt(index);
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Iconsax.trash, color: Colors.red, size: 25),
                    ),
                  ),
                  const SizedBox(width: 18),
                ],
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _toggleBillItem(index),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      billItemExpanded[index]
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: billItemExpanded[index]
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _billItemField(
                          icon: Iconsax.box_1,
                          title: "Pieces",
                          subtitle: "Enter number of pieces",
                          value: item.pieces?.toString() ?? "-",
                        ),
                        _billItemField(
                          icon: Iconsax.money_2,
                          title: "Gross Amount",
                          subtitle: "Enter gross amount",
                          value: _formatAmount(item.grossAmount),
                        ),
                        _billItemField(
                          icon: Iconsax.percentage_circle,
                          title: "Discount %",
                          subtitle: "Enter discount percentage",
                          value: _formatAmount(item.discountPercent),
                        ),
                        _billItemField(
                          icon: Iconsax.discount_shape,
                          title: "Discount Amount",
                          subtitle: "Auto calculated",
                          value: _formatAmount(item.discountAmount),
                        ),
                        _billItemField(
                          icon: Iconsax.add_square,
                          title: "Add-On Amount",
                          subtitle: "Enter add-on amount",
                          value: _formatAmount(item.addOnAmount),
                        ),
                        _billItemField(
                          icon: Iconsax.card,
                          title: "ECR Amount",
                          subtitle: "Enter ECR amount",
                          value: _formatAmount(item.ecrAmount),
                        ),
                        _billItemField(
                          icon: Iconsax.percentage_circle,
                          title: "GST %",
                          subtitle: "Enter GST percentage",
                          value: _formatAmount(item.gstPercent),
                        ),
                        _billItemField(
                          icon: Iconsax.calculator,
                          title: "GST Amount",
                          subtitle: "Auto calculated",
                          value: _formatAmount(item.gstAmount),
                          isLast: true,
                        ),
                        _billItemField(
                          icon: Iconsax.receipt_item,
                          title: "Taxable Value",
                          subtitle: "Auto calculated",
                          value: _formatAmount(
                            item.taxableValue ??
                                ((item.grossAmount ?? 0) -
                                    (item.discountAmount ?? 0) +
                                    (item.addOnAmount ?? 0) +
                                    (item.ecrAmount ?? 0)),
                          ),
                        ),

                        _billItemField(
                          icon: Iconsax.wallet_2,
                          title: "Bill Amount",
                          subtitle: "Auto calculated",
                          value: _formatAmount(
                            item.totalAmount ??
                                ((item.taxableValue ??
                                        ((item.grossAmount ?? 0) -
                                            (item.discountAmount ?? 0) +
                                            (item.addOnAmount ?? 0) +
                                            (item.ecrAmount ?? 0))) +
                                    (item.gstAmount ?? 0)),
                          ),
                          isLast: true,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _billItemField({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    bool isLast = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const iconSize = 42.0;

        final valueWidth = constraints.maxWidth * 0.38;

        return Container(
          constraints: const BoxConstraints(minHeight: 65),
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: Color(0xFFE8E6EF), width: 0.5),
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ICON
              Container(
                height: iconSize,
                width: iconSize,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.primaryPurple, size: 32),
              ),

              const SizedBox(width: 18),

              // TITLE
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF11132A),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF505077),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // VALUE BOX
              Container(
                width: valueWidth,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFDCD9E8),
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  String _formatDisplayDate(String? value) {
    if (value == null || value.trim().isEmpty) return "";

    try {
      return DateFormat('dd-MM-yyyy')
          .format(DateTime.parse(value.trim()));
    } catch (_) {
      return value;
    }
  }
  void fillBillData(BillDetails bill) {
    dateController.text = _formatDisplayDate(bill.date);
    receivedDateController.text = _formatDisplayDate(bill.receivedDate);
    invoiceController.text = bill.invoiceNo ?? "";

    supplierGroupController.text = bill.supplierGroup ?? "";
    supplierGstController.text = bill.supplierGstNo ?? "";

    customerGroupController.text = bill.customerGroup ?? "";
    customerGstController.text = bill.customerGstNo ?? "";

    lrNumberController.text = bill.lrNumber ?? "";
    remarksController.text = bill.remarks ?? "";

    billItems = bill.items ?? [];

    billItemExpanded = List.generate(billItems.length, (_) => false);

    billItemKeys = List.generate(billItems.length, (_) => GlobalKey());
    final provider = context.read<EntriesProvider>();
    final supplier = provider.entries.where((e) => e.id == bill.supplierId);

    if (supplier.isNotEmpty) {
      selectedSupplier = supplier.first;
      selectedSupplierName = supplier.first.supplierName;
    }

    selectedSupplierName = selectedSupplier?.supplierName;
    final customer = provider.customerEntries.where(
      (e) => e.id == bill.customerId,
    );

    if (customer.isNotEmpty) {
      selectedCustomer = customer.first;
      selectedCustomerName = customer.first.customerName;
    }
    selectedCustomerName = selectedCustomer?.customerName;
    selectedTransportName = bill.transport;

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
    showBillItemError = false;

    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    setState(() {

      billItems = [];
      billItemExpanded = [];
      billItemKeys = [];

      selectedSupplier = null;
      selectedSupplierName = null;
      selectedCustomer = null;
      selectedCustomerName = null;

      selectedTransport = null;
      selectedTransportName = null;

      uploadedFiles = [];
      newUploadedFiles = [];
      existingUrls = [];
      existingObjectKeys = [];
      existingFileNames = [];
      removedObjectKeys = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EntriesProvider>();
    final bill = context.read<BillProvider>().billDetails;
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
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    EntryContainer(
                      children: [
                        Container(
                          height: 55,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    "Order Information",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isExpanded = !isExpanded;
                                  });
                                },
                                icon: Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isExpanded) ...[
                          SizedBox(height: 10),
                          _requiredLabel("Date"),
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
                          _requiredLabel("Invoice"),
                          EntryTextField(
                            enabled: !isViewMode,
                            controller: invoiceController,
                            hintText: "Invoice",
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onChanged: (value) {
                              if (value.trim().isNotEmpty) {
                                _formKey.currentState?.validate();
                              }
                            },
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
                          Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      "Supplier Information",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isSupplierExpanded = !isSupplierExpanded;
                                    });
                                  },
                                  icon: Icon(
                                    isSupplierExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSupplierExpanded) ...[
                            SizedBox(height: 10),
                         _requiredLabel("Supplier"),

                            CustomDropdown(
                              isDisabled: isViewMode,
                              hintText: "Supplier",
                              items: provider.entries
                                  .map((e) => e.supplierName ?? '')
                                  .toList(),
                              initialValue: selectedSupplierName,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Supplier is required";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                final supplier = provider.entries.firstWhere(
                                      (e) => e.supplierName == value,
                                );

                                debugPrint("========== SUPPLIER CHANGED ==========");
                                debugPrint("Selected supplier name: $value");
                                debugPrint("Selected supplier ID: ${supplier.id}");

                                setState(() {
                                  selectedSupplierName = value;
                                  selectedSupplier = supplier;

                                  supplierGroupController.text =
                                      supplier.supplierGroup ?? '';

                                  supplierGstController.text =
                                      supplier.supplierGstNo ?? '';
                                });
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
                          Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      "Customer Information",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isCustomerExpanded = !isCustomerExpanded;
                                    });
                                  },
                                  icon: Icon(
                                    isCustomerExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isCustomerExpanded) ...[
                            SizedBox(height: 10),
                            _requiredLabel("Customer"),
                            CustomDropdown(
                              isDisabled: isViewMode,
                              hintText: "Customer",
                              items: provider.customerEntries
                                  .map((e) => e.customerName ?? '')
                                  .toList(),
                              initialValue: selectedCustomerName,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
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
                          Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      "Logistic & Notes",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isLogisticExpanded = !isLogisticExpanded;
                                    });
                                  },
                                  icon: Icon(
                                    isLogisticExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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
                          final result = await showDialog<Map<String, dynamic>>(
                            context: context,
                            builder: (_) => BillEntryUploadDocuments(
                              existingImageKeys: existingObjectKeys,
                              existingFileNames: existingFileNames,
                              existingUrls: existingUrls,
                              files: newUploadedFiles,
                              isEditMode: widget.mode == FormMode.edit,
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              newUploadedFiles = List<PlatformFile>.from(
                                result["files"] ?? [],
                              );

                              existingObjectKeys = List<String>.from(
                                result["existingImageKeys"] ?? [],
                              );

                              existingFileNames = List<String>.from(
                                result["existingFileNames"] ?? [],
                              );

                              existingUrls = List<String>.from(
                                result["existingUrls"] ?? [],
                              );
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!_scrollController.hasClients) return;

                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
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
                            border: Border.all(color: const Color(0xFFE4D9FF)),
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
                    // EXISTING BILL ITEMS
                    if (billItems.isNotEmpty) ...[
                      const SizedBox(height: 15),

                      Column(
                        children: List.generate(billItems.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: _buildBillItemCard(billItems[index], index),
                          );
                        }),
                      ),

                      if (!isViewMode) ...[
                        const SizedBox(height: 2),

                        GestureDetector(
                          onTap: () async {
                            final BillItem? item =
                                await Navigator.push<BillItem>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddNewBillItem(),
                                  ),
                                );

                            if (item != null) {
                              setState(() {
                                billItems.add(item);

                                billItemExpanded.add(true);
                                billItemKeys.add(GlobalKey());

                                showBillItemError = false;
                              });

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted || billItemKeys.isEmpty) return;

                                final target = billItemKeys.last.currentContext;

                                if (target == null) return;

                                Scrollable.ensureVisible(
                                  target,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  alignment: 0.08,
                                );
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.primaryPurple,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  "+ Add Bill Item",
                                  style: TextStyle(color: Colors.white),

                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      // SUMMARY
                      const SizedBox(height: 12),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 17,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryPurple,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(17),
                                  topRight: Radius.circular(17),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.bodyFillColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.pie_chart_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Summary",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              child: Column(
                                children: [
                                  _summaryRow(
                                    icon: Iconsax.calculator,
                                    title: "Taxable Value",
                                    value: totalTaxableValue.toStringAsFixed(2),
                                  ),
                                  _summaryRow(
                                    icon: Iconsax.wallet_2,
                                    title: "Bill Amount",
                                    value: totalBillAmount.toStringAsFixed(2),
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                    // NO ITEMS YET
                    else if (!isViewMode) ...[
                      const SizedBox(height: 15),

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
                              billItemKeys.add(GlobalKey());

                              showBillItemError = false;
                            });

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted || billItemKeys.isEmpty) return;

                              final target = billItemKeys.last.currentContext;

                              if (target == null) return;

                              Scrollable.ensureVisible(
                                target,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                                alignment: 0.08,
                              );
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: AppColors.primaryPurple,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
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
                    if (showBillItemError)
                      const Padding(
                        padding: EdgeInsets.only(top: 5, left: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Please add at least one bill item",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
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
                      const SizedBox(height: 15),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Attachments",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          if (existingUrls.isEmpty)
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
                              children: List.generate(existingUrls.length, (
                                index,
                              ) {
                                final imageUrl = existingUrls[index];

                                final fileName =
                                    existingFileNames.length > index &&
                                        existingFileNames[index].isNotEmpty
                                    ? existingFileNames[index]
                                    : "Attachment ${index + 1}";

                                final isPdf = fileName.toLowerCase().endsWith(
                                  '.pdf',
                                );

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      // FILE ICON
                                      Container(
                                        height: 48,
                                        width: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4F0FF),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          isPdf
                                              ? Icons.picture_as_pdf_outlined
                                              : Icons.image_outlined,
                                          color: AppColors.primaryPurple,
                                          size: 27,
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      // FILE NAME
                                      Expanded(
                                        child: Text(
                                          fileName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),

                                      // VIEW
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 38,
                                          minHeight: 38,
                                        ),
                                        icon: const Icon(
                                          Icons.remove_red_eye,
                                          color: Colors.blue,
                                          size: 23,
                                        ),
                                        onPressed: () async {
                                          if (imageUrl.isEmpty) {
                                            ScaffoldSnackBar.show(
                                              context,
                                              "Invalid document URL",
                                            );
                                            return;
                                          }

                                          await viewAttachment(
                                            imageUrl,
                                            fileName,
                                          );
                                        },
                                      ),

                                      // DOWNLOAD
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 38,
                                          minHeight: 38,
                                        ),
                                        icon: const Icon(
                                          Icons.download,
                                          color: Colors.green,
                                          size: 23,
                                        ),
                                        onPressed: () async {
                                          if (imageUrl.isEmpty) {
                                            ScaffoldSnackBar.show(
                                              context,
                                              "Download URL not available",
                                            );
                                            return;
                                          }

                                          await _downloadAttachment(
                                            imageUrl,
                                            fileName,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                        ],
                      ),
                    ],
                    if (widget.mode == FormMode.add) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 10),
                        child: Row(
                          children: [
                            // RESET
                            Expanded(
                              child: SizedBox(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(5),
                                    onTap: () {
                                      clearFields();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: const Color(0xFFE5E2EE),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.refresh_rounded,
                                            color: AppColors.primaryPurple,
                                            size: 30,
                                          ),
                                          const SizedBox(width: 10),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: const Text(
                                              "Reset",
                                              style: TextStyle(
                                                color: AppColors.primaryPurple,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),
                            // SAVE
                            Expanded(
                              child: SizedBox(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(5),
                                    onTap: () async {
                                      setState(() {
                                        isExpanded = true;
                                        isSupplierExpanded = true;
                                        isCustomerExpanded = true;
                                      });

                                      final isValid =
                                          _formKey.currentState?.validate() ??
                                          false;

                                      if (!isValid) {
                                        ScaffoldSnackBar.show(
                                          context,
                                          "Please fill all the required fields",
                                        );
                                        return;
                                      }

                                      if (billItems.isEmpty) {
                                        setState(() {
                                          showBillItemError = true;
                                        });
                                        return;
                                      }

                                      final payload = {
                                        "date": _toApiDate(dateController.text),
                                        "receivedDate": _toApiDate(
                                            receivedDateController.text),
                                        "order": invoiceController.text,
                                        "supplierId": selectedSupplier?.id,
                                        "customerId": selectedCustomer?.id,
                                        "transportId": selectedTransport?.id,
                                        "transportName":
                                            selectedTransport?.name,
                                        "transportCity":
                                            selectedTransport?.city,
                                        "lrNumber": lrNumberController.text,
                                        "remarks": remarksController.text,

                                        "taxableValue": billItems.fold<double>(
                                          0.0,
                                          (sum, item) =>
                                              sum +
                                              (item.taxableValue ?? 0)
                                                  .toDouble(),
                                        ),

                                        "billAmount": billItems.fold<double>(
                                          0.0,
                                          (sum, item) =>
                                              sum +
                                              (item.totalAmount ?? 0)
                                                  .toDouble(),
                                        ),

                                        "billItems": billItems
                                            .map(
                                              (item) => {
                                                "pieces": item.pieces,
                                                "grossAmount": item.grossAmount,
                                                "discountPercent":
                                                    item.discountPercent,
                                                "discountAmount":
                                                    item.discountAmount,
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
                                        await provider.saveBill(
                                          payload: payload,
                                          images: images,
                                        );

                                        if (!context.mounted) return;

                                        Navigator.pop(context, true);
                                      } catch (e) {
                                        if (!context.mounted) return;

                                        ScaffoldSnackBar.show(
                                          context,
                                          e.toString(),
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPurple,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Save",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                            setState(() {
                              showBillItemError = true;
                            });
                            return;
                          }

                          final payload = {
                            "date": _toApiDate(dateController.text),
                            "receivedDate": _toApiDate(
                              receivedDateController.text,
                            ),

                            "order": invoiceController.text,
                            "supplierId": selectedSupplier?.id,
                            "customerId": selectedCustomer?.id,
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
                            debugPrint("========== UPDATE BILL ==========");
                            debugPrint("Bill ID: ${bill?.id}");
                            debugPrint("Selected Supplier: ${selectedSupplier?.supplierName}");
                            debugPrint("Selected Supplier ID: ${selectedSupplier?.id}");
                            debugPrint("Payload Supplier ID: ${payload["supplierId"]}");
                            debugPrint("Payload: $payload");
                            final success = await provider.updateBillEntry(
                              id: bill?.id?.toInt() ?? 0,
                              payload: payload,
                              images: images,
                            );

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.of(context).pop(true);
                            } else {
                              ScaffoldSnackBar.show(
                                context,
                                provider.error ?? "Failed to update bill",
                              );
                            }
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
        ],
      ),
    );
  }

  Widget _summaryRow({
    required IconData icon,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    final iconSize = 42.0;
    return Container(
      constraints: const BoxConstraints(minHeight: 65),
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFE8E6EF), width: 0.5),
              ),
      ),
      child: Row(
        children: [
          Container(
            height: iconSize,
            width: iconSize,
            decoration: BoxDecoration(
              color: AppColors.containerFillColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 28),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
