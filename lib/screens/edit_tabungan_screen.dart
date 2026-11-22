import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/tabungan_model.dart';
import '../utils/app_colors.dart';
import '../utils/rupiah_formatter.dart';
import '../widgets/selector.dart';
import '../widgets/tabungan_image.dart';

class EditTabunganScreen extends StatefulWidget {
  final Tabungan item;

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

  late TextEditingController namaController;
  late TextEditingController targetController;
  late TextEditingController nominalController;

  String selectedType = "Harian";
  String? imageBase64;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.item.nama);
    targetController = TextEditingController(
      text: formatRupiahInitial(widget.item.target),
    );
    nominalController = TextEditingController(
      text: formatRupiahInitial(widget.item.perHari),
    );
    selectedType = widget.item.tipe;
    imageBase64 = widget.item.imagePath;
  }

  String formatRupiahInitial(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> pickImage() async {
    try {
      bool isAllowed = true;

      if (!kIsWeb) {
        PermissionStatus status = await Permission.photos.request();

        if (status.isDenied) {
          status = await Permission.storage.request();
        }

        isAllowed = status.isGranted || status.isLimited;

        if (status.isPermanentlyDenied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Izin galeri ditolak. Aktifkan izin foto untuk naboengs di Pengaturan.',
              ),
              action: SnackBarAction(
                label: 'Pengaturan',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
          return;
        }
      }

      if (!isAllowed) return;

      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 75,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (!mounted) return;
        setState(() {
          imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuka galeri: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Ionicons.arrowBack, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Tabungan",
          style: TextStyle(
            color: AppColors.textPrimary,
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
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),

              CustomPaint(
                painter: DashedBorderPainter(color: AppColors.textMuted),
                child: Material(
                  color: AppColors.surfaceInput,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: pickImage,
                    borderRadius: BorderRadius.circular(16),
                    splashColor: AppColors.primary.withValues(alpha: 0.12),
                    highlightColor: AppColors.primary.withValues(alpha: 0.08),
                    child: SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: imageBase64 == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Ionicons.cloudUpload,
                                  color: AppColors.textSecondary,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Klik untuk unggah foto",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : TabunganImage(
                              imageSource: imageBase64!,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// NAMA
              const Text(
                "Nama tabungan",
                style: TextStyle(
                  color: AppColors.textSecondary,
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
                    buttonItems: editableTextState.contextMenuButtonItems,
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
                  color: AppColors.textSecondary,
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
                    buttonItems: editableTextState.contextMenuButtonItems,
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
                  color: AppColors.textSecondary,
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
                    buttonItems: editableTextState.contextMenuButtonItems,
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
                        imagePath: imageBase64,
                        terkumpul: widget.item.terkumpul,
                        riwayat: widget.item.riwayat,
                        isDone: widget.item.isDone,
                      );
                      Navigator.pop(context, data);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "SIMPAN PERUBAHAN",
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.5,
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
      hintStyle: const TextStyle(color: AppColors.textMuted),
      errorStyle: const TextStyle(fontSize: 12, color: AppColors.danger),
      filled: true,
      fillColor: AppColors.surfaceInput,
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
