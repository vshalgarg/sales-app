import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:public_file_saver/public_file_saver.dart';
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
import '../../provider/reporting_provider/purchase_provider.dart';

class PurchaseEntryScreen extends StatefulWidget {
  final FormMode mode;
  final num? id;

  const PurchaseEntryScreen({super.key, this.mode = FormMode.add, this.id});

  @override
  State<PurchaseEntryScreen> createState() => _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends State<PurchaseEntryScreen> {
  static const MethodChannel _channel = MethodChannel('file_opener');
  final _formKey = GlobalKey<FormState>();

  final ScrollController _scrollController = ScrollController();

  bool isInformationExpanded = true;

  bool isSupplierExpanded = true;

  EntriesCustomerModel? selectedCustomer;

  GetStaffEntry? selectedStaff;

  final transactionController = TextEditingController();

  List<TextEditingController> remarksControllers = [TextEditingController()];

  List<EntriesModel?> selectedSuppliers = [null];

  List<List<PlatformFile>> uploadedFiles = [[]];

  bool get isViewMode => widget.mode == FormMode.view;

  bool get isEditMode => widget.mode == FormMode.edit;

  bool get isAddMode => widget.mode == FormMode.add;
  List<String> existingImageKeys = [];
  List<String> existingUrls = [];
  List<String> existingFileNames = [];

  @override
  void initState() {
    super.initState();
    if (widget.mode == FormMode.add) {
      transactionController.text = DateFormat(
        "dd-MM-yyyy",
      ).format(DateTime.now());
    }
    final purchaseProvider = context.read<PurchaseProvider>();
    final entriesProvider = context.read<EntriesProvider>();

    Future.microtask(() async {
      if (isAddMode) {
        purchaseProvider.clearDetails();
      }

      await Future.wait([
        entriesProvider.fetchCustomer(),
        entriesProvider.fetchSuppliers(),
        entriesProvider.fetchStaff(),
      ]);

      if (widget.id != null) {
        final success = await purchaseProvider.fetchPurchaseDetails(widget.id!);

        if (success && purchaseProvider.purchaseDetails != null) {
          _fillData(purchaseProvider.purchaseDetails!, entriesProvider);
        }
      }
    });
  }
  String _toApiDate(String? value) {
    if (value == null || value.trim().isEmpty) return "";

    try {
      return DateFormat('yyyy-MM-dd').format(
        DateFormat('dd-MM-yyyy').parse(value.trim()),
      );
    } catch (_) {
      return value;
    }
  }

  String _formatDisplayDate(String? value) {
    if (value == null || value.trim().isEmpty) return "";

    try {
      return DateFormat('dd-MM-yyyy').format(
        DateTime.parse(value.trim()),
      );
    } catch (_) {
      return value;
    }
  }
  void _fillData(PurchaseDetails purchase, EntriesProvider entriesProvider) {
    transactionController.text = _formatDisplayDate(purchase.date);

    // Customer
    selectedCustomer = null;

    for (final customer in entriesProvider.customerEntries) {
      if (customer.id == purchase.customerId) {
        selectedCustomer = customer;
        break;
      }
    }

    // Staff
    selectedStaff = null;

    for (final staff in entriesProvider.staffList) {
      if (staff.staffId == purchase.staffId) {
        selectedStaff = staff;
        break;
      }
    }

    // Clear old supplier data
    for (final controller in remarksControllers) {
      controller.dispose();
    }

    remarksControllers = [];
    selectedSuppliers = [];
    uploadedFiles = [];

    // Remarks
    remarksControllers.add(TextEditingController(text: purchase.remarks));

    // Existing documents
    existingImageKeys = purchase.supplier.images
        .map((e) => e.key)
        .where((e) => e.isNotEmpty)
        .toList();

    existingUrls = purchase.supplier.images.map((e) => e.url).toList();

    existingFileNames = purchase.supplier.images
        .map((e) => e.fileName)
        .toList();

    // Supplier
    EntriesModel? supplier;

    for (final entry in entriesProvider.entries) {
      if (entry.id == purchase.supplier.supplierId) {
        supplier = entry;
        break;
      }
    }

    selectedSuppliers.add(supplier);
    uploadedFiles.add([]);

    if (mounted) {
      setState(() {});
    }
  }

  void clearFields() {
    _formKey.currentState?.reset();

    transactionController.text = DateFormat(
      "dd-MM-yyyy",
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
  Future<void> _downloadAttachment(
      String url,
      String fileName,
      ) async {
    try {
      if (url.isEmpty) {
        if (!mounted) return;

        ScaffoldSnackBar.show(
          context,
          'Download URL not available',
        );
        return;
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

      // Save to public Downloads
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

      // Show success message
      ScaffoldSnackBar.show(
        context,
        'File downloaded successfully',
      );

      // Give the SnackBar a moment to appear
      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      final uri = result.uri;

      if (uri == null || uri.isEmpty) {
        ScaffoldSnackBar.show(
          context,
          'File downloaded, but could not open it',
        );
        return;
      }

      // Native Android "Open with"
      await _channel.invokeMethod(
        'openFile',
        {
          'uri': uri,
          'mimeType': mimeType,
        },
      );
    } catch (e) {
      debugPrint('Download error: $e');

      if (!mounted) return;

      ScaffoldSnackBar.show(
        context,
        'Download failed: $e',
      );
    }
  }
  Future<bool> _validatePurchaseForm() async {
    // Open sections containing required fields
    setState(() {
      isInformationExpanded = true;
      isSupplierExpanded = true;
    });

    await Future<void>.delayed(Duration.zero);

    if (!mounted) return false;

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      ScaffoldSnackBar.show(
        context,
        "Please fill all the required fields",
      );
      return false;
    }

    if (selectedCustomer == null) {
      ScaffoldSnackBar.show(
        context,
        "Please select customer",
      );
      return false;
    }

    if (selectedSuppliers.isEmpty || selectedSuppliers.first == null) {
      ScaffoldSnackBar.show(
        context,
        "Please select supplier",
      );
      return false;
    }

    return true;
  }
  @override
  Widget build(BuildContext context) {
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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
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
                                "Information",
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
                                isInformationExpanded = !isInformationExpanded;
                              });
                            },
                            icon: Icon(
                              isInformationExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isInformationExpanded) ...[
                      const SizedBox(height: 10),

                      Text(
                        widget.mode != FormMode.view ? " Customer * " :"Customer",
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      Consumer<EntriesProvider>(
                        builder: (context, provider, child) {
                          return CustomDropdown(
                            isDisabled: isViewMode,
                            hintText: "Customer ",
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
                                selectedCustomer = provider.customerEntries
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
                        style: TextStyle(color: Colors.white, fontSize: 18),
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
                                selectedStaff = provider.staffList.firstWhere(
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
                        style: TextStyle(color: Colors.white, fontSize: 18),
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

                const SizedBox(height: 15),
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
                                "Suppliers",
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
                      const SizedBox(height: 10),
                      Column(
                        children: List.generate(selectedSuppliers.length, (
                          index,
                        ) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: AppColors.bodyFillColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        index == 0 && widget.mode != FormMode.view
                                            ? "Supplier ${index + 1}*"
                                            : "Supplier ${index + 1}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                      if (index != 0)
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              remarksControllers.removeAt(
                                                index,
                                              );
                                              selectedSuppliers.removeAt(
                                                index,
                                              );
                                              uploadedFiles.removeAt(index);
                                            });
                                          },
                                          child: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 24,
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  Consumer<EntriesProvider>(
                                    builder: (context, provider, child) {
                                      return CustomDropdown(
                                        isDisabled: isViewMode,

                                        hintText:"Supplier",

                                        isRequired: index == 0,

                                        items: provider.entries
                                            .map((e) => e.supplierName ?? "")
                                            .toList(),

                                        initialValue: selectedSuppliers[index]?.supplierName,

                                        validator: index == 0
                                            ? (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Supplier is required";
                                          }
                                          return null;
                                        }
                                            : null,

                                        onChanged: (value) {
                                          setState(() {
                                            selectedSuppliers[index] = provider.entries.firstWhere(
                                                  (e) => e.supplierName == value,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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

                                        if ((purchaseProvider
                                                .purchaseDetails
                                                ?.supplier
                                                .images
                                                .isEmpty ??
                                            true))
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                "No Documents Uploaded",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          )
                                        else
                                          Column(
                                            children: purchaseProvider.purchaseDetails!.supplier.images.map(
                                                  (image) {
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
                                                      //  FILE ICON
                                                      Container(
                                                        height: 48,
                                                        width: 48,
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFF4F0FF),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: Icon(
                                                          image.fileName.toLowerCase().endsWith('.pdf')
                                                              ? Icons.picture_as_pdf_outlined
                                                              : Icons.image_outlined,
                                                          color: AppColors.primaryPurple,
                                                          size: 27,
                                                        ),
                                                      ),

                                                      const SizedBox(width: 12),

                                                      //  FILE NAME
                                                      Expanded(
                                                        child: Text(
                                                          image.fileName,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),

                                                      //  VIEW
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
                                                          if (image.url.isEmpty) {
                                                            ScaffoldSnackBar.show(
                                                              context,
                                                              "Invalid document URL",
                                                            );
                                                            return;
                                                          }

                                                          final uri = Uri.parse(image.url);

                                                          try {
                                                            final launched = await launchUrl(
                                                              uri,
                                                              mode: LaunchMode.externalApplication,
                                                            );

                                                            if (!launched && context.mounted) {
                                                              ScaffoldSnackBar.show(
                                                                context,
                                                                "Unable to open document",
                                                              );
                                                            }
                                                          } catch (e) {
                                                            if (context.mounted) {
                                                              ScaffoldSnackBar.show(
                                                                context,
                                                                "Unable to open document",
                                                              );
                                                            }
                                                          }
                                                        },
                                                      ),

                                                      //  DOWNLOAD
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
                                                          if (image.url.isEmpty) {
                                                            ScaffoldSnackBar.show(
                                                              context,
                                                              "Download URL not available",
                                                            );
                                                            return;
                                                          }

                                                          await _downloadAttachment(
                                                            image.url,
                                                            image.fileName,
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ).toList(),
                                          ),
                                      ],
                                    )
                                  else
                                    GestureDetector(
                                      onTap: isViewMode
                                          ? null
                                          : () async {
                                              final dialog =
                                                  BillEntryUploadDocuments(
                                                    files:
                                                        uploadedFiles[index],

                                                    // Existing documents are only needed in Edit mode
                                                    existingImageKeys:
                                                        isEditMode
                                                        ? existingImageKeys
                                                        : [],
                                                    existingFileNames:
                                                        isEditMode
                                                        ? existingFileNames
                                                        : [],
                                                    existingUrls: isEditMode
                                                        ? existingUrls
                                                        : [],

                                                    isViewMode: isViewMode,
                                                    isEditMode: isEditMode,
                                                  );

                                              final result =
                                                  await showDialog<
                                                    Map<String, dynamic>
                                                  >(
                                                    context: context,
                                                    builder: (_) => dialog,
                                                  );

                                              if (result != null) {
                                                setState(() {
                                                  uploadedFiles[index] =
                                                      List<PlatformFile>.from(
                                                        result["files"] ?? [],
                                                      );

                                                  // Existing files are only relevant for Edit mode
                                                  if (isEditMode) {
                                                    existingImageKeys =
                                                        List<String>.from(
                                                          result["existingImageKeys"] ??
                                                              [],
                                                        );

                                                    existingFileNames =
                                                        List<String>.from(
                                                          result["existingFileNames"] ??
                                                              [],
                                                        );

                                                    existingUrls =
                                                        List<String>.from(
                                                          result["existingUrls"] ??
                                                              [],
                                                        );
                                                  }
                                                });
                                              }
                                            },
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 82,
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                                  color: const Color(
                                                    0xFFF4F0FF,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10,
                                                      ),
                                                ),
                                                child: const Icon(
                                                  Icons.cloud_upload_outlined,
                                                  color:
                                                      AppColors.primaryPurple,
                                                ),
                                              ),

                                              const SizedBox(width: 14),

                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
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
                                                    const SizedBox(height: 3),
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
                                                        5,
                                                      ),
                                                ),
                                                child: Text(
                                                  "${(isEditMode ? existingImageKeys.length : 0) + uploadedFiles[index].length}/3",
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
                                    ),

                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      if (isAddMode)
                        CustomElevatedButton(
                          color: AppColors.primaryPurple,
                          text: "+ Add More Supplier",
                          textStyle: const TextStyle(color: Colors.white),
                          borderRadius: 5,
                          onPressed: () async {
                            setState(() {
                              remarksControllers.add(TextEditingController());

                              selectedSuppliers.add(null);

                              uploadedFiles.add([]);
                            });
                          },
                        ),
                    ],
                    if (isAddMode) ...[
                      const SizedBox(height: 15),

                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(5),
                                    onTap: () {
                                      clearFields();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFE5E2EE),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.refresh_rounded,
                                            color: AppColors.primaryPurple,
                                            size: 30,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Reset",
                                            style: TextStyle(
                                              color: AppColors.primaryPurple,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(5),
                                    onTap: () async {
                                      final isValid = await _validatePurchaseForm();

                                      if (!isValid) return;

                                      final request = AddPurchaseRequest(
                                        date: _toApiDate(transactionController.text),
                                        staffId: selectedStaff?.staffId,
                                        customerId: selectedCustomer!.id!,
                                        suppliers: List.generate(
                                          selectedSuppliers.length,
                                              (index) => index,
                                        )
                                            .where((index) => selectedSuppliers[index] != null)
                                            .map(
                                              (index) => PurchaseSupplierRequest(
                                            supplierId: selectedSuppliers[index]!.id!,
                                            remarks: remarksControllers[index].text.trim(),
                                          ),
                                        )
                                            .toList(),
                                      );

                                      final purchaseProvider = context.read<PurchaseProvider>();

                                      final success = await purchaseProvider.addPurchase(
                                        request: request,
                                        uploadedFiles: uploadedFiles,
                                        selectedSuppliers: selectedSuppliers,
                                      );

                                      if (!context.mounted) return;

                                      if (success) {
                                        Navigator.pop(context, true);
                                      } else {
                                        ScaffoldSnackBar.show(
                                          context,
                                          "Failed to add purchase",
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPurple,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.save_rounded,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                          const SizedBox(width: 10),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "Save",
                                              style: TextStyle(
                                                color: Colors.white,
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height:20),
                if (isEditMode)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 0,
                      ),
                      child: CustomElevatedButton(
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
                            date: _toApiDate(transactionController.text),
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
                            existingImageKeys,
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
                            if (!context.mounted) return;

                            ScaffoldSnackBar.show(
                              context,
                              "Failed to update purchase",
                            );
                            return;
                          }

                          if (!context.mounted) return;

                          ScaffoldSnackBar.show(
                            context,
                            "Purchase updated successfully",
                          );
                          await purchaseProvider
                              .refreshPurchases();

                          if (!context.mounted) return;

                          Navigator.pop(context, true);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
