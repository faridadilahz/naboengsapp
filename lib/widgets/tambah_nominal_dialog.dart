import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:naboengs/utils/app_colors.dart';
import 'package:naboengs/widgets/tambah_kurang_selector.dart';
import '../models/tabungan_model.dart';
import '../utils/format_rupiah.dart';
import '../utils/rupiah_formatter.dart';

class TambahNominalDialog extends StatefulWidget {
  final Tabungan item;

  const TambahNominalDialog({super.key, required this.item});

  @override
  State<TambahNominalDialog> createState() => _TambahNominalDialogState();
}

class _TambahNominalDialogState extends State<TambahNominalDialog> {
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  bool isTambah = true;
  List<int> userNominals = [];

  @override
  void initState() {
    super.initState();
    _initUserNominals();
  }

  void _initUserNominals() {
    for (dynamic r in widget.item.riwayat) {
      bool rIsTambah = false;
      int rNominal = 0;

      if (r is Map) {
        rIsTambah = r['isTambah'] ?? true;
        rNominal = (r['nominal'] is int)
            ? r['nominal']
            : int.tryParse(r['nominal'].toString()) ?? 0;
      } else {
        rIsTambah = r.isTambah ?? true;
        rNominal = r.nominal ?? 0;
      }

      if (rIsTambah && rNominal > 0 && !userNominals.contains(rNominal)) {
        userNominals.add(rNominal);
      }
    }
  }

  InputDecoration inputDecoration(String hint, {Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      errorStyle: const TextStyle(fontSize: 12, color: AppColors.danger),
      filled: true,
      fillColor: AppColors.surfaceInput,
      prefixIcon: prefixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Tambah Nominal Tabungan",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TambahKurangSelector(
              isTambah: isTambah,
              onChanged: (value) => setState(() => isTambah = value),
            ),
            const SizedBox(height: 20),
            const Text(
              "Nominal Tabungan",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: nominalController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                RupiahFormatter(),
              ],
              decoration: inputDecoration(
                "Masukkan Nominal",
                prefixIcon: const Icon(
                  Ionicons.cash,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(height: 12),
            if (userNominals.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: userNominals.map((amount) {
                    String formatted = formatRupiah(amount);
                    bool isSelected = nominalController.text == formatted;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surfaceInput,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          splashColor: AppColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          highlightColor: AppColors.primary.withValues(
                            alpha: 0.08,
                          ),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                nominalController.clear();
                              } else {
                                nominalController.text = formatted;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.grey,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              formatted,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
            const Text(
              "Catatan (Opsional)",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: catatanController,
              decoration: inputDecoration(
                "Contoh: Uang jajan",
                prefixIcon: const Icon(
                  Ionicons.reader,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.danger,
                      minimumSize: const Size(double.infinity, 48),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.danger),
                      ),
                    ),
                    child: const Text(
                      "BATAL",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (nominalController.text.isNotEmpty) {
                        String cleanNominal = nominalController.text.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        );
                        int nominal = int.parse(cleanNominal);
                        int nominalFinal = isTambah ? nominal : -nominal;

                        Navigator.pop(context, {
                          "nominal": nominalFinal,
                          "catatan": catatanController.text.trim(),
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      minimumSize: const Size(double.infinity, 48),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "TAMBAH",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
