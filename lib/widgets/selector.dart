import 'package:flutter/material.dart';

class SegmentedSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const SegmentedSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  static const List<String> types = ["Harian", "Mingguan", "Bulanan"];

  @override
  Widget build(BuildContext context) {
    int selectedIndex = types.indexOf(selectedType);
    if (selectedIndex == -1) selectedIndex = 0;

    Alignment alignment;
    if (selectedIndex == 0) {
      alignment = Alignment.centerLeft;
    } else if (selectedIndex == 1) {
      alignment = Alignment.center;
    } else {
      alignment = Alignment.centerRight;
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: alignment,
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1B6B5A),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Row(
            children: types.map((type) {
              bool isSelected = selectedType == type;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTypeChanged(type),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFFAAAAAA),
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w400,
                        fontFamily: 'Quicksand',
                      ),
                      child: Text(type),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}