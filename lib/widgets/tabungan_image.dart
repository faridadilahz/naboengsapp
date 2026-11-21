import 'dart:convert';
import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:ionicons/ionicons.dart';
import '../utils/app_colors.dart';

class TabunganImage extends StatelessWidget {
  final String imageSource;
  final double? height;
  final double? width;
  final BoxFit fit;

  static final Map<String, Uint8List> _memoryCache = {};

  const TabunganImage({
    super.key,
    required this.imageSource,
    this.height,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
  });

  Uint8List _getBytes(String raw) {
    final String key =
        '${raw.length}_${raw.substring(0, raw.length > 32 ? 32 : raw.length)}';
    return _memoryCache.putIfAbsent(key, () {
      final clean = raw.contains(',') ? raw.split(',').last : raw;
      return base64Decode(clean);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (imageSource.trim().isEmpty) {
      return _buildFallback();
    }

    try {
      final bytes = _getBytes(imageSource);
      return Image.memory(
        bytes,
        height: height,
        width: width,
        fit: fit,
        gaplessPlayback: true,
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
      child: const Icon(Ionicons.imageOutline, color: AppColors.textMuted),
    );
  }
}