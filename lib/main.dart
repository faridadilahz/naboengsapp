import 'package:material_ui/material_ui.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NaboengsApp());
}

class NaboengsApp extends StatelessWidget {
  const NaboengsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Naboengs',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Quicksand'),
      home: const HomeScreen(),
    );
  }
}
