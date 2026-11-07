import 'package:flutter/material.dart';
import '../widgets/empty_state.dart';
import '../screens/add_tabungan_screen.dart';
import '../models/tabungan_model.dart';
import 'dart:io';
import '../utils/format_rupiah.dart';
import '../screens/detail_tabungan_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ionicons/ionicons.dart';
import '../widgets/tabungan_card.dart';
import '../widgets/tab_bar.dart';

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

  Future<void> _bukaFormTambahTabungan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTabunganScreen()),
    );

    if (result != null && result is Tabungan) {
      setState(() {
        tabunganList.insert(0, result);
        selectedTab = 0;
      });

      _saveDataTabungan();
    }
  }

  Future<void> _saveDataTabungan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = tabunganList
        .map((item) => item.toJson())
        .toList();
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
                fontWeight: FontWeight.w800,
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
            SegmentedTabBar(
              selectedIndex: selectedTab,
              onTabChanged: (index) {
                setState(() {
                  selectedTab = index;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "Tabunganmu",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xff777777),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: tabunganList.isEmpty
                  ? EmptyState(onAddPressed: _bukaFormTambahTabungan)
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];

                        return TabunganCard(
                          item: item,
                          selectedTab: selectedTab,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailTabunganScreen(item: item),
                              ),
                            );

                            if (result == "delete") {
                              setState(() {
                                tabunganList.remove(item);
                              });

                              _saveDataTabungan();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Tabungan '${item.nama}' berhasil dihapus!",
                                  ),
                                  backgroundColor: const Color(0xFFD35D5D),
                                ),
                              );
                            } else {
                              setState(() {});
                              _saveDataTabungan();
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: (tabunganList.isEmpty || selectedTab != 0)
            ? const SizedBox.shrink()
            : SizedBox(
                key: const ValueKey('fab_tambah_tabungan'),
                width: 72,
                height: 72,
                child: FloatingActionButton(
                  elevation: 0,
                  focusElevation: 0,
                  hoverElevation: 0,
                  highlightElevation: 0,
                  backgroundColor: const Color(0xFF1B6B5A),
                  onPressed: _bukaFormTambahTabungan,
                  child: const Icon(
                    Ionicons.add,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }
}
