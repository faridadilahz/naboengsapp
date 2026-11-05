import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart'; 

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32, bottom: 72),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // Ganti Ionicons.sad_outline jadi Icons.sentiment_dissatisfied_outlined
            Icon(
              Ionicons.file_tray,
              size: 86,
              color: Color(0xffaaaaaa),
            ),

            SizedBox(height: 24),

            Text(
              "Belum ada sesuatu yang mau ditabung nih, yuk tambah tabungan!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xffaaaaaa),
                fontSize: 16,
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}