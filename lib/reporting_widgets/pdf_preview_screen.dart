import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String pdfUrl;

  const PdfPreviewScreen({
    super.key,
    required this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Preview")),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}