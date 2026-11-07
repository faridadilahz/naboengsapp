import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
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
      hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
      errorStyle: const TextStyle(fontSize: 12, color: Color(0xffC35555)),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      prefixIcon: prefixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF1B6B5A),
          width: 1.5,
        ),
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
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isTambah = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isTambah
                            ? const Color(0xFF1B6B5A)
                            : const Color(0xFFE8F1EF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "+ Tambah",
                          style: TextStyle(
                            fontSize: 16,
                            color: isTambah
                                ? Colors.white
                                : const Color(0xFF1B6B5A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isTambah = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !isTambah
                            ? const Color(0xFFD35D5D)
                            : const Color(0xFFFAEBEB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "- Kurangi",
                          style: TextStyle(
                            fontSize: 16,
                            color: !isTambah
                                ? Colors.white
                                : const Color(0xFFD35D5D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Nominal Tabungan",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF333333),),
            ),
            const SizedBox(height: 8),

            // ⚡ TextField Nominal dengan inputDecoration ⚡
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
                  color: Color(0xFF777777),
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
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
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
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1B6B5A).withOpacity(0.1)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF1B6B5A)
                                  : Colors.grey.shade100,
                            ),
                          ),
                          child: Text(
                            formatted,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFF1B6B5A)
                                  : const Color(0xFF555555),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              "Catatan (Opsional)",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF333333),),
            ),
            const SizedBox(height: 8),

            // ⚡ TextField Catatan dengan inputDecoration ⚡
            TextField(
              controller: catatanController,
              decoration: inputDecoration(
                "Contoh: Uang jajan",
                prefixIcon: const Icon(
                  Ionicons.reader,
                  color: Color(0xFF777777),
                  size: 20,
                ),
              ),
            ),

            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFD35D5D),
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFD35D5D)),
                      ),
                    ),
                    child: const Text(
                      "BATAL",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (nominalController.text.isNotEmpty) {
                        String cleanNominal = nominalController.text
                            .replaceAll(RegExp(r'[^0-9]'), '');
                        int nominal = int.parse(cleanNominal);
                        int nominalFinal = isTambah ? nominal : -nominal;

                        Navigator.pop(context, {
                          "nominal": nominalFinal,
                          "catatan": catatanController.text.trim(),
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B6B5A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "TAMBAH",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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