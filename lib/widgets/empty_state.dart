import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const EmptyState({super.key, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32, bottom: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Ionicons.file_tray, size: 86, color: Color(0xffaaaaaa)),
            const SizedBox(height: 24),
            const Text(
              "Belum ada sesuatu yang mau ditabung nih, yuk tambah tabungan!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xffaaaaaa),
                fontSize: 16,
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(
                Ionicons.add,
                color: Colors.white,
              ),
              label: const Text(
                "Tambah Tabungan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B6B5A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
