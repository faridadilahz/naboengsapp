import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:ionicons/ionicons.dart';
import '../models/tabungan_model.dart';
import '../utils/format_rupiah.dart';

class SelebrasiTercapaiDialog extends StatefulWidget {
  final Tabungan item;

  const SelebrasiTercapaiDialog({super.key, required this.item});

  @override
  State<SelebrasiTercapaiDialog> createState() => _SelebrasiTercapaiDialogState();
}

class _SelebrasiTercapaiDialogState extends State<SelebrasiTercapaiDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
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
            Color(0xFF1B6B5A),
            Colors.amber,
            Colors.orange,
            Colors.pink,
            Colors.blue,
          ],
        ),

        Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Ionicons.trophy,
                    size: 56,
                    color: Color(0xFF1B6B5A),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Hore! Tabungan Kamu Tercapai!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Selamat! Kamu berhasil mengumpulkan target ${formatRupiah(widget.item.target)} untuk '${widget.item.nama}'.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777777),
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
                      backgroundColor: const Color(0xFF1B6B5A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "LANJUTKAN",
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
      ],
    );
  }
}