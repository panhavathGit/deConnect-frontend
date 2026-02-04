// lib/features/chat/presentation/views/full_image_view.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullImageView extends StatelessWidget {
  final String imageUrl;

  const FullImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (c, u) => const CircularProgressIndicator(
              color: Colors.white,
            ),
            errorWidget: (c, u, e) => const Icon(
              Icons.error,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}