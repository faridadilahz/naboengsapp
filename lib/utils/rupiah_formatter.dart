import 'package:flutter/services.dart';

class RupiahFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // ambil angka aja (hapus titik)
    String text = newValue.text.replaceAll('.', '');

    if (text.isEmpty) return newValue;

    // parse ke int
    int value = int.parse(text);

    // format jadi ribuan
    String newText = _formatNumber(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  String _formatNumber(int number) {
    String result = number.toString();
    StringBuffer buffer = StringBuffer();

    int count = 0;

    for (int i = result.length - 1; i >= 0; i--) {
      count++;
      buffer.write(result[i]);

      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    return buffer.toString().split('').reversed.join();
  }
}
