import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/colors_used.dart';
import '../../constants/view_image_method.dart';

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
  final ImagePicker _imagePicker = ImagePicker();
  List<PlatformFile> selectedFiles = [];
  late List<String> _existingFileNames;
  late List<String> _existingUrls;
  late List<String> _existingImageKeys;

  static const List<String> _allowedExtensions = [
    'jpg', 'jpeg', 'png', 'pdf',
  ];

  @override
  void initState() {
    super.initState();
    selectedFiles = List<PlatformFile>.from(widget.files);
    _existingFileNames = List<String>.from(widget.existingFileNames);
    _existingUrls = List<String>.from(widget.existingUrls);
    _existingImageKeys = List<String>.from(widget.existingImageKeys);
  }

  int get _totalFiles => _existingFileNames.length + selectedFiles.length;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _isAllowedFile(String name) {
    final extension = name.split('.').last.toLowerCase();
    return _allowedExtensions.contains(extension);
  }

  void _addSelectedFiles(List<PlatformFile> files) {
    if (!mounted || files.isEmpty) return;

    final remainingSlots = 3 - _totalFiles;
    if (remainingSlots <= 0) {
      _showMessage('Maximum 3 files can be uploaded');
      return;
    }

    int added = 0;
    bool skippedUnsupported = false;
    for (final file in files) {
      if (!_isAllowedFile(file.name)) {
        skippedUnsupported = true;
        continue;
      }

      final alreadyAdded = selectedFiles.any((existing) =>
      (file.path != null && existing.path == file.path) ||
          existing.name.toLowerCase() == file.name.toLowerCase());
      if (alreadyAdded) continue;

      if (added >= remainingSlots) break;
      selectedFiles.add(file);
      added++;
    }

    setState(() {});

    if (skippedUnsupported) {
      _showMessage('Only JPG, JPEG, PNG and PDF files are supported');
    } else if (files.length > added && _totalFiles >= 3) {
      _showMessage('Maximum 3 files can be uploaded');
    }
  }

  Future<void> takePhoto() async {
    if (_totalFiles >= 3) {
      _showMessage('Maximum 3 files can be uploaded');
      return;
    }

    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (photo == null || !mounted) return;

      final extension = photo.name.split('.').last.toLowerCase();
      final safeName = extension.isEmpty || extension == photo.name
          ? 'bill_photo_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : photo.name;
      final file = PlatformFile(
        name: safeName,
        path: photo.path,
        size: await photo.length(),
      );
      _addSelectedFiles([file]);
    } catch (e) {
      _showMessage('Unable to open camera: $e');
    }
  }

  /// Opens the system file chooser with image and PDF filters. On Android,
  /// users can choose images from the device's image locations as well as PDFs.
  Future<void> chooseFromGallery() async {
    if (_totalFiles >= 3) {
      _showMessage('Maximum 3 files can be uploaded');
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        allowMultiple: true,
        withData: false,
      );
      if (result == null || !mounted) return;
      _addSelectedFiles(result.files);
    } catch (e) {
      _showMessage('Unable to select files: $e');
    }
  }

  void _removeAllFiles() {
    setState(() {
      selectedFiles.clear();
      if (widget.isEditMode) {
        _existingFileNames.clear();
        _existingUrls.clear();
        _existingImageKeys.clear();
      }
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }

  Widget _buildFileIcon(String fileName, {String? path}) {
    final extension = fileName.split('.').last.toLowerCase();

    if (path != null && ['jpg', 'jpeg', 'png'].contains(extension)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Image.file(
          File(path),
          height: 52,
          width: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackFileIcon(extension),
        ),
      );
    }
    return _buildFallbackFileIcon(extension);
  }

  Widget _buildFallbackFileIcon(String extension) {
    final isPdf = extension == 'pdf';
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: isPdf ? const Color(0xFFFFEEEE) : AppColors.primaryPurpleLight,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(
        isPdf ? Icons.picture_as_pdf_rounded : Icons.image_outlined,
        color: isPdf ? Colors.redAccent : AppColors.primaryPurple,
        size: 30,
      ),
    );
  }

  Widget _buildFileCard({
    required String fileName,
    required String fileSize,
    String? localPath,
    VoidCallback? onRemove,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F0FC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildFileIcon(fileName, path: localPath),
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
                      color: Color(0xFF111D5E),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (fileSize.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      fileSize,
                      style: const TextStyle(
                        color: Color(0xFF68658A),
                        fontSize: 12,
                      ),
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
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF34228F),
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            // Keep the contents comfortably inside the fixed-height option card.
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE7E3FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primaryPurple, size: 38),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111D5E),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadOptions() {
    final canAddMore = !widget.isViewMode && _totalFiles < 3;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F1FF),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.45),
          width: 1.4,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 145,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildUploadOption(
                  icon: Icons.camera_alt_rounded,
                  title: 'Take Photo',
                  onTap: canAddMore ? takePhoto : null,
                ),
                const SizedBox(width: 12),
                Container(
                  height: 105,
                  width: 1.2,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  color: AppColors.primaryPurple.withValues(alpha: 0.28),
                ),
                const SizedBox(width: 12),
                _buildUploadOption(
                  icon: Icons.file_present_sharp,
                  title: 'Choose from Files',
                  onTap: canAddMore ? chooseFromGallery : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Divider(
            color: AppColors.primaryPurple.withValues(alpha: 0.22),
            height: 1,
          ),
          const SizedBox(height: 10),
          const Text(
            'Supports JPG, PNG, JPEG & PDF  •  Max 3 files',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF68658A),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_totalFiles >= 3) ...[
            const SizedBox(height: 7),
            const Text(
              'Maximum 3 files reached',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalFiles = _totalFiles;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bill Upload Documents',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF111D5E),
                    fontWeight: FontWeight.w700,
                    fontSize: 21,
                  ),
                ),
                const SizedBox(height: 20),
                if (totalFiles > 0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Selected Files ($totalFiles/3)',
                          style: const TextStyle(
                            color: Color(0xFF111D5E),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!widget.isViewMode)
                        TextButton(
                          onPressed: _removeAllFiles,
                          child: const Text(
                            'Remove All',
                            style: TextStyle(
                              color: AppColors.primaryPurple,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
                if (_existingFileNames.isNotEmpty)
                  ...List.generate(_existingFileNames.length, (index) {
                    final fileName = _existingFileNames[index];
                    final fileUrl = index < _existingUrls.length
                        ? _existingUrls[index]
                        : '';
                    return _buildFileCard(
                      fileName: fileName,
                      fileSize: '',
                      onTap: fileUrl.isEmpty
                          ? null
                          : () async => viewAttachment(fileUrl, fileName),
                      trailing: widget.isViewMode
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 34, minHeight: 34,
                            ),
                            icon: const Icon(
                              Icons.visibility_outlined,
                              color: AppColors.primaryPurple,
                            ),
                            onPressed: fileUrl.isEmpty
                                ? null
                                : () async => viewAttachment(fileUrl, fileName),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 34, minHeight: 34,
                            ),
                            icon: const Icon(
                              Icons.download_outlined,
                              color: Colors.green,
                            ),
                            onPressed: fileUrl.isEmpty
                                ? null
                                : () async => launchUrl(
                              Uri.parse(fileUrl),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                        ],
                      )
                          : widget.isEditMode
                          ? IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 35, minHeight: 35,
                        ),
                        icon: const Icon(
                          Icons.visibility_outlined,
                          color: AppColors.primaryPurple,
                        ),
                        onPressed: fileUrl.isEmpty
                            ? null
                            : () async => viewAttachment(fileUrl, fileName),
                      )
                          : null,
                      onRemove: widget.isEditMode
                          ? () {
                        setState(() {
                          _existingFileNames.removeAt(index);
                          if (index < _existingUrls.length) {
                            _existingUrls.removeAt(index);
                          }
                          if (index < _existingImageKeys.length) {
                            _existingImageKeys.removeAt(index);
                          }
                        });
                      }
                          : null,
                    );
                  }),
                ...selectedFiles.map((file) {
                  return _buildFileCard(
                    fileName: file.name,
                    fileSize: _formatFileSize(file.size),
                    localPath: file.path,
                    onTap: file.path == null
                        ? null
                        : () async => OpenAppFile.open(file.path!),
                    onRemove: widget.isViewMode
                        ? null
                        : () => setState(() => selectedFiles.remove(file)),
                  );
                }),
                if (!widget.isViewMode) ...[
                  if (totalFiles > 0) const SizedBox(height: 8),
                  _buildUploadOptions(),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: AppColors.primaryPurple.withValues(alpha: 0.65),
                              width: 1.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF111D5E),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!widget.isViewMode) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, {
                              'files': selectedFiles,
                              'existingImageKeys': _existingImageKeys,
                              'existingFileNames': _existingFileNames,
                              'existingUrls': _existingUrls,
                            }),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Colors.white,
                                  size: 23,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
