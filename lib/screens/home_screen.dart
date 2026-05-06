import 'package:flutter/material.dart';
import '../widgets/empty_state.dart';
import 'package:ionicons/ionicons.dart';
import '../screens/add_tabungan_screen.dart';
import '../models/tabungan_model.dart';
import 'dart:io';
import '../utils/format_rupiah.dart';
import '../screens/detail_tabungan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _hitungSisaHari(Tabungan item) {
    // 1. Hitung sisa uang yang harus dikumpulkan
    int sisaUang = item.target - item.terkumpul;

    // 2. Kalau sudah lunas, langsung return selesai
    if (sisaUang <= 0) return "Selesai hari ini";

    // 3. Hitung berapa hari lagi berdasarkan nominal harian (perHari)
    // Misal: Sisa 100rb, nabung 20rb/hari = 5 hari lagi.
    int sisaHari = (sisaUang / item.perHari).ceil();

    return "$sisaHari hari lagi";
  }

  // 1. Deklarasi variabel harus di sini (di dalam State, di luar build)
  List<Tabungan> tabunganList = [];
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    // 2. Logika filter harus di DALAM fungsi build sebelum return Scaffold
    List<Tabungan> filteredList = tabunganList.where((item) {
      // Cek otomatis: kalau duit pas/lebih, status jadi true
      if (item.terkumpul >= item.target) {
        item.isDone = true;
      } else {
        item.isDone = false;
      }

      if (selectedTab == 0) {
        return item.isDone == false;
      } else {
        return item.isDone == true;
      }
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffFDFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B6B5A),
        elevation: 0,
        toolbarHeight: 96,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Halo, Farid!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Nabung berapa hari ini?",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Center(
                        child: Text(
                          "Dalam Proses",
                          style: TextStyle(
                            color: selectedTab == 0
                                ? const Color(0xFF1B6B5A)
                                : const Color(0xffaaaaaa),
                            fontSize: 16,
                            fontWeight: selectedTab == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTab = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Center(
                        child: Text(
                          "Tercapai",
                          style: TextStyle(
                            color: selectedTab == 1
                                ? const Color(0xFF1B6B5A)
                                : const Color(0xffaaaaaa),
                            fontSize: 16,
                            fontWeight: selectedTab == 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Tabunganmu",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xff777777),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: tabunganList.isEmpty
                  ? const EmptyState()
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];

                        return GestureDetector(
                          onTap: () async {
                            // Tambahkan async di sini
                            // 1. Ambil result dari DetailTabunganScreen
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailTabunganScreen(item: item),
                              ),
                            );

                            // 2. Cek kalau result-nya adalah "delete"
                            if (result == "delete") {
                              setState(() {
                                // Kita hapus berdasarkan objek 'item',
                                // karena kalau pake 'index' takutnya salah hapus
                                // akibat data yang sudah di-filter (Tercapai vs Dalam Proses)
                                tabunganList.remove(item);
                              });

                              // 3. Notifikasi biar user tau udah kehapus
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Tabungan '${item.nama}' berhasil dihapus!",
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            } else {
                              // Ini logika lama lu, tetap dijaga buat update nominal/data
                              setState(() {});
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xffffffff),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xffeeeeee),
                                width: 0.7,
                              ),
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
                                Text(
                                  item.nama,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff222222),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatRupiah(item.target),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Color(0xFF555555),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // LOGIKA SWITCH UI CARD
                                    if (selectedTab == 1) ...[
                                      const Text(
                                        "Tercapai!",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B6B5A),
                                          fontStyle: FontStyle.italic,
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xff555555),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Divider(
                                          color: Color(0xffeeeeee),
                                          thickness: 1,
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          _hitungSisaHari(
                                            item,
                                          ), // Pastikan nama variabel di model sesuai
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
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 72,
        height: 72,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF1B6B5A),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTabunganScreen(),
              ),
            );

            if (result != null && result is Tabungan) {
              setState(() {
                tabunganList.insert(0, result);
              });
            }
          },
          child: const Icon(
            Ionicons.add_outline,
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
