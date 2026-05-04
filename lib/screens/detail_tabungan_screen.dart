import 'dart:io';
import 'package:flutter/material.dart';
import '../models/tabungan_model.dart';
import '../utils/format_rupiah.dart';

class DetailTabunganScreen extends StatelessWidget {
  final Tabungan item;

  const DetailTabunganScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    int sisa = item.target; // sementara (belum ada terkumpul)

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Edit", style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// NAMA
            Text(
              item.nama,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B6B5A),
              ),
            ),

            const SizedBox(height: 12),

            /// GAMBAR
            if (item.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(item.imagePath!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 16),

            /// TARGET
            Text(
              formatRupiah(item.target),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B6B5A),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "${formatRupiah(item.perHari)}/${item.tipe}",
              style: const TextStyle(
                color: Color(0xff777777),
              ),
            ),

            const SizedBox(height: 16),

            /// TANGGAL (dummy dulu)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Tanggal dibuat", style: TextStyle(color: Colors.grey)),
                Text("11 November 2025"),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Perkiraan selesai", style: TextStyle(color: Colors.grey)),
                Text("15 Januari 2029"),
              ],
            ),

            const SizedBox(height: 20),

            /// TERKUMPUL & SISA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text("Uang Terkumpul"),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah(0),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text("Uang Tersisa"),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah(sisa),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 12),

            /// RIWAYAT
            const Center(
              child: Text(
                "Riwayat Tabungan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B6B5A),
                ),
              ),
            ),

            const SizedBox(height: 100), // placeholder kosong

            /// BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B6B5A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Tambah nominal",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}