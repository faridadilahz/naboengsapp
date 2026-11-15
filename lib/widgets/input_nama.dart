import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:naboengs/utils/app_colors.dart';

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
            padding: EdgeInsets.fromLTRB(
              24,
              widget.isFirstTime ? 28 : 48,
              24,
              widget.isFirstTime ? 16 : 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.isFirstTime
                      ? "Masukkan Nama Panggilan"
                      : "Ubah Nama Panggilan",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  widget.isFirstTime
                      ? "Nama ini akan muncul saat kamu membuka aplikasi."
                      : "Kosongkan jika ingin memakai nama yang sebelumnya.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textMuted,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _namaController,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitNama(),
                  inputFormatters: [LengthLimitingTextInputFormatter(20)],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: "Contoh: Jane Doe",
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceInput,
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
                      borderSide: const BorderSide(color: AppColors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitNama,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
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

                if (widget.isFirstTime) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Lewati",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (!widget.isFirstTime)
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(
                  Ionicons.close,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
        ],
      ),
    );
  }
}
