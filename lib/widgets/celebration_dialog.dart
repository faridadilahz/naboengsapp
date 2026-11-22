import 'dart:math';
import 'package:material_ui/material_ui.dart';
import 'package:confetti/confetti.dart';
import 'package:ionicons/ionicons.dart';
import 'package:naboengs/utils/app_colors.dart';
import '../models/tabungan_model.dart';
import '../utils/format_rupiah.dart';

class SelebrasiTercapaiDialog extends StatefulWidget {
  final Tabungan item;

  const SelebrasiTercapaiDialog({super.key, required this.item});

  @override
  State<SelebrasiTercapaiDialog> createState() =>
      _SelebrasiTercapaiDialogState();
}

class _SelebrasiTercapaiDialogState extends State<SelebrasiTercapaiDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          blastDirection: pi / 2,
          emissionFrequency: 0.05,
          numberOfParticles: 25,
          gravity: 0.2,
          colors: const [
            AppColors.primary,
            AppColors.danger,
            Color(0xFF8CE4C5),
            Color(0xFFFFC847),
            Color(0xFF4CC9F0),
          ],
        ),

        Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Ionicons.trophy,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Hore! Tabungan Kamu Tercapai!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Selamat! Kamu berhasil mengumpulkan target ${formatRupiah(widget.item.target)} untuk '${widget.item.nama}'.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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
                      "LANJUTKAN",
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
