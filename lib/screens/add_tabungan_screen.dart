import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:ionicons/ionicons.dart';
import '../models/tabungan_model.dart';
import '../utils/rupiah_formatter.dart';
import 'package:flutter/services.dart';

class AddTabunganScreen extends StatefulWidget {
  const AddTabunganScreen({super.key});

  @override
  State<AddTabunganScreen> createState() => _AddTabunganScreenState();
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
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: BackButton(color: Color(0xff222222)),
        ),
        title: const Text(
          "Tambah Tabungan",
          style: TextStyle(
            color: Color(0xff222222),
            fontWeight: FontWeight.bold,
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
                "Foto Tabungan",
                style: TextStyle(
                  color: Color(0xff777777),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),

              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF1B6B5A)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Ionicons.cloud_upload_outline,
                              color: Color(0xFF1B6B5A),
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Ambil foto dari galeri",
                              style: TextStyle(color: Color(0xFF1B6B5A)),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(imageFile!, fit: BoxFit.cover),
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
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF1B6B5A)
                              : Color(0xfff2f2f2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            e,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Color(0xff222222),
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
                decoration: inputDecoration("Rencana nominal tabungan"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Nominal wajib diisi!";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// CATATAN
              const Text(
                "Catatan (Opsional)",
                style: TextStyle(
                  color: Color(0xff777777),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: catatanController,
                maxLines: 3,
                decoration: inputDecoration("Masukkan catatan tabungan disini"),
              ),

              const SizedBox(height: 24),

              /// BUTTON SIMPAN
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
                        imagePath: imageFile?.path,
                      );

                      Navigator.pop(context, data);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6B5A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Simpan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
      hintStyle: const TextStyle(
      color: Color(0xFFAAAAAA),
    ),
      errorStyle: const TextStyle(fontSize: 12, color: Color(0xffC35555)),
      filled: true,
      fillColor: Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
