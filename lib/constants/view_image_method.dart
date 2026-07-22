import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

Future<void> viewAttachment(String url, String fileName) async {
  try {
    final dir = await getTemporaryDirectory();
    final path = "${dir.path}/$fileName";

    final file = File(path);

    if (!await file.exists()) {
      await Dio().download(url, path);
    }

    await OpenFilex.open(path);
  } catch (e) {
    print(e);
  }
}