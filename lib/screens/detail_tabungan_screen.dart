import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tabungan_model.dart';
import '../utils/format_rupiah.dart';
import '../widgets/edit_riwayat_dialog.dart';
import '../widgets/tambah_nominal_dialog.dart';
import 'edit_tabungan_screen.dart';

class DetailTabunganScreen extends StatefulWidget {
  final Tabungan item;

  const DetailTabunganScreen({super.key, required this.item});

  @override
  State<DetailTabunganScreen> createState() => _DetailTabunganScreenState();
}

class _DetailTabunganScreenState extends State<DetailTabunganScreen> {
  // Save Data
  Future<void> _saveToPrefs({String? oldNama}) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('data_tabungan');

    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      List<Tabungan> list = jsonList
          .map((item) => Tabungan.fromJson(item))
          .toList();

      String searchNama = oldNama ?? widget.item.nama;
      int index = list.indexWhere((t) => t.nama == searchNama);

      if (index != -1) {
        list[index] = widget.item;
        String updatedJson = jsonEncode(
          list.map((item) => item.toJson()).toList(),
        );
        await prefs.setString('data_tabungan', updatedJson);
      }
    }
  }

  // Hitung Estimasi Selesai
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

  // Dialog Tambah Nominal
  void showTambahNominal(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => TambahNominalDialog(item: widget.item),
    );

    if (result != null) {
      int nominalFinal = result['nominal'];
      String catatan = result['catatan'];

      DateTime now = DateTime.now();
      String formattedDate =
          "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString().substring(2)}";

      setState(() {
        widget.item.terkumpul += nominalFinal;
        widget.item.riwayat.insert(0, {
          "nominal": nominalFinal,
          "catatan": catatan,
          "tanggal": formattedDate,
        });
      });

      _saveToPrefs();
    }
  }

  // Dialog Edit Riwayat
  void showEditRiwayat(BuildContext context, int index) async {
    final data = widget.item.riwayat[index];

    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditRiwayatDialog(
        data: data,
        riwayatFull: widget.item.riwayat,
      ),
    );

    if (result != null) {
      int nominalFinal = result['nominal'];
      String catatan = result['catatan'];
      int nominalLama = data['nominal'] as int;
      int selisih = nominalFinal - nominalLama;

      setState(() {
        widget.item.terkumpul += selisih;
        data['nominal'] = nominalFinal;
        data['catatan'] = catatan;
      });

      _saveToPrefs();
    }
  }

  // Dialog Preview Riwayat
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
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Nominal: ${formatRupiah(data['nominal'])}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: const Text("Hapus Riwayat Nominal?"),
                                content: Text(
                                  "Apakah Anda yakin ingin menghapus riwayat nominal ${(data['nominal'] as int) >= 0 ? "+${formatRupiah(data['nominal'])}" : "-${formatRupiah((data['nominal'] as int).abs())}"}?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    child: const Text(
                                      "Batal",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                      setState(() {
                                        widget.item.terkumpul -=
                                            (data['nominal'] as int);
                                        widget.item.riwayat.removeAt(index);
                                      });
                                      _saveToPrefs();
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Hapus",
                                      style: TextStyle(
                                        color: Color(0xFFD35D5D),
                                        fontWeight: FontWeight.w600,
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
                          style: TextStyle(color: Color(0xFFD35D5D)),
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
                icon: const Icon(Ionicons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
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

      // App Bar (Tombol Back, Edit & Hapus)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Color(0xff333333)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _buildAppBarButton(
            "Edit",
            Ionicons.pencil,
            const Color(0xFF1B6B5A),
            () async {
              String oldNama = widget.item.nama;
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

                await _saveToPrefs(oldNama: oldNama);
              }
            },
          ),
          const SizedBox(width: 8),
          _buildAppBarButton(
            "Hapus",
            Ionicons.trash,
            const Color(0xFFD35D5D),
            () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: const Text(
                      "Hapus Tabungan Ini?",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    content: Text(
                      "Apakah Anda yakin ingin menghapus tabungan '${widget.item.nama}'?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context, "delete");
                        },
                        child: const Text(
                          "Hapus",
                          style: TextStyle(
                            color: Color(0xFFD35D5D),
                            fontWeight: FontWeight.w600,
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
            // Nama Tabungan
            Text(
              widget.item.nama,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),

            // Foto Tabungan
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
                    child: const Icon(Ionicons.help),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Target & Progress Persentase
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
                        fontWeight: FontWeight.w600,
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
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tanggal Dibuat & Perkiraan Selesai
            Column(
              children: [
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
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
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
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Card Ringkasan (Terkumpul vs Tersisa)
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

            // Section Riwayat Tabungan
            const Center(
              child: Text(
                "Riwayat Nominal Tabungan",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF1B6B5A),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List Riwayat
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
                      String catatan = (data['catatan'] ?? '')
                          .toString()
                          .trim();
                      bool hasCatatan = catatan.isNotEmpty;

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => showPreviewRiwayat(context, index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          constraints: const BoxConstraints(minHeight: 62),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: hasCatatan
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      nominalRiwayat >= 0
                                          ? "+${formatRupiah(nominalRiwayat)}"
                                          : "-${formatRupiah(nominalRiwayat.abs())}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: nominalRiwayat >= 0
                                            ? const Color(0xFF1B6B5A)
                                            : const Color(0xFFD35D5D),
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (hasCatatan) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        catatan,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: hasCatatan ? 2.0 : 0.0,
                                ),
                                child: Text(
                                  data['tanggal'],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
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

      // Tombol Floating Tambah Nominal
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTambahNominal(context),
        backgroundColor: const Color(0xFF1B6B5A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Ionicons.add, color: Colors.white),
        label: const Text(
          "TAMBAH NOMINAL",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Helper Widget Appbar Button
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

  // Helper Widget Card Ringkasan
  Widget _buildSummaryItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}