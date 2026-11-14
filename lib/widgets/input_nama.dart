import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';

class InputNamaDialog extends StatefulWidget {
  final String currentName;
  final bool isFirstTime;

  const InputNamaDialog({
    super.key,
    required this.currentName,
    this.isFirstTime = false,
  });

  @override
  State<InputNamaDialog> createState() => _InputNamaDialogState();
}

class _InputNamaDialogState extends State<InputNamaDialog> {
  late TextEditingController _namaController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _submitNama() {
    Navigator.pop(context, _namaController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  widget.isFirstTime
                      ? "Masukkan Nama Panggilan"
                      : "Ubah Nama Panggilan",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  widget.isFirstTime
                      ? "Nama ini akan muncul saat kamu membuka aplikasi."
                      : "Kosongkan jika ingin memakai nama yang sebelumnya.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFAAAAAA),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 24),

                // Input Field (Tanpa validator wajib)
                TextFormField(
                  controller: _namaController,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitNama(),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                  decoration: InputDecoration(
                    hintText: "Contoh: Jane Doe",
                    hintStyle: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F9F9),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF1B6B5A),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submitNama,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B6B5A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      widget.isFirstTime ? "MULAI NABUNG" : "SIMPAN PERUBAHAN",
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tombol Close
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Ionicons.close, color: Colors.grey, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}