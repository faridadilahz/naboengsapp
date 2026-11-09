import 'dart:io';
import 'package:flutter/material.dart';
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
          border: Border.all(color: const Color(0xffeeeeee), width: 0.7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(item.imagePath!),
                  height: 144,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              item.nama,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xff333333),
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatRupiah(item.target),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 21,
                    color: Color(0xFF1B6B5A),
                  ),
                ),
                const SizedBox(height: 4),
                if (selectedTab == 1) ...[
                  const Text(
                    "Tercapai!",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B6B5A),
                    ),
                  ),
                ] else ...[
                  Text(
                    "Tabungan per ${item.tipe}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xffaaaaaa),
                    ),
                  ),
                  Text(
                    formatRupiah(item.perHari),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 19,
                      color: Color(0xff555555),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Color(0xffeeeeee), thickness: 1),
                  ),
                  Center(
                    child: Text(
                      _hitungSisaHari(item),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xffaaaaaa),
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
