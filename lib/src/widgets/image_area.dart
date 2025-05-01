import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageArea extends StatelessWidget {
  final Uint8List? imageBytes;
  const ImageArea({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: imageBytes != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(imageBytes!, fit: BoxFit.cover, width: 350, height: 240),
        )
            : const Icon(Icons.image, size: 60, color: Colors.grey),
      ),
    );
  }
}
