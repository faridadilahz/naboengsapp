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
  
  // LOGIKA PROSES (Bisa nambah / ngurang)
  void _prosesTransaksi(String nominalRaw, String catatan, bool isTambah) {
    try {
      String cleanNominal = nominalRaw.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanNominal.isEmpty) return;

      int nominal = int.parse(cleanNominal);
      // Kalau pilih kurangi, nominal dipaksa jadi negatif
      int nominalFinal = isTambah ? nominal : -nominal;

      DateTime now = DateTime.now();
      String formattedDate = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString().substring(2)}";

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

  // 1. DIALOG TAMBAH NOMINAL (LOGIKA PLUS MINUS)
  void showTambahNominal(BuildContext context) {
    final TextEditingController nominalController = TextEditingController();
    final TextEditingController catatanController = TextEditingController();
    bool isTambah = true; // State awal: Tambah

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // WAJIB ada biar tombol bisa ganti warna pas diklik
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Tambah Nominal Tabungan",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B6B5A)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // TOMBOL PILIHAN TAMBAH / KURANGI (Toggle UI)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => isTambah = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isTambah ? const Color(0xFF1B6B5A) : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: const Color(0xFF1B6B5A)),
                              ),
                              child: Center(
                                child: Text("+ Tambah", style: TextStyle(color: isTambah ? Colors.white : const Color((0xFF1B6B5A)), fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => isTambah = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isTambah ? const Color(0xFFD35D5D) : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: const Color(0xFFD35D5D)),
                              ),
                              child: Center(
                                child: Text("- Kurangi", style: TextStyle(color: !isTambah ? Colors.white : const Color(0xFFD35D5D), fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    const Text("Nominal tabungan", style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nominalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, RupiahFormatter()],
                      decoration: InputDecoration(
                        hintText: "Masukkan Nominal",
                        filled: true,
                        fillColor: const Color(0xfff5f5f5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    const Text("Catatan (Opsional)", style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: catatanController,
                      decoration: InputDecoration(
                        hintText: "Catatan",
                        filled: true,
                        fillColor: const Color(0xfff5f5f5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD35D5D),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Batal"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (nominalController.text.isNotEmpty) {
                                _prosesTransaksi(nominalController.text, catatanController.text, isTambah);
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B6B5A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Tambah"),
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
                  const Text("Detail Tabungan", style: TextStyle(color: Color(0xFF1B6B5A), fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  Text("Nominal: ${formatRupiah(data['nominal'])}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: (data['nominal'] as int) < 0 ? Colors.red : const Color(0xFF1B6B5A))),
                  const SizedBox(height: 8),
                  Text("Catatan: ${data['catatan']}", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text("Tanggal: ${data['tanggal']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showEditRiwayat(context, index); 
                        },
                        child: const Text("Edit", style: TextStyle(color: Color(0xFF1B6B5A))),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            widget.item.terkumpul -= (data['nominal'] as int);
                            widget.item.riwayat.removeAt(index);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Hapus", style: TextStyle(color: Colors.red)),
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

  // 3. DIALOG EDIT RIWAYAT
  void showEditRiwayat(BuildContext context, int index) {
    final data = widget.item.riwayat[index];
    int nominalAsli = (data['nominal'] as int).abs();
    bool isTambah = (data['nominal'] as int) >= 0;
    
    final TextEditingController nominalController = TextEditingController(text: nominalAsli.toString());
    final TextEditingController catatanController = TextEditingController(text: data['catatan']);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text("Edit Riwayat Tabungan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B6B5A))),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => isTambah = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isTambah ? const Color(0xFF1B6B5A) : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: const Color(0xFF1B6B5A)),
                            ),
                            child: Center(
                              child: Text("+ Tambah", style: TextStyle(color: isTambah ? Colors.white : const Color(0xFF1B6B5A), fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => isTambah = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !isTambah ? const Color(0xFFD35D5D) : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: const Color(0xFFD35D5D)),
                            ),
                            child: Center(
                              child: Text("- Kurangi", style: TextStyle(color: !isTambah ? Colors.white : const Color(0xFFD35D5D), fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Nominal tabungan"),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nominalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, RupiahFormatter()],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xfff5f5f5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Catatan"),
                  const SizedBox(height: 6),
                  TextField(
                    controller: catatanController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xfff5f5f5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
  children: [
    Expanded(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          showPreviewRiwayat(context, index);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD35D5D),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0, // Biar clean kayak di gambar
        ),
        child: const Text("Batal"),
      ),
    ),
    
    // NAH, INI KUNCINYA CUI, KASIH JARAK DI SINI
    const SizedBox(width: 12), 
    
    Expanded(
      child: ElevatedButton(
        onPressed: () {
          if (nominalController.text.isEmpty) return;
          int nominalLama = data['nominal'];
          int nominalInput = int.parse(nominalController.text.replaceAll(RegExp(r'[^0-9]'), ''));
          int nominalBaru = isTambah ? nominalInput : -nominalInput;

          setState(() {
            widget.item.terkumpul = (widget.item.terkumpul - nominalLama) + nominalBaru;
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text("Simpan"),
      ),
    ),
  ],
)
                ],
              ),
            ),
          );
        }
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
          _buildAppBarButton("Edit", Icons.edit_note, const Color(0xFF1B6B5A), () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditTabunganScreen(item: widget.item)));
            if (result != null && result is Tabungan) {
              setState(() {
                widget.item.nama = result.nama;
                widget.item.target = result.target;
                widget.item.perHari = result.perHari;
                widget.item.tipe = result.tipe;
                widget.item.imagePath = result.imagePath;
              });
            }
          }),
          const SizedBox(width: 8),
          _buildAppBarButton("Hapus", Icons.delete_outline, const Color(0xFFD35D5D), () {
             Navigator.pop(context, "delete");
          }),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.item.nama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B6B5A))),
            const SizedBox(height: 12),
            if (widget.item.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(widget.item.imagePath!), height: 160, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(height: 160, color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatRupiah(widget.item.target), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B6B5A))),
                    Text("${formatRupiah(widget.item.perHari)}/${widget.item.tipe}", style: const TextStyle(color: Color(0xff777777))),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(height: 50, width: 50, child: CircularProgressIndicator(value: persen, strokeWidth: 4, backgroundColor: Colors.grey.shade200, color: const Color(0xFF1B6B5A))),
                    Text("$persenDisplay%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem("Uang Terkumpul", formatRupiah(uangTerkumpul), const Color(0xFF1B6B5A)),
                _buildSummaryItem("Uang Tersisa", formatRupiah(sisa < 0 ? 0 : sisa), const Color(0xFFD35D5D)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Center(child: Text("Riwayat Tabungan", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B6B5A)))),
            const SizedBox(height: 16),
            
            widget.item.riwayat.isEmpty 
              ? const Center(child: Text("Belum ada riwayat", style: TextStyle(color: Colors.grey)))
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
                                  nominalRiwayat >= 0 ? "+${formatRupiah(nominalRiwayat)}" : formatRupiah(nominalRiwayat), 
                                  style: TextStyle(fontWeight: FontWeight.bold, color: nominalRiwayat >= 0 ? const Color(0xFF1B6B5A) : Colors.red, fontSize: 16)
                                ),
                                Text(data['catatan'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                            Text(data['tanggal'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
        label: const Text("Tambah nominal", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAppBarButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: onTap, 
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}