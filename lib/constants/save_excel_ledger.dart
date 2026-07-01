import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveExcel(Uint8List bytes) async {
  final dir = await getApplicationDocumentsDirectory();

  final file = File(
    "${dir.path}/Ledger_${DateTime.now().millisecondsSinceEpoch}.xlsx",
  );

  await file.writeAsBytes(bytes);

  await OpenFilex.open(file.path);
}