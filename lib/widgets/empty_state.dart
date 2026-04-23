import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Ionicons.sad_outline, size: 86, color: Color(0xffaaaaaa)),

            SizedBox(height: 24),

            Text(
              "Belum ada sesuatu yang mau ditabung nih, yuk tambah tabungan!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xffaaaaaa),
                fontSize: 16,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
