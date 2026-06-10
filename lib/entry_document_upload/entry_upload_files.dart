import 'package:file_picker/file_picker.dart';

Future<List<PlatformFile>> pickFiles() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
  );

  if (result != null) {
    return result.files;
  }

  return [];
}