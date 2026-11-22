import 'package:material_ui/material_ui.dart';
import '../models/tabungan_model.dart';
import '../screens/detail_tabungan_screen.dart';
import 'empty_state.dart';
import 'tabungan_card.dart';

class TabunganListView extends StatelessWidget {
  final List<Tabungan> items;
  final int selectedTab;
  final VoidCallback onAddPressed;
  final Function(Tabungan item, String action) onItemUpdated;

  const TabunganListView({
    super.key,
    required this.items,
    required this.selectedTab,
    required this.onAddPressed,
    required this.onItemUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(
        onAddPressed: onAddPressed,
        isTercapaiTab: selectedTab == 1,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return TabunganCard(
          item: item,
          selectedTab: selectedTab,
          onTap: () async {
            final prevTerkumpul = item.terkumpul;
            final prevRiwayatLen = item.riwayat.length;
            final prevNama = item.nama;
            final prevTarget = item.target;

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailTabunganScreen(item: item),
              ),
            );

            if (result == "delete") {
              onItemUpdated(item, "delete");
            } else {
              // Cek apakah ada aktivitas baru (tambah/kurang nominal, riwayat baru, atau edit)
              final hasActivity =
                  item.terkumpul != prevTerkumpul ||
                  item.riwayat.length != prevRiwayatLen ||
                  item.nama != prevNama ||
                  item.target != prevTarget;

              if (hasActivity) {
                item.updatedAt = DateTime.now();
              }
              onItemUpdated(item, "update");
            }
          },
        );
      },
    );
  }
}
