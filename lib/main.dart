import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/theme/app_theme.dart';
import 'features/home/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Hive.initFlutter();
    await Hive.openBox('ufuk_cache');
  } catch (e) {
    print("CRITICAL: Hive Init Failed. Offline cache unavailable. Details: $e");
    // App continues to run, but offline mode will fail gracefully or re-attempt in repo
  }
  
  runApp(const UfukApp());
}

class UfukApp extends StatelessWidget {
  const UfukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UFUK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}

