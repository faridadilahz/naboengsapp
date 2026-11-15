import 'dart:io';
import 'package:flutter/material.dart';
import 'package:naboengs/utils/app_colors.dart';
import '../models/tabungan_model.dart';
import '../utils/format_rupiah.dart';

class TabunganCard extends StatelessWidget {
  final Tabungan item;
  final int selectedTab;
  final VoidCallback onTap;

  const TabunganCard({
    super.key,
    required this.item,
    required this.selectedTab,
    required this.onTap,
  });

  // HITUNG SISA HARI
  String _hitungSisaHari(Tabungan item) {
    int sisaUang = item.target - item.terkumpul;
    if (sisaUang <= 0) return "Selesai hari ini";
    if (item.perHari <= 0) return "-";

    int sisaPeriode = (sisaUang / item.perHari).ceil();
    String tipeLower = item.tipe.toLowerCase();
    int totalHari;

    if (tipeLower.contains('minggu')) {
      totalHari = sisaPeriode * 7;
    } else if (tipeLower.contains('bulan')) {
      totalHari = sisaPeriode * 30;
    } else {
      totalHari = sisaPeriode;
    }

    return "$totalHari hari lagi";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey, width: 0.7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(item.imagePath!),
                  height: 144,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            Text(
              item.nama,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.2, // 👈 Rapatkan line-height judul
              ),
            ),
            const SizedBox(height: 6), // 👈 Sedikit lebih rapat & konsisten
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatRupiah(item.target),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 21,
                    color: AppColors.primary,
                    height: 1.2, // 👈 Rapatkan line-height nominal target
                  ),
                ),
                if (selectedTab == 1) ...[
                  const SizedBox(
                    height: 4,
                  ),
                  const Text(
                    "Tercapai!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      height: 1.2,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Text(
                    "Tabungan per ${item.tipe}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    formatRupiah(item.perHari),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 19,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: AppColors.grey, thickness: 1),
                  ),
                  Center(
                    child: Text(
                      _hitungSisaHari(item),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
