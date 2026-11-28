import 'package:material_ui/material_ui.dart';
import 'package:naboengs/utils/app_colors.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService().initNotification();
  } catch (e) {
    debugPrint('Gagal inisialisasi notifikasi: $e');
  }
  runApp(const NaboengsApp());
}

class NaboengsApp extends StatelessWidget {
  const NaboengsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'naboengs',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        fontFamily: 'MPLUSRounded1c',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
