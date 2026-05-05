import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:ionicons/ionicons.dart';
import '../models/tabungan_model.dart';
import '../utils/rupiah_formatter.dart';
import 'package:flutter/services.dart';

class EditTabunganScreen extends StatefulWidget {
  final Tabungan item; // Wajib ada karena mau edit data yang sudah ada

  const EditTabunganScreen({super.key, required this.item});

  @override
  State<EditTabunganScreen> createState() => _EditTabunganScreenState();
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
    targetController = TextEditingController(text: widget.item.target.toString());
    nominalController = TextEditingController(text: widget.item.perHari.toString());
    selectedType = widget.item.tipe;
    if (widget.item.imagePath != null) {
      imageFile = File(widget.item.imagePath!);
    }
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
        title: const Text(
          "Edit Tabungan",
          style: TextStyle(color: Color(0xff222222), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Color(0xff222222)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Foto Tabungan", style: TextStyle(color: Color(0xff777777), fontSize: 16)),
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
                      ? const Center(child: Icon(Ionicons.image_outline, size: 40))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(imageFile!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              
              const Text("Nama tabungan", style: TextStyle(color: Color(0xff777777), fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: namaController,
                decoration: inputDecoration("Nama tabungan"),
                validator: (v) => (v == null || v.isEmpty) ? "Nama wajib diisi!" : null,
              ),

              const SizedBox(height: 16),
              const Text("Target tabungan", style: TextStyle(color: Color(0xff777777), fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: targetController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, RupiahFormatter()],
                decoration: inputDecoration("Target"),
                validator: (v) => (v == null || v.isEmpty) ? "Target wajib diisi!" : null,
              ),

              const SizedBox(height: 16),
              const Text("Tipe Tabungan", style: TextStyle(color: Color(0xff777777), fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: ["Harian", "Mingguan", "Bulanan"].map((e) {
                  bool isActive = selectedType == e;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedType = e),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF1B6B5A) : const Color(0xfff2f2f2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(e, style: TextStyle(color: isActive ? Colors.white : const Color(0xff222222))),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              const Text("Nominal Tabungan", style: TextStyle(color: Color(0xff777777), fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: nominalController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, RupiahFormatter()],
                decoration: inputDecoration("Nominal"),
                validator: (v) => (v == null || v.isEmpty) ? "Nominal wajib diisi!" : null,
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Kuncinya di sini: Kita bikin objek baru tapi bawa saldo lama
                      final data = Tabungan(
                        nama: namaController.text,
                        target: int.parse(targetController.text.replaceAll('.', '')),
                        perHari: int.parse(nominalController.text.replaceAll('.', '')),
                        tipe: selectedType,
                        imagePath: imageFile?.path,
                        terkumpul: widget.item.terkumpul, // Tetap pake saldo lama
                        riwayat: widget.item.riwayat,     // Tetap pake riwayat lama
                        isDone: widget.item.isDone,
                      );
                      Navigator.pop(context, data);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B6B5A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Simpan Perubahan", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}