import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewScreen({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Preview")),
      body: InteractiveViewer(
        child: Center(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}