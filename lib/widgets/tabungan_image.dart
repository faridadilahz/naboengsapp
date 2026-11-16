import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../utils/app_colors.dart';

class TabunganImage extends StatelessWidget {
  final String imageSource;
  final double? height;
  final double? width;
  final BoxFit fit;

  const TabunganImage({
    super.key,
    required this.imageSource,
    this.height,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final bytes = base64Decode(imageSource);
      return Image.memory(
        bytes,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } catch (_) {
      return _buildFallback();
    }
  }

  Widget _buildFallback() {
    return Container(
      height: height ?? 160,
      width: width ?? double.infinity,
      color: AppColors.grey,
      child: const Icon(Ionicons.image_outline, color: AppColors.textMuted),
    );
  }
}
