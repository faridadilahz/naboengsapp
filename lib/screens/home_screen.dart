import 'package:flutter/material.dart';
import '../widgets/empty_state.dart';
import 'package:ionicons/ionicons.dart';
import '../screens/add_tabungan_screen.dart';
import '../models/tabungan_model.dart';
import 'dart:io';
import '../utils/format_rupiah.dart';
import '../screens/detail_tabungan_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Deklarasi variabel
  List<Tabungan> tabunganList = [];
  int selectedTab = 0;

  // --- TAMBAHAN BARU: Fungsi Load & Save Data ---
  
  @override
  void initState() {
    super.initState();
    _loadDataTabungan(); // Panggil data pas aplikasi dibuka
  }

  Future<void> _loadDataTabungan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('data_tabungan');

    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      setState(() {
        tabunganList = jsonList.map((item) => Tabungan.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveDataTabungan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = tabunganList.map((item) => item.toJson()).toList();
    String jsonString = jsonEncode(jsonList);
    await prefs.setString('data_tabungan', jsonString);
  }
  // ---------------------------------------------

  String _hitungSisaHari(Tabungan item) {
    int sisaUang = item.target - item.terkumpul;
    if (sisaUang <= 0) return "Selesai hari ini";
    int sisaHari = (sisaUang / item.perHari).ceil();
    return "$sisaHari hari lagi";
  }

  @override
  Widget build(BuildContext context) {
    // 2. Logika filter
    List<Tabungan> filteredList = tabunganList.where((item) {
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
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailTabunganScreen(item: item),
                              ),
                            );

                            if (result == "delete") {
                              setState(() {
                                tabunganList.remove(item);
                              });
                              
                              _saveDataTabungan(); // <-- Simpan setelah dihapus

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Tabungan '${item.nama}' berhasil dihapus!",
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            } else {
                              setState(() {});
                              _saveDataTabungan(); // <-- Simpan perubahan apapun (nambah nominal/edit tabungan)
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
              
              _saveDataTabungan(); // <-- Simpan setelah bikin tabungan baru
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