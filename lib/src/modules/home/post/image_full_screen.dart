import 'dart:io';

import 'package:flutter/material.dart';

class ImageFullScreenPage extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;

  const ImageFullScreenPage({super.key, this.imageUrl, this.imageFile});

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    if (imageFile != null) {
      imageProvider = FileImage(imageFile!);
    } else if (imageUrl != null && imageUrl!.startsWith('http')) {
      imageProvider = NetworkImage(imageUrl!);
    } else {
      imageProvider = AssetImage(imageUrl ?? '');
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image(image: imageProvider, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
