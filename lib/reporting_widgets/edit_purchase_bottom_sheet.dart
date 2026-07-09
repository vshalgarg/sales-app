import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors_used.dart';
import '../provider/entries_provider/entries_section_provider.dart';
import '../provider/staff_provider.dart';
import '../reporting_documents_upload/reporting_upload_files.dart';
import '../services/update_purchase_api.dart';

class EditPurchaseBottomSheet extends StatefulWidget {
  final Map<String, dynamic> purchaseData;

  const EditPurchaseBottomSheet({super.key, required this.purchaseData});

  @override
  State<EditPurchaseBottomSheet> createState() =>
      _EditPurchaseBottomSheetState();
}

class _EditPurchaseBottomSheetState extends State<EditPurchaseBottomSheet> {
  late TextEditingController remarksController;
  late TextEditingController dateController;

  int? selectedCustomerId;
  int? selectedSupplierId;
  int? selectedStaffId;

  List<File> selectedFiles = [];

  late List<String> existingImageKeys =
      (widget.purchaseData['supplierImages'] as List?)
          ?.map((e) => e['imageKey'].toString())
          .toList() ??
      [];
  List<String> existingFileNames = [];
  List<String> existingUrls = [];

  Widget _sectionHeader(String title) {
    return Container(
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
          const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
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
    final totalAttachments =
        existingFileNames.length + selectedFiles.length;

    if (totalAttachments >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can attach a maximum of 3 files."),
        ),
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

  @override
  void initState() {
    super.initState();

    _initializeData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _initializeData() {

    final supplier = widget.purchaseData["supplier"] ?? {};

    existingImageKeys = (supplier["images"] ?? [])
        .map<String>((e) => e["key"].toString())
        .toList();

    existingUrls = (supplier["images"] ?? [])
        .map<String>((e) => e["url"].toString())
        .toList();

    existingFileNames = (supplier["images"] ?? [])
        .map<String>((e) => e["fileName"].toString())
        .toList();

    remarksController = TextEditingController(
      text: widget.purchaseData["remarks"] ?? "",
    );

    dateController = TextEditingController(
      text: widget.purchaseData["date"] ?? "",
    );

    selectedCustomerId = widget.purchaseData["customerId"];

    selectedStaffId = widget.purchaseData["staffId"];

    selectedSupplierId = supplier["supplierId"];
  }

  Future<void> _loadData() async {
    try {
      final entriesProvider = context.read<EntriesProvider>();

      final staffProvider = context.read<StaffProvider>();

      await Future.wait([
        entriesProvider.fetchCustomer(),
        entriesProvider.fetchSuppliers(),
        staffProvider.fetchStaffs(),
      ]);
    } catch (e) {
      debugPrint("Error loading dropdown data: $e");
    }
  }

  Future<void> _previewFile(int index) async {
    if (index >= existingUrls.length) return;

    final uri = Uri.parse(existingUrls[index]);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    remarksController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _updatePurchase() async {
    try {
      await updatePurchase(
        id: widget.purchaseData["id"],
        date: dateController.text,
        customerId: selectedCustomerId!,
        supplierId: selectedSupplierId!,
        staffId: selectedStaffId!,
        remarks: remarksController.text.trim(),
        existingImageKeys: existingImageKeys,
        supplierImages: selectedFiles,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Purchase updated successfully")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
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
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).padding.bottom + 10,
            ),
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
                      "Edit Purchase",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
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

                _sectionHeader("Basic Information"),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 700;

                    Widget customerField = Consumer<EntriesProvider>(
                      builder: (_, provider, __) {
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
                              items: provider.customerEntries
                                  .map(
                                    (e) => DropdownMenuItem<int>(
                                      value: e.id?.toInt(),
                                      child: Text(
                                        e.customerName ?? "",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
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

                    Widget staffField = Consumer<StaffProvider>(
                      builder: (_, provider, __) {
                        return _buildField(
                          label: "Staff",
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value:
                                  provider.staffs.any(
                                    (e) => e.staffId == selectedStaffId,
                                  )
                                  ? selectedStaffId
                                  : null,
                              items: provider.staffs
                                  .map(
                                    (staff) => DropdownMenuItem<int>(
                                      value: staff.staffId,
                                      child: Text(
                                        staff.staffName,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedStaffId = value;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    );

                    if (isMobile) {
                      return Column(children: [customerField, staffField]);
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: customerField),
                        const SizedBox(width: 20),
                        Expanded(child: staffField),
                      ],
                    );
                  },
                ),

                _buildField(
                  label: "Transaction Date",
                  child: TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),

                Consumer<EntriesProvider>(
                  builder: (_, provider, __) {
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
                          items: provider.entries
                              .map(
                                (e) => DropdownMenuItem<int>(
                                  value: e.id?.toInt(),
                                  child: Text(
                                    e.supplierName ?? "",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSupplierId = value;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),

                _buildField(
                  label: "Remarks",
                  child: TextFormField(
                    controller: remarksController,
                    maxLines: 3,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),

                const SizedBox(height: 10),

                _sectionHeader("Attachments"),

                const SizedBox(height: 20),

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
                        "Attachments (${existingFileNames.length})",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (existingFileNames.isNotEmpty)
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
                                        const Icon(
                                          Icons.description_outlined,
                                          color: Colors.grey,
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                existingFileNames[index],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),

                                              const SizedBox(height: 4),

                                              const Text(
                                                "Tap to preview",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
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

                                          existingUrls.removeAt(index);
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
                              "Upload a File",
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
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.attach_file,
                                        color: Colors.green,
                                      ),

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

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                   width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updatePurchase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            "Update",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
