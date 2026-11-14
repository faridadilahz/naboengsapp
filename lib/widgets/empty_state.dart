import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;
  final bool isTercapaiTab; // ⚡ Tambahkan flag tab

  const EmptyState({
    super.key,
    required this.onAddPressed,
    this.isTercapaiTab = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32, bottom: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTercapaiTab ? Ionicons.trophy : Ionicons.file_tray,
              size: 86,
              color: const Color(0xffaaaaaa),
            ),
            const SizedBox(height: 24),
            Text(
              isTercapaiTab
                  ? "Belum ada tabungan yang berhasil tercapai. Tetap semangat nabungnya!"
                  : "Belum ada sesuatu yang mau ditabung nih, yuk tambah tabungan!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xffaaaaaa),
                fontSize: 16,
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            if (!isTercapaiTab) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Ionicons.add, color: Colors.white),
                label: const Text(
                  "TAMBAH TABUNGAN",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF1B6B5A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
