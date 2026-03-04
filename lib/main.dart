import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/tts_provider.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'themes/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TtsProvider()),
      ],
      child: Consumer<TtsProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'kinite TTS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}