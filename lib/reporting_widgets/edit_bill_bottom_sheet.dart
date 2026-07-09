import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../constants/colors_used.dart';
import '../provider/entries_provider/entries_section_provider.dart';
import '../reporting_documents_upload/reporting_upload_files.dart';
import '../services/update_bills_api.dart';
import 'package:url_launcher/url_launcher.dart';

class EditBillBottomSheet extends StatefulWidget {
  final Map<String, dynamic> billData;

  const EditBillBottomSheet({super.key, required this.billData});

  @override
  State<EditBillBottomSheet> createState() => _EditBillBottomSheetState();
}

class _EditBillBottomSheetState extends State<EditBillBottomSheet> {
  double taxableValue = 0;
  double billAmount = 0;
  bool showBillInfo = true;
  bool showSupplierInfo = false;
  bool showCustomerInfo = false;
  bool showBillItems = false;
  bool showAttachments = false;
  bool showTransportInfo = false;
  final GlobalKey _newItemKey = GlobalKey();
  late TextEditingController invoiceController;
  late TextEditingController lrController;
  late TextEditingController remarksController;
  late TextEditingController dateController;
  late TextEditingController receivedDateController;
  int? selectedSupplierId;
  int? selectedCustomerId;
  String? selectedTransport;
  bool isLoading = false;
  List<File> selectedFiles = [];
  List<Map<String, dynamic>> items = [];
  List<String> existingImageKeys = [];
  List<String> existingFileNames = [];
  List<String> existingPublicUrls = [];

  Future<void> _openSelectedFile(File file) async {
    await OpenFilex.open(file.path);
  }

  Widget _sectionHeader({
    required String title,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Future<void> _pickAttachment() async {
    final totalAttachments = existingFileNames.length + selectedFiles.length;

    if (totalAttachments >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can attach a maximum of 3 files.")),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);

                  final file = await AttachmentPicker.pickFromGallery();

                  if (file != null) {
                    if (existingFileNames.length + selectedFiles.length >= 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("You can attach a maximum of 3 files."),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      selectedFiles.add(file);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text("Document / PDF"),
                onTap: () async {
                  Navigator.pop(context);

                  final file = await AttachmentPicker.pickDocument();

                  if (file != null) {
                    if (existingFileNames.length + selectedFiles.length >= 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("You can attach a maximum of 3 files."),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      selectedFiles.add(file);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _editableItemField(
    String label,
    Map<String, dynamic> item,
    String key,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 6),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextFormField(
            initialValue: item[key]?.toString() ?? "",
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            onChanged: (value) {
              item[key] = value;
            },
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    taxableValue = (widget.billData['taxableValue'] ?? 0).toDouble();
    billAmount = (widget.billData['billAmount'] ?? 0).toDouble();
    selectedSupplierId = widget.billData['supplierId']?.toInt();
    selectedCustomerId = widget.billData['customerId']?.toInt();
    existingImageKeys = List<String>.from(widget.billData['objectKeys'] ?? []);

    existingPublicUrls = List<String>.from(widget.billData['publicUrls'] ?? []);

    existingFileNames = existingImageKeys
        .map((e) => e.split('/').last)
        .toList();
    items = List<Map<String, dynamic>>.from(widget.billData['items'] ?? []);
    if (items.isEmpty) {
      items.add({
        "pieces": "",
        "grossAmount": "",
        "discountPercent": "",
        "discountAmount": "",
        "addOnAmount": "",
        "ecrAmount": "",
        "gstPercent": "",
        "gstAmount": "",
      });
    }

    _calculateTotals();
    Future.microtask(() async {
      final provider = Provider.of<EntriesProvider>(context, listen: false);

      await Future.wait([
        provider.fetchSuppliers(),
        provider.fetchCustomer(),
        provider.fetchTransport(),
      ]);

      if (!mounted) return;

      setState(() {
        selectedSupplierId = widget.billData['supplierId']?.toInt();

        selectedCustomerId = widget.billData['customerId']?.toInt();
      });
    });
    selectedTransport = widget.billData['transport'];
    dateController = TextEditingController(text: widget.billData['date'] ?? '');

    receivedDateController = TextEditingController(
      text: widget.billData['receivedDate'] ?? '',
    );

    invoiceController = TextEditingController(
      text: widget.billData['invoiceNo'] ?? '',
    );

    lrController = TextEditingController(
      text: widget.billData['lrNumber'] ?? '',
    );

    remarksController = TextEditingController(
      text: widget.billData['remarks'] ?? '',
    );

    selectedTransport = widget.billData['transport'];
  }
  void _calculateTotals() {
    double taxable = 0;
    double total = 0;

    for (final item in items) {
      final gross =
          double.tryParse(item['grossAmount']?.toString() ?? '0') ?? 0;

      final discount =
          double.tryParse(item['discountAmount']?.toString() ?? '0') ?? 0;

      final addOn =
          double.tryParse(item['addOnAmount']?.toString() ?? '0') ?? 0;

      final ecr =
          double.tryParse(item['ecrAmount']?.toString() ?? '0') ?? 0;

      final gst =
          double.tryParse(item['gstAmount']?.toString() ?? '0') ?? 0;

      final taxableItem = gross - discount + addOn - ecr;

      taxable += taxableItem;
      total += taxableItem + gst;
    }

    taxableValue = taxable;
    billAmount = total;
  }
  Future<void> _previewFile(int index) async {
    if (index >= existingPublicUrls.length) return;

    final uri = Uri.parse(existingPublicUrls[index]);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    invoiceController.dispose();
    lrController.dispose();
    remarksController.dispose();
    dateController.dispose();
    receivedDateController.dispose();
    super.dispose();
  }

  Future<void> _updateBill() async {
    try {
      setState(() {
        isLoading = true;
      });

      await updateBill(
        id: widget.billData['id'],

        date: dateController.text,
        receivedDate: receivedDateController.text,

        supplierId: selectedSupplierId ?? 0,
        customerId: selectedCustomerId ?? 0,

        transport: selectedTransport ?? '',

        lrNumber: lrController.text,

        remarks: remarksController.text,

        taxableValue: taxableValue,

        billAmount: billAmount,

        billItems: items,

        existingImageKeys: existingImageKeys,

        files: selectedFiles,
      );
      if (!mounted) return;
      Navigator.pop(context, true);

      return;
    } catch (e) {
      debugPrint("Update Error => $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget readOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF1F3F6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.95,
      maxChildSize: 0.98,
      minChildSize: 0.70,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF9499D8), Color(0xFFB8BDE5)],
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),

                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Edit Bill",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _sectionHeader(
                  title: "Bill Information",
                  expanded: showBillInfo,
                  onTap: () {
                    setState(() {
                      showBillInfo = !showBillInfo;
                    });
                  },
                ),

                const SizedBox(height: 20),

                if (showBillInfo) ...[
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 700;

                      Widget billNumberField = _buildField(
                        label: "Bill Number",
                        child: TextFormField(
                          initialValue: widget.billData['billNumber'] ?? '',
                          enabled: false,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      );

                      Widget dateField = _buildField(
                        label: "Date",
                        child: TextFormField(
                          controller: dateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              dateController.text =
                                  "${pickedDate.year}-"
                                  "${pickedDate.month.toString().padLeft(2, '0')}-"
                                  "${pickedDate.day.toString().padLeft(2, '0')}";
                            }
                          },
                        ),
                      );

                      if (isMobile) {
                        return Column(children: [billNumberField, dateField]);
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: billNumberField),
                          const SizedBox(width: 20),
                          Expanded(child: dateField),
                        ],
                      );
                    },
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 700;

                      Widget receivedField = _buildField(
                        label: "Received Date",
                        child: TextFormField(
                          controller: receivedDateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              receivedDateController.text =
                                  "${pickedDate.year}-"
                                  "${pickedDate.month.toString().padLeft(2, '0')}-"
                                  "${pickedDate.day.toString().padLeft(2, '0')}";
                            }
                          },
                        ),
                      );

                      Widget invoiceField = _buildField(
                        label: "Invoice Number",
                        child: TextFormField(
                          controller: invoiceController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      );

                      if (isMobile) {
                        return Column(children: [receivedField, invoiceField]);
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: receivedField),
                          const SizedBox(width: 20),
                          Expanded(child: invoiceField),
                        ],
                      );
                    },
                  ),
                ],
                const SizedBox(height: 10),

                _sectionHeader(
                  title: "Supplier Information",
                  expanded: showSupplierInfo,
                  onTap: () {
                    setState(() {
                      showSupplierInfo = !showSupplierInfo;
                    });
                  },
                ),

                const SizedBox(height: 20),
                if (showSupplierInfo) ...[
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 700;

                      Widget supplierField = Consumer<EntriesProvider>(
                        builder: (context, provider, child) {
                          return _buildField(
                            label: "Supplier",
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,

                                value:
                                    provider.entries.any(
                                      (e) => e.id == selectedSupplierId,
                                    )
                                    ? selectedSupplierId
                                    : null,

                                items: provider.entries.map((supplier) {
                                  return DropdownMenuItem<int>(
                                    value: supplier.id?.toInt(),
                                    child: Text(
                                      supplier.supplierName ?? "",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),

                                onChanged: (value) {
                                  setState(() {
                                    selectedSupplierId = value;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      );

                      Widget groupField = _buildField(
                        label: "Supplier Group",
                        child: TextFormField(
                          initialValue: widget.billData['supplierGroup'] ?? '',
                          enabled: false,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      );

                      if (isMobile) {
                        return Column(children: [supplierField, groupField]);
                      }

                      return Row(
                        children: [
                          Expanded(child: supplierField),
                          const SizedBox(width: 20),
                          Expanded(child: groupField),
                        ],
                      );
                    },
                  ),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 700;

                      Widget msmeField = _buildField(
                        label: "MSME",
                        child: TextFormField(
                          initialValue: widget.billData['supplierMsme'] ?? '',
                          enabled: false,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      );

                      Widget gstField = _buildField(
                        label: "GSTIN",
                        child: TextFormField(
                          initialValue: widget.billData['supplierGstNo'] ?? '',
                          enabled: false,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      );

                      if (isMobile) {
                        return Column(children: [msmeField, gstField]);
                      }

                      return Row(
                        children: [
                          Expanded(child: msmeField),
                          const SizedBox(width: 20),
                          Expanded(child: gstField),
                        ],
                      );
                    },
                  ),
                ],
                const SizedBox(height: 10),

                _sectionHeader(
                  title: "Customer Information",
                  expanded: showCustomerInfo,
                  onTap: () {
                    setState(() {
                      showCustomerInfo = !showCustomerInfo;
                    });
                  },
                ),
                const SizedBox(height: 20),
                if (showCustomerInfo) ...[
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 700;

                      Widget customerField = Consumer<EntriesProvider>(
                        builder: (context, provider, child) {
                          return _buildField(
                            label: "Customer",
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,

                                value:
                                    provider.customerEntries.any(
                                      (e) => e.id == selectedCustomerId,
                                    )
                                    ? selectedCustomerId
                                    : null,

                                items: provider.customerEntries.map((customer) {
                                  return DropdownMenuItem<int>(
                                    value: customer.id?.toInt(),
                                    child: Text(
                                      customer.customerName ?? "",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),

                                onChanged: (value) {
                                  setState(() {
                                    selectedCustomerId = value;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      );
                      Widget groupField = _buildField(
                        label: "Customer Group",
                        child: TextFormField(
                          initialValue: widget.billData['customerGroup'] ?? '',
                          enabled: false,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      );

                      if (isMobile) {
                        return Column(children: [customerField, groupField]);
                      }

                      return Row(
                        children: [
                          Expanded(child: customerField),
                          const SizedBox(width: 20),
                          Expanded(child: groupField),
                        ],
                      );
                    },
                  ),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 700;

                      Widget msmeField = _buildField(
                        label: "MSME",
                        child: TextFormField(
                          initialValue: widget.billData['customerMsme'] ?? '',
                          enabled: false,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      );

                      Widget gstField = _buildField(
                        label: "GSTIN",
                        child: TextFormField(
                          initialValue: widget.billData['customerGstNo'] ?? '',
                          enabled: false,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      );

                      if (isMobile) {
                        return Column(children: [msmeField, gstField]);
                      }

                      return Row(
                        children: [
                          Expanded(child: msmeField),
                          const SizedBox(width: 20),
                          Expanded(child: gstField),
                        ],
                      );
                    },
                  ),
                ],
                const SizedBox(height: 20),

                _sectionHeader(
                  title: "Bill Items",
                  expanded: showBillItems,
                  onTap: () {
                    setState(() {
                      showBillItems = !showBillItems;
                    });
                  },
                ),

                const SizedBox(height: 20),

                if (showBillItems) ...[
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          items.add({
                            "pieces": "",
                            "grossAmount": "",
                            "discountPercent": "",
                            "discountAmount": "",
                            "addOnAmount": "",
                            "ecrAmount": "",
                            "gstPercent": "",
                            "gstAmount": "",
                          });

                          _calculateTotals();
                        });

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final ctx = _newItemKey.currentContext;

                          if (ctx != null) {
                            Scrollable.ensureVisible(
                              ctx,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              alignment: 0.1, // Item appears at the top
                            );
                          }
                        });
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Add Bill Item",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ...List.generate(items.length, (index) {
                    final item = items[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == items.length - 1)
                            Container(
                              key: _newItemKey,
                              height: 1,
                            ),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Item ${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (items.length == 1) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "At least 1 item is required.",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() {
                                      items.removeAt(index);
                                      _calculateTotals();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _editableItemField(
                                  "Pieces",
                                  item,
                                  "pieces",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _editableItemField(
                                  "Gross Amount",
                                  item,
                                  "grossAmount",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _editableItemField(
                                  "Disc %",
                                  item,
                                  "discountPercent",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _editableItemField(
                                  "Disc Amount",
                                  item,
                                  "discountAmount",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _editableItemField(
                                  "Add-On",
                                  item,
                                  "addOnAmount",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _editableItemField(
                                  "ECR",
                                  item,
                                  "ecrAmount",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _editableItemField(
                                  "GST %",
                                  item,
                                  "gstPercent",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _editableItemField(
                                  "GST Amount",
                                  item,
                                  "gstAmount",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Taxable Value",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("₹${taxableValue.toStringAsFixed(2)}")
                          ],
                        ),

                        const Divider(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Bill Amount",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("₹${billAmount.toStringAsFixed(2)}")
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _sectionHeader(
                  title: "Attachments",
                  expanded: showAttachments,
                  onTap: () {
                    setState(() {
                      showAttachments = !showAttachments;
                    });
                  },
                ),
                const SizedBox(height: 20),
                if (showAttachments) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Attachments (${existingFileNames.length + selectedFiles.length})",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ...List.generate(existingFileNames.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                InkWell(
                                  onTap: () => _previewFile(index),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.description_outlined),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Text(
                                            existingFileNames[index],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Positioned(
                                  right: -8,
                                  top: -8,
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.white,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 18,
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          existingImageKeys.removeAt(index);

                                          existingFileNames.removeAt(index);

                                          existingPublicUrls.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (existingFileNames.length + selectedFiles.length < 3)
                          InkWell(
                            onTap: _pickAttachment,
                            child: Container(
                              width: double.infinity,
                              height: 140,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  "+ Add Attachment",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        if (selectedFiles.isNotEmpty)
                          ...List.generate(selectedFiles.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        _openSelectedFile(selectedFiles[index]),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.attach_file),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Text(
                                              selectedFiles[index].path
                                                  .split('/')
                                                  .last,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: -8,
                                    top: -8,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 18,
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selectedFiles.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                _sectionHeader(
                  title: "Transport & Logistics Information",
                  expanded: showTransportInfo,
                  onTap: () {
                    setState(() {
                      showTransportInfo = !showTransportInfo;
                    });
                  },
                ),
                const SizedBox(height: 20),
                if (showTransportInfo) ...[
                  Consumer<EntriesProvider>(
                    builder: (context, provider, child) {
                      final transports = {
                        for (final t in provider.transportDetails)
                          if (t.name != null) t.name!: t,
                      }.values.toList();

                      return _buildField(
                        label: "Transport",
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value:
                                transports.any(
                                  (t) => t.name == selectedTransport,
                                )
                                ? selectedTransport
                                : null,
                            items: transports.map((transport) {
                              return DropdownMenuItem<String>(
                                value: transport.name,
                                child: Text(
                                  transport.name!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedTransport = value;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  _buildField(
                    label: "LR Number",
                    child: TextFormField(
                      controller: lrController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  _buildField(
                    label: "Remarks",
                    child: TextFormField(
                      controller: remarksController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _updateBill,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Updated",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}
