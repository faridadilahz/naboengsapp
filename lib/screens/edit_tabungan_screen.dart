import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import '../models/tabungan_model.dart';
import '../utils/rupiah_formatter.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import '../widgets/selector.dart';

class EditTabunganScreen extends StatefulWidget {
  final Tabungan item; // Wajib ada karena mau edit data yang sudah ada

  const EditTabunganScreen({super.key, required this.item});

  @override
  State<EditTabunganScreen> createState() => _EditTabunganScreenState();
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

class _EditTabunganScreenState extends State<EditTabunganScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller langsung diisi pake data dari widget.item
  late TextEditingController namaController;
  late TextEditingController targetController;
  late TextEditingController nominalController;

  String selectedType = "Harian";
  File? imageFile;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data lama
    namaController = TextEditingController(text: widget.item.nama);
    targetController = TextEditingController(
      text: formatRupiahInitial(widget.item.target),
    );
    nominalController = TextEditingController(
      text: formatRupiahInitial(widget.item.perHari),
    );
    selectedType = widget.item.tipe;
    if (widget.item.imagePath != null) {
      imageFile = File(widget.item.imagePath!);
    }
  }

  // Helper opsional buat format titik angka awal pas load data
  String formatRupiahInitial(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

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
          "Edit Tabungan",
          style: TextStyle(
            color: Color(0xff333333),
            fontWeight: FontWeight.w800,
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
                                style: TextStyle(
                                  color: Color(0xFF777777),
                                  fontWeight: FontWeight.w500,
                                ),
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
                contextMenuBuilder: (context, editableTextState) {
                  return AdaptiveTextSelectionToolbar.buttonItems(
                    anchors: editableTextState.contextMenuAnchors,
                    buttonItems: editableTextState
                        .contextMenuButtonItems, // Gunakan contextMenuButtonItems
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
                contextMenuBuilder: (context, editableTextState) {
                  return AdaptiveTextSelectionToolbar.buttonItems(
                    anchors: editableTextState.contextMenuAnchors,
                    buttonItems: editableTextState
                        .contextMenuButtonItems, // Gunakan contextMenuButtonItems
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

              SegmentedSelector(
                selectedType: selectedType,
                onTypeChanged: (type) {
                  setState(() {
                    selectedType = type;
                  });
                },
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
                contextMenuBuilder: (context, editableTextState) {
                  return AdaptiveTextSelectionToolbar.buttonItems(
                    anchors: editableTextState.contextMenuAnchors,
                    buttonItems: editableTextState
                        .contextMenuButtonItems, // Gunakan contextMenuButtonItems
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

              /// BUTTON SIMPAN PERUBAHAN
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Tetap pakai logika PUT/EDIT kamu (saldo & riwayat lama aman)
                      final data = Tabungan(
                        nama: namaController.text,
                        target: int.parse(
                          targetController.text.replaceAll('.', ''),
                        ),
                        perHari: int.parse(
                          nominalController.text.replaceAll('.', ''),
                        ),
                        tipe: selectedType,
                        tanggalDibuat: widget.item.tanggalDibuat,
                        estimasiSelesai: widget.item.estimasiSelesai,
                        imagePath: imageFile?.path,
                        terkumpul:
                            widget.item.terkumpul, // Tetap pake saldo lama
                        riwayat: widget.item.riwayat, // Tetap pake riwayat lama
                        isDone: widget.item.isDone,
                      );
                      Navigator.pop(context, data);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6B5A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "SIMPAN PERUBAHAN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
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
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF1B6B5A), width: 1.5),
      ),
    );
  }
}
