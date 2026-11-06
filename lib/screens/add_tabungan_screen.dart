import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import '../models/tabungan_model.dart';
import '../utils/rupiah_formatter.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';

class AddTabunganScreen extends StatefulWidget {
  const AddTabunganScreen({super.key});

  @override
  State<AddTabunganScreen> createState() => _AddTabunganScreenState();
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    double dashWidth = 6.0;
    double dashSpace = 4.0;
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AddTabunganScreenState extends State<AddTabunganScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController targetController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  String selectedType = "Harian";
  File? imageFile;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Color(0xff333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tambah Tabungan",
          style: TextStyle(
            color: Color(0xff333333),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// FOTO
              const Text(
                "Foto tabungan",
                style: TextStyle(
                  color: Color(0xff777777),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),

              GestureDetector(
                onTap: pickImage,
                child: CustomPaint(
                  painter: DashedBorderPainter(color: const Color(0xFFAAAAAA)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Ionicons.cloud_upload,
                                color: Color(0xFF777777),
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Klik untuk unggah foto",
                                style: TextStyle(color: Color(0xFF777777), fontWeight: FontWeight.w500),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(imageFile!, fit: BoxFit.cover),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// NAMA
              const Text(
                "Nama tabungan",
                style: TextStyle(
                  color: Color(0xff777777),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: namaController,
                decoration: inputDecoration("Masukkan nama tabungan disini"),
                // ⚡ POPUP ADAPTIF ⚡
                contextMenuBuilder: (context, editableTextState) {
                  return SystemContextMenu.editableText(
                    editableTextState: editableTextState,
                  );
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nama tabungan wajib diisi!";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// TARGET
              const Text(
                "Target tabungan",
                style: TextStyle(
                  color: Color(0xff777777),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: targetController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  RupiahFormatter(),
                ],
                decoration: inputDecoration("Masukkan target tabungan disini"),
                // ⚡ POPUP ADAPTIF ⚡
                contextMenuBuilder: (context, editableTextState) {
                  return SystemContextMenu.editableText(
                    editableTextState: editableTextState,
                  );
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Target wajib diisi!";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// NOMINAL PERHARI
              const Text(
                "Nominal tabungan",
                style: TextStyle(
                  color: Color(0xff777777),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: ["Harian", "Mingguan", "Bulanan"].map((e) {
                  bool isActive = selectedType == e;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedType = e;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF1B6B5A)
                              : Color(0xfff2f2f2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            e,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Color(0xFF777777),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: nominalController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  RupiahFormatter(),
                ],
                decoration: inputDecoration("Masukkan nominal tabungan disini"),
                // ⚡ POPUP ADAPTIF ⚡
                contextMenuBuilder: (context, editableTextState) {
                  return SystemContextMenu.editableText(
                    editableTextState: editableTextState,
                  );
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nominal wajib diisi!";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              /// BUTTON SIMPAN
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // 1. Hitung dulu berapa hari yang dibutuhkan buat mencapai target
                      int targetAngka = int.parse(
                        targetController.text.replaceAll('.', ''),
                      );
                      int nominalAngka = int.parse(
                        nominalController.text.replaceAll('.', ''),
                      );

                      // Target dibagi nominal harian = jumlah hari (dibulatkan ke atas pakai .ceil)
                      int jumlahHari = (targetAngka / nominalAngka).ceil();

                      // 2. Tentukan tanggal dibuat dan hitung estimasi selesainya
                      DateTime sekarang = DateTime.now();
                      DateTime tanggalEstimasi = sekarang.add(
                        Duration(days: jumlahHari),
                      );
                      final data = Tabungan(
                        nama: namaController.text,
                        target: targetAngka,
                        perHari: nominalAngka,
                        tipe: selectedType,
                        terkumpul: 0, // Inisialisasi awal 0
                        tanggalDibuat: sekarang,
                        estimasiSelesai:
                            tanggalEstimasi, // MASUKIN VARIABEL INI
                        imagePath: imageFile?.path,
                      );

                      Navigator.pop(context, data);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6B5A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Simpan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
      errorStyle: const TextStyle(fontSize: 12, color: Color(0xffC35555)),
      filled: true,
      fillColor: const Color(0xFFFAFAFA), // Warna background inputan
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ), // Dikasih space dikit biar lega
      // 1. Border default (Bawaan pas lagi ga diklik)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      // 2. Border pas form lagi ga diklik (enabled) biar makin rapi
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),

      // 3. INI YANG BIKIN JADI IJO PAS LAGI NGETIK / FOKUS
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF1B6B5A), // Warna ijo sesuai request kamu
          width: 1.5, // Ditebelin dikit biar tegas kelihatannya
        ),
      ),
    );
  }
}
