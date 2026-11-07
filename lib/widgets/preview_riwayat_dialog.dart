import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../utils/format_rupiah.dart';

class PreviewRiwayatDialog extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(String) formatTanggal;

  const PreviewRiwayatDialog({
    super.key,
    required this.data,
    required this.onEdit,
    required this.onDelete,
    required this.formatTanggal,
  });

  @override
  Widget build(BuildContext context) {
    int nominal = data['nominal'] as int;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Detail Nominal",
                  style: TextStyle(
                    color: Color(0xFF555555),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatRupiah(nominal),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: nominal < 0
                        ? const Color(0xFFD35D5D)
                        : const Color(0xFF1B6B5A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Catatan: ${data['catatan'] != null && data['catatan'].toString().isNotEmpty ? data['catatan'] : '-'}",
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tanggal: ${formatTanggal(data['tanggal'])}",
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onEdit();
                      },
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          color: Color(0xFF1B6B5A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        onDelete();
                      },
                      child: const Text(
                        "Hapus",
                        style: TextStyle(
                          color: Color(0xFFD35D5D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Ionicons.close, color: Colors.grey, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
