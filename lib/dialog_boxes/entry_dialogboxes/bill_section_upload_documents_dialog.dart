import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/colors_used.dart';
import '../../constants/view_image_method.dart';
import '../../entry_document_upload/entry_upload_files.dart';

class BillEntryUploadDocuments extends StatefulWidget {
  final List<PlatformFile> files;
  final List<String> existingFileNames;
  final List<String> existingUrls;
  final List<String> existingImageKeys;
  final bool isViewMode;
  final bool isEditMode;

  const BillEntryUploadDocuments({
    super.key,
    required this.files,
    required this.existingImageKeys,
    required this.existingFileNames,
    required this.existingUrls,
    this.isViewMode = false,
    this.isEditMode = false,
  });

  @override
  State<BillEntryUploadDocuments> createState() =>
      _BillEntryUploadDocumentsState();
}

class _BillEntryUploadDocumentsState extends State<BillEntryUploadDocuments> {
  List<PlatformFile> selectedFiles = [];

  @override
  void initState() {
    super.initState();
    selectedFiles = List<PlatformFile>.from(widget.files);
  }

  Future<void> selectFiles() async {
    final files = await pickFiles();
    if (!mounted) return;
    if (files.isEmpty) return;

    final totalFiles = widget.existingFileNames.length + selectedFiles.length;

    final remainingSlots = 3 - totalFiles;

    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 3 files can be uploaded")),
      );
      return;
    }

    int added = 0;

    for (final file in files) {
      if (added >= remainingSlots) break;

      if (!selectedFiles.any((e) => e.path == file.path)) {
        selectedFiles.add(file);
        added++;
      }
    }

    setState(() {});
  }

  Widget _buildFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    IconData icon;
    Color iconColor;
    Color backgroundColor;

    if (extension == 'pdf') {
      icon = Icons.picture_as_pdf_outlined;
      iconColor = Colors.redAccent;
      backgroundColor = const Color(0xFFFFEEEE);
    } else if (extension == 'jpg' ||
        extension == 'jpeg' ||
        extension == 'png') {
      icon = Icons.image_outlined;
      iconColor = AppColors.primaryPurple;
      backgroundColor = AppColors.primaryPurpleLight;
    } else {
      icon = Icons.insert_drive_file_outlined;
      iconColor = AppColors.primaryPurple;
      backgroundColor = AppColors.primaryPurpleLight;
    }

    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: 27),
    );
  }

  Widget _buildFileCard({
    required String fileName,
    required String fileSize,
    VoidCallback? onRemove,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE1DEED)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildFileIcon(fileName),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (fileSize.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      fileSize,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),

            if (trailing != null) trailing,

            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
                icon: const Icon(Icons.close, color: Colors.red, size: 25),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalFiles =
        widget.existingFileNames.length + selectedFiles.length;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Container(
        width: MediaQuery.of(context).size.width > 700
            ? 680
            : MediaQuery.of(context).size.width * 0.92,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Bill Upload Documents",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            // Existing Files
            if (widget.existingFileNames.isNotEmpty)
              ...List.generate(widget.existingFileNames.length, (index) {
                return _buildFileCard(
                  fileName: widget.existingFileNames[index],
                  fileSize: "",

                  onTap: () async {
                    await viewAttachment(
                      widget.existingUrls[index],
                      widget.existingFileNames[index],
                    );
                  },
                  trailing: widget.isViewMode
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 35,
                                minHeight: 35,
                              ),
                              icon: const Icon(
                                Icons.remove_red_eye,
                                color: Colors.blue,
                              ),
                              onPressed: () async {
                                await viewAttachment(
                                  widget.existingUrls[index],
                                  widget.existingFileNames[index],
                                );
                              },
                            ),

                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 35,
                                minHeight: 35,
                              ),
                              icon: const Icon(
                                Icons.download,
                                color: Colors.green,
                              ),
                              onPressed: () async {
                                final uri = Uri.parse(
                                  widget.existingUrls[index],
                                );

                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                            ),
                          ],
                        )
                      : widget.isEditMode
                      ? IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 35,
                            minHeight: 35,
                          ),
                          icon: const Icon(
                            Icons.remove_red_eye,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            await viewAttachment(
                              widget.existingUrls[index],
                              widget.existingFileNames[index],
                            );
                          },
                        )
                      : null,
                  onRemove: widget.isEditMode
                      ? () {
                          setState(() {
                            widget.existingFileNames.removeAt(index);
                            widget.existingUrls.removeAt(index);
                            widget.existingImageKeys.removeAt(index);
                          });
                        }
                      : null,
                );
              }),
            if (selectedFiles.isNotEmpty)
              ...selectedFiles.map((file) {
                return _buildFileCard(
                  fileName: file.name,
                  fileSize: "${(file.size / 1024).toStringAsFixed(2)} KB",
                  onTap: () async {
                    if (file.path != null) {
                      await OpenAppFile.open(file.path!);
                    }
                  },
                  onRemove: widget.isViewMode
                      ? null
                      : () {
                          setState(() {
                            selectedFiles.remove(file);
                          });
                        },
                );
              }),
            const SizedBox(height: 10),
            if (!widget.isViewMode && totalFiles < 3)
              GestureDetector(
                onTap: selectFiles,

                child: DottedBorder(
                  color: AppColors.primaryPurple.withValues(alpha: 0.35),
                  strokeWidth: 1.5,
                  dashPattern: const [6, 4],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: totalFiles == 0 ? 18 : 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF9FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Upload icon
                        Container(
                          height: totalFiles == 0 ? 58 : 44,
                          width: totalFiles == 0 ? 58 : 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurpleLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            color: AppColors.primaryPurple,
                            size: totalFiles == 0 ? 42 : 30,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          totalFiles == 0
                              ? "Drag & drop files here"
                              : "Add more files",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          totalFiles == 0
                              ? "or browse files"
                              : "Drag & drop or browse",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Supported formats
                        const Text(
                          "Supports JPG, PNG, JPEG & PDF",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),

                        const SizedBox(height: 3),

                        const Text(
                          "Max 3 files",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(height: 15),
            Row(
              children: [
                // CANCEL
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: AppColors.primaryPurple.withValues(
                            alpha: 0.35,
                          ),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xFF111D5E),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                // SAVE
                if (!widget.isViewMode)
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            "files": selectedFiles,
                            "existingImageKeys": widget.existingImageKeys,
                            "existingFileNames": widget.existingFileNames,
                            "existingUrls": widget.existingUrls,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              color: Colors.white,
                              size: 26,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
  }
}
