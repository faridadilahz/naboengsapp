import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:naboengs/utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tabungan_model.dart';
import '../utils/format_rupiah.dart';
import '../widgets/edit_riwayat_dialog.dart';
import '../widgets/tambah_nominal_dialog.dart';
import 'edit_tabungan_screen.dart';
import '../widgets/preview_riwayat_dialog.dart';
import '../widgets/celebration_dialog.dart';

class DetailTabunganScreen extends StatefulWidget {
  final Tabungan item;

  const DetailTabunganScreen({super.key, required this.item});

  @override
  State<DetailTabunganScreen> createState() => _DetailTabunganScreenState();
}

class _DetailTabunganScreenState extends State<DetailTabunganScreen> {
  // Format Tanggal di Detail Nominal
  String _formatTanggalDibuat(String tanggalRaw) {
    try {
      List<String> parts = tanggalRaw.split('/');
      if (parts.length != 3) return tanggalRaw;

      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      if (year < 100) {
        year += 2000;
      }

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

      return "$day ${bulan[month - 1]} $year";
    } catch (e) {
      return tanggalRaw;
    }
  }

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

  // Dialog Konfirmasi Hapus Riwayat
  void _konfirmasiHapusRiwayat(
    BuildContext context,
    int index,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Hapus Riwayat Ini?",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus nominal ${formatRupiah(data['nominal'])}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "Batal",
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);

                setState(() {
                  widget.item.riwayat.removeAt(index);

                  // Recalculate saldo terkumpul
                  int totalMurni = _totalSaldoRiwayat;
                  widget.item.terkumpul = totalMurni < 0 ? 0 : totalMurni;
                });

                _saveToPrefs();
              },
              child: const Text(
                "Hapus",
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Hitung Estimasi Selesai
  String get estimasiSelesai {
    int sisaUang = widget.item.target - widget.item.terkumpul;
    if (sisaUang <= 0) return "Tercapai!";
    if (widget.item.perHari <= 0) return "-";

    int sisaPeriode = (sisaUang / widget.item.perHari).ceil();

    // ⚡ CAP SISA PERIODE BIAR GAK OVERFLOW ⚡
    if (sisaPeriode > 36500) return "Lebih dari 100 tahun";

    DateTime now = DateTime.now();
    DateTime tglSelesai;

    try {
      String tipeLower = widget.item.tipe.toLowerCase();
      if (tipeLower.contains('minggu')) {
        tglSelesai = now.add(Duration(days: sisaPeriode * 7));
      } else if (tipeLower.contains('bulan')) {
        tglSelesai = DateTime(now.year, now.month + sisaPeriode, now.day);
      } else {
        tglSelesai = now.add(Duration(days: sisaPeriode));
      }
    } catch (e) {
      return "Lebih dari 100 tahun";
    }

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

  // Helper Murni Hitung Saldo dari Seluruh Riwayat
  int get _totalSaldoRiwayat {
    int total = 0;
    for (var r in widget.item.riwayat) {
      total += (r['nominal'] as int);
    }
    return total;
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

      bool statusSebelumnya = widget.item.terkumpul >= widget.item.target;

      setState(() {
        widget.item.riwayat.insert(0, {
          "nominal": nominalFinal,
          "catatan": catatan,
          "tanggal": formattedDate,
        });

        // Update item.terkumpul berdasar total riwayat murni
        int totalMurni = _totalSaldoRiwayat;
        widget.item.terkumpul = totalMurni < 0 ? 0 : totalMurni;
      });

      _saveToPrefs();

      bool statusSekarang = widget.item.terkumpul >= widget.item.target;
      if (!statusSebelumnya && statusSekarang) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => SelebrasiTercapaiDialog(item: widget.item),
          );
        }
      }
    }
  }

  // Dialog Edit Riwayat
  void showEditRiwayat(BuildContext context, int index) async {
    final data = widget.item.riwayat[index];

    final result = await showDialog(
      context: context,
      builder: (context) =>
          EditRiwayatDialog(data: data, riwayatFull: widget.item.riwayat),
    );

    if (result != null) {
      int nominalFinal = result['nominal'];
      String catatan = result['catatan'];

      setState(() {
        data['nominal'] = nominalFinal;
        data['catatan'] = catatan;

        int totalMurni = _totalSaldoRiwayat;
        widget.item.terkumpul = totalMurni < 0 ? 0 : totalMurni;
      });

      _saveToPrefs();
    }
  }

  // Dialog Preview Riwayat
  void showPreviewRiwayat(BuildContext context, int index) {
    final data = widget.item.riwayat[index];

    showDialog(
      context: context,
      builder: (context) => PreviewRiwayatDialog(
        data: data,
        formatTanggal: _formatTanggalDibuat,
        onEdit: () => showEditRiwayat(context, index),
        onDelete: () => _konfirmasiHapusRiwayat(context, index, data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalSaldoMurni = _totalSaldoRiwayat;

    int uangTerkumpul = totalSaldoMurni < 0 ? 0 : totalSaldoMurni;

    int sisa = widget.item.target - totalSaldoMurni;

    double persen = (uangTerkumpul / widget.item.target).clamp(0.0, 1.0);
    int persenDisplay = (persen * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,

      // App Bar (Tombol Back, Edit & Hapus)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _buildAppBarButton(
            "Edit",
            Ionicons.pencil,
            AppColors.primary,
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
          _buildAppBarButton("Hapus", Ionicons.trash, AppColors.danger, () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                          color: AppColors.textMuted,
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
                          color: AppColors.danger,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }),
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
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Foto Tabungan
            if (widget.item.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(widget.item.imagePath!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    color: AppColors.grey,
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
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      "${formatRupiah(widget.item.perHari)}/${widget.item.tipe}",
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: AppColors.textMuted),
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
                        backgroundColor: AppColors.grey,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      "$persenDisplay%",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
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
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "${widget.item.tanggalDibuat.day} ${["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"][widget.item.tanggalDibuat.month - 1]} ${widget.item.tanggalDibuat.year}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Perkiraan selesai",
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      estimasiSelesai,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
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
                  AppColors.primary,
                ),
                _buildSummaryItem(
                  "Uang Tersisa",
                  formatRupiah(sisa),
                  AppColors.danger,
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Divider(color: AppColors.grey, thickness: 0.7, height: 32),
            const SizedBox(height: 8),

            // Section Riwayat Tabungan
            const Center(
              child: Text(
                "Riwayat Nominal Tabungan",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List Riwayat
            widget.item.riwayat.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada riwayat nominal",
                      style: TextStyle(color: AppColors.textMuted),
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
                          constraints: const BoxConstraints(minHeight: 56),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.grey),
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
                                        fontWeight: FontWeight.w800,
                                        color: nominalRiwayat >= 0
                                            ? AppColors.primary
                                            : AppColors.danger,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (hasCatatan) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        catatan,
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
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
                                    color: AppColors.textMuted,
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
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        onPressed: () => showTambahNominal(context),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Ionicons.add, color: AppColors.onPrimary),
        label: const Text(
          "TAMBAH NOMINAL",
          style: TextStyle(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
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
        icon: Icon(icon, size: 13),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          backgroundColor: color,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Quicksand',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Helper Widget Card Ringkasan
  Widget _buildSummaryItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
