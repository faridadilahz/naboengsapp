import 'dart:io';
import 'package:flutter/material.dart';
import '../models/tabungan_model.dart';
import 'package:flutter/services.dart';
import '../utils/format_rupiah.dart';
import '../utils/rupiah_formatter.dart';
import 'edit_tabungan_screen.dart';

class DetailTabunganScreen extends StatefulWidget {
  final Tabungan item;

  const DetailTabunganScreen({super.key, required this.item});

  @override
  State<DetailTabunganScreen> createState() => _DetailTabunganScreenState();
}

class _DetailTabunganScreenState extends State<DetailTabunganScreen> {
  String get estimasiSelesai {
    int sisaUang = widget.item.target - widget.item.terkumpul;
    if (sisaUang <= 0) return "Tercapai!";
    if (widget.item.perHari <= 0) return "-";

    int sisaHari = (sisaUang / widget.item.perHari).ceil();
    DateTime tglSelesai = DateTime.now().add(Duration(days: sisaHari));

    List<String> bulan = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    return "${tglSelesai.day} ${bulan[tglSelesai.month - 1]} ${tglSelesai.year}";
  }

  // LOGIKA PROSES (Bisa nambah / ngurang)
  void _prosesTransaksi(String nominalRaw, String catatan, bool isTambah) {
    try {
      String cleanNominal = nominalRaw.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanNominal.isEmpty) return;

      int nominal = int.parse(cleanNominal);
      // Kalau pilih kurangi, nominal dipaksa jadi negatif
      int nominalFinal = isTambah ? nominal : -nominal;

      DateTime now = DateTime.now();
      String formattedDate =
          "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString().substring(2)}";

      setState(() {
        widget.item.terkumpul += nominalFinal;
        widget.item.riwayat.insert(0, {
          "nominal": nominalFinal,
          "catatan": catatan.isEmpty ? (isTambah ? "-" : "-") : catatan,
          "tanggal": formattedDate,
        });
      });
    } catch (e) {
      debugPrint("Error saat proses transaksi: $e");
    }
  }

  // 1. DIALOG TAMBAH NOMINAL (UI POLISHED)
  void showTambahNominal(BuildContext context) {
    final TextEditingController nominalController = TextEditingController();
    final TextEditingController catatanController = TextEditingController();
    bool isTambah = true; // State awal: Tambah

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Radius lebih smooth
              ),
              child: Padding(
                padding: const EdgeInsets.all(24), // Spacing lebih lega
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Tambah Nominal Tabungan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1B6B5A),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // TOMBOL PILIHAN TAMBAH / KURANGI (Modern Soft Toggle)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => isTambah = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isTambah
                                    ? const Color(0xFF1B6B5A)
                                    : const Color(
                                        0xFFE8F1EF,
                                      ), // Soft green tint pas unselected
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "+ Tambah",
                                  style: TextStyle(
                                    color: isTambah
                                        ? Colors.white
                                        : const Color(0xFF1B6B5A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => isTambah = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isTambah
                                    ? const Color(0xFFD35D5D)
                                    : const Color(
                                        0xFFFAEBEB,
                                      ), // Soft red tint pas unselected
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "- Kurangi",
                                  style: TextStyle(
                                    color: !isTambah
                                        ? Colors.white
                                        : const Color(0xFFD35D5D),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
                      "Nominal Tabungan",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nominalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        RupiahFormatter(),
                      ],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: "Masukkan Nominal",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        prefixIcon: const Icon(
                          Icons.payments_outlined,
                          color: Color(0xFF1B6B5A),
                          size: 22,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1B6B5A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      "Catatan (Opsional)",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: catatanController,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: "Contoh: Uang jajan, Sisa gajian",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        prefixIcon: const Icon(
                          Icons.sticky_note_2_outlined,
                          color: Colors.grey,
                          size: 22,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1B6B5A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFD35D5D),
                              minimumSize: const Size(double.infinity, 48),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFFD35D5D),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const Text(
                              "Batal",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (nominalController.text.isNotEmpty) {
                                _prosesTransaksi(
                                  nominalController.text,
                                  catatanController.text,
                                  isTambah,
                                );
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B6B5A),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Tambah",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 2. DIALOG PREVIEW RIWAYAT
  void showPreviewRiwayat(BuildContext context, int index) {
    final data = widget.item.riwayat[index];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Detail Tabungan",
                    style: TextStyle(
                      color: Color(0xFF1B6B5A),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Nominal: ${formatRupiah(data['nominal'])}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: (data['nominal'] as int) < 0
                          ? const Color(0xFFD35D5D)
                          : const Color(0xFF1B6B5A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Catatan: ${data['catatan']}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tanggal: ${data['tanggal']}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showEditRiwayat(context, index);
                        },
                        child: const Text(
                          "Edit",
                          style: TextStyle(color: Color(0xFF1B6B5A)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Tampilkan dialog konfirmasi sebelum hapus riwayat
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: const Text("Hapus Riwayat?"),
                                content: Text(
                                  "Apakah Anda yakin ingin menghapus riwayat nominal ${(data['nominal'] as int) >= 0 ? "+${formatRupiah(data['nominal'])}" : "-${formatRupiah((data['nominal'] as int).abs())}"}?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(
                                      dialogContext,
                                    ), // Tutup dialog konfirmasi aja
                                    child: const Text(
                                      "Batal",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // 1. Tutup dialog konfirmasi
                                      Navigator.pop(dialogContext);

                                      // 2. Jalankan logika penghapusan
                                      setState(() {
                                        widget.item.terkumpul -=
                                            (data['nominal'] as int);
                                        widget.item.riwayat.removeAt(index);
                                      });

                                      // 3. Tutup dialog preview riwayat
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Hapus",
                                      style: TextStyle(
                                        color: Color(0xFFD35D5D),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(
                          "Hapus",
                          style: TextStyle(
                            color: Color(0xFFD35D5D),
                          ), // Warna disamain biar konsisten
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. DIALOG EDIT RIWAYAT (UI POLISHED)
  void showEditRiwayat(BuildContext context, int index) {
    final data = widget.item.riwayat[index];
    int nominalAsli = (data['nominal'] as int).abs();
    bool isTambah = (data['nominal'] as int) >= 0;

    final TextEditingController nominalController = TextEditingController(
      text: nominalAsli.toString(),
    );
    final TextEditingController catatanController = TextEditingController(
      text: data['catatan'],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Edit Riwayat Tabungan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1B6B5A),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TOMBOL PILIHAN TAMBAH / KURANGI (Modern Soft Toggle)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => isTambah = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isTambah
                                  ? const Color(0xFF1B6B5A)
                                  : const Color(0xFFE8F1EF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                "+ Tambah",
                                style: TextStyle(
                                  color: isTambah
                                      ? Colors.white
                                      : const Color(0xFF1B6B5A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => isTambah = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isTambah
                                  ? const Color(0xFFD35D5D)
                                  : const Color(0xFFFAEBEB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                "- Kurangi",
                                style: TextStyle(
                                  color: !isTambah
                                      ? Colors.white
                                      : const Color(0xFFD35D5D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
                    "Nominal Tabungan",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nominalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      RupiahFormatter(),
                    ],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      prefixIcon: const Icon(
                        Icons.payments_outlined,
                        color: Color(0xFF1B6B5A),
                        size: 22,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1B6B5A),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Catatan",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: catatanController,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      prefixIcon: const Icon(
                        Icons.sticky_note_2_outlined,
                        color: Colors.grey,
                        size: 22,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1B6B5A),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            showPreviewRiwayat(context, index);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFD35D5D),
                            minimumSize: const Size(double.infinity, 48),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Color(0xFFD35D5D),
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (nominalController.text.isEmpty) return;
                            int nominalLama = data['nominal'];
                            int nominalInput = int.parse(
                              nominalController.text.replaceAll(
                                RegExp(r'[^0-9]'),
                                '',
                              ),
                            );
                            int nominalBaru = isTambah
                                ? nominalInput
                                : -nominalInput;

                            setState(() {
                              widget.item.terkumpul =
                                  (widget.item.terkumpul - nominalLama) +
                                  nominalBaru;
                              widget.item.riwayat[index] = {
                                "nominal": nominalBaru,
                                "catatan": catatanController.text,
                                "tanggal": data['tanggal'],
                              };
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B6B5A),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Simpan",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int uangTerkumpul = widget.item.terkumpul;
    int sisa = widget.item.target - uangTerkumpul;
    double persen = (uangTerkumpul / widget.item.target).clamp(0.0, 1.0);
    int persenDisplay = (persen * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          _buildAppBarButton(
            "Edit",
            Icons.edit_note,
            const Color(0xFF1B6B5A),
            () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTabunganScreen(item: widget.item),
                ),
              );
              if (result != null && result is Tabungan) {
                setState(() {
                  widget.item.nama = result.nama;
                  widget.item.target = result.target;
                  widget.item.perHari = result.perHari;
                  widget.item.tipe = result.tipe;
                  widget.item.imagePath = result.imagePath;
                });
              }
            },
          ),
          const SizedBox(width: 8),
          _buildAppBarButton(
            "Hapus",
            Icons.delete_outline,
            const Color(0xFFD35D5D),
            () {
              // Tampilkan dialog konfirmasi sebelum hapus
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: const Text("Hapus Tabungan?"),
                    content: Text(
                      "Apakah Anda yakin ingin menghapus tabungan '${widget.item.nama}'?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context), // Tutup dialog doang
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Tutup dialog
                          Navigator.pop(
                            context,
                            "delete",
                          ); // Balik ke Home sambil kirim perintah delete
                        },
                        child: const Text(
                          "Hapus",
                          style: TextStyle(
                            color: Color(0xFFD35D5D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.nama,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B6B5A),
              ),
            ),
            const SizedBox(height: 12),
            if (widget.item.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.item.imagePath!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatRupiah(widget.item.target),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B6B5A),
                      ),
                    ),
                    Text(
                      "${formatRupiah(widget.item.perHari)}/${widget.item.tipe}",
                      style: const TextStyle(color: Color(0xff777777)),
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        value: persen,
                        strokeWidth: 4,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color(0xFF1B6B5A),
                      ),
                    ),
                    Text(
                      "$persenDisplay%",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                // Baris Tanggal Dibuat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tanggal dibuat",
                      style: TextStyle(color: Color(0xffaaaaaa), fontSize: 15),
                    ),
                    Text(
                      "${widget.item.tanggalDibuat.day} ${["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"][widget.item.tanggalDibuat.month - 1]} ${widget.item.tanggalDibuat.year}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
                // Baris Perkiraan Selesai
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Perkiraan selesai",
                      style: TextStyle(color: Color(0xffaaaaaa), fontSize: 16),
                    ),
                    Text(
                      estimasiSelesai,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  "Uang Terkumpul",
                  formatRupiah(uangTerkumpul),
                  const Color(0xFF1B6B5A),
                ),
                _buildSummaryItem(
                  "Uang Tersisa",
                  formatRupiah(sisa < 0 ? 0 : sisa),
                  const Color(0xFFD35D5D),
                ),
              ],
            ),
            const SizedBox(height: 8),

            const Divider(color: Color(0xffeeeeee), thickness: 0.7, height: 32),

            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Riwayat Tabungan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1B6B5A),
                ),
              ),
            ),
            const SizedBox(height: 16),

            widget.item.riwayat.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada riwayat",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.item.riwayat.length,
                    itemBuilder: (context, index) {
                      final data = widget.item.riwayat[index];
                      int nominalRiwayat = data['nominal'];
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => showPreviewRiwayat(context, index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nominalRiwayat >= 0
                                        ? "+${formatRupiah(nominalRiwayat)}"
                                        : "-${formatRupiah(nominalRiwayat.abs())}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: nominalRiwayat >= 0
                                          ? const Color(0xFF1B6B5A)
                                          : const Color(0xFFD35D5D),
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    data['catatan'],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                data['tanggal'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTambahNominal(context),
        backgroundColor: const Color(0xFF1B6B5A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        icon: const Icon(Icons.edit_note, color: Colors.white),
        label: const Text(
          "Tambah nominal",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAppBarButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
