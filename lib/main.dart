import 'package:flutter/material.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'core/services/debug_service.dart';
import 'core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database factory for desktop platforms
  await DatabaseHelper.initializeDatabaseFactory();
  
  // Initialize debug service
  await DebugService.instance.initialize();
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dokter Grammar',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
