import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentPicker {
  static Future<File?> pickFromGallery() async {
    final XFile? image =
    await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return null;

    return File(image.path);
  }

  static Future<File?> pickFromCamera() async {
    final XFile? image =
    await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (image == null) return null;

    return File(image.path);
  }

  static Future<File?> pickDocument() async {
    FilePickerResult? result =
    await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'jpg',
        'jpeg',
        'png',
      ],
    );

    if (result == null ||
        result.files.single.path == null) {
      return null;
    }

    return File(
      result.files.single.path!,
    );
  }
}