import 'package:flutter/material.dart';
import '../screens/add_tabungan_screen.dart';
import '../models/tabungan_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ionicons/ionicons.dart';
import '../widgets/tabungan_list_view.dart';
import '../widgets/tab_bar.dart';
import '../widgets/input_nama.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Tabungan> tabunganList = [];
  int selectedTab = 0;
  late PageController _pageController;
  String namaPengguna = "";
  String sapaanHarian = "Nabung berapa hari ini?";

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedTab);
    _generateSapaan();
    _loadDataTabungan();
    _loadNamaPengguna();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _generateSapaan() {
    final jam = DateTime.now().hour;
    final random = Random();

    List<String> daftarSapaan;

    if (jam >= 4 && jam < 11) {
      daftarSapaan = [
        "Selamat pagi! Awali hari dengan nabung yuk.",
        "Pagi yang cerah buat selangkah lebih dekat ke target!",
        "Semangat pagi! Mau sisihin berapa hari ini?",
        "Ngopi dulu, habis itu jangan lupa nabung ya!",
      ];
    } else if (jam >= 11 && jam < 15) {
      daftarSapaan = [
        "Selamat siang! Tetap konsisten kejar impianmu.",
        "Siang-siang gini paling pas cek progres tabungan.",
        "Jangan lupa sisihin receh siang ini ya!",
        "Semangat terus, dikit-dikit lama-lama jadi bukit!",
      ];
    } else if (jam >= 15 && jam < 18) {
      daftarSapaan = [
        "Selamat sore! Gimana progres nabungmu hari ini?",
        "Sore santai, waktunya cek target tabungan!",
        "Ada sisa uang jajan hari ini? Yuk masukin tabungan!",
        "Sore-sore gini enak nih liat saldo makin nambah.",
      ];
    } else {
      daftarSapaan = [
        "Selamat malam! Sudah nabung hari ini?",
        "Sebelum istirahat, yuk isi tabunganmu dulu.",
        "Malam! Satu langkah lagi menuju barang impianmu.",
        "Tutup harimu dengan nabung hari ini, yuk!",
      ];
    }

    sapaanHarian = daftarSapaan[random.nextInt(daftarSapaan.length)];
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

  Future<void> _loadNamaPengguna() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedName = prefs.getString('nama_pengguna');
    bool sudahDitanya = prefs.getBool('sudah_ditanya_nama') ?? false;

    if (savedName != null && savedName.trim().isNotEmpty) {
      setState(() {
        namaPengguna = savedName;
      });
    } else if (!sudahDitanya) {
      // Tandai sudah pernah ditanya agar tidak muncul berulang kali jika di-skip
      await prefs.setBool('sudah_ditanya_nama', true);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _bukaDialogEditNama(isFirstTime: true);
      });
    }
  }

  Future<void> _bukaDialogEditNama({bool isFirstTime = false}) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          InputNamaDialog(currentName: namaPengguna, isFirstTime: isFirstTime),
    );

    // Jika user menekan tombol Simpan (result tidak null, meskipun kosong)
    if (result != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('nama_pengguna', result);

      setState(() {
        namaPengguna = result;
      });
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
        flexibleSpace: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.36,
                child: Image.asset(
                  'assets/images/headerpattern.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _bukaDialogEditNama(isFirstTime: false),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      "Halo, ${namaPengguna.isEmpty ? 'Sobat' : namaPengguna}!",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Ionicons.pencil,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sapaanHarian,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, color: Color(0xFFDDDDDD)),
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
