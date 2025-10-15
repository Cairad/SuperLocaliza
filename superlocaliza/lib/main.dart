import 'package:flutter/material.dart';
import 'package:superlocaliza/screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {

   WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null); 
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuperLocaliza',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF4A90E2),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF4A90E2),
        scaffoldBackgroundColor: Color(0xFF121212),
      ),
      themeMode: _themeMode,
      home: const LoginScreen(),
    );
  }
}
