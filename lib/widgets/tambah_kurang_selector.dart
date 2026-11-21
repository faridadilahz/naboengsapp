import 'package:material_ui/material_ui.dart';
import 'package:naboengs/utils/app_colors.dart';

class TambahKurangSelector extends StatelessWidget {
  final bool isTambah;
  final ValueChanged<bool> onChanged;

  const TambahKurangSelector({
    super.key,
    required this.isTambah,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: isTambah ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 1 / 2,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isTambah ? AppColors.primary : AppColors.danger,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
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
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(true),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: isTambah
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFFAAAAAA),
                        fontSize: 14,
                        fontWeight:
                            isTambah ? FontWeight.w800 : FontWeight.w600,
                        fontFamily: 'Quicksand',
                      ),
                      child: const Text("+ Tambah"),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(false),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: !isTambah
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFFAAAAAA),
                        fontSize: 14,
                        fontWeight:
                            !isTambah ? FontWeight.w800 : FontWeight.w600,
                        fontFamily: 'Quicksand',
                      ),
                      child: const Text("- Kurangi"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}