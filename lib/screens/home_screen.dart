import 'package:flutter/material.dart';
import '../screens/add_tabungan_screen.dart';
import '../models/tabungan_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ionicons/ionicons.dart';
import '../widgets/tabungan_list_view.dart';
import '../widgets/tab_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Tabungan> tabunganList = [];
  int selectedTab = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedTab);
    _loadDataTabungan();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleItemUpdate(Tabungan item, String action) {
    if (action == "delete") {
      setState(() {
        tabunganList.remove(item);
      });
      _saveDataTabungan();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tabungan '${item.nama}' berhasil dihapus!"),
          backgroundColor: const Color(0xFFD35D5D),
        ),
      );
    } else {
      setState(() {});
      _saveDataTabungan();
    }
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

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }

      await _saveDataTabungan();
    }
  }

  Future<void> _saveDataTabungan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List jsonList = tabunganList.map((item) => item.toJson()).toList();
    String jsonString = jsonEncode(jsonList);
    await prefs.setString('data_tabungan', jsonString);
  }

  @override
  Widget build(BuildContext context) {
    List<Tabungan> dalamProsesList = [];
    List<Tabungan> tercapaiList = [];

    for (var item in tabunganList) {
      item.isDone = item.terkumpul >= item.target;
      if (item.isDone) {
        tercapaiList.add(item);
      } else {
        dalamProsesList.add(item);
      }
    }

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
              style: TextStyle(fontSize: 16, color: Color(0xFFDDDDDD)),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⚡ 2. BUNGKUS HEADER & TAB BAR DENGAN PADDING SENDIRI ⚡
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedTabBar(
                  selectedIndex: selectedTab,
                  onTabChanged: (index) {
                    setState(() {
                      selectedTab = index;
                    });
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
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
              ],
            ),
          ),

          // ⚡ 3. PAGEVIEW SEKARANG MEMENUHI SELEBAR LAYAR (FULL BLEED) ⚡
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  selectedTab = index;
                });
              },
              children: [
                TabunganListView(
                  items: dalamProsesList,
                  selectedTab: 0,
                  onAddPressed: _bukaFormTambahTabungan,
                  onItemUpdated: (item, action) =>
                      _handleItemUpdate(item, action),
                ),
                TabunganListView(
                  items: tercapaiList,
                  selectedTab: 1,
                  onAddPressed: _bukaFormTambahTabungan,
                  onItemUpdated: (item, action) =>
                      _handleItemUpdate(item, action),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: (dalamProsesList.isEmpty || selectedTab != 0)
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
