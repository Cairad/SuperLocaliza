import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'screens/search.dart';
import 'screens/map.dart';
import 'screens/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  runApp(SuperLocalizaApp(initialDarkMode: isDarkMode));
}

class SuperLocalizaApp extends StatefulWidget {
  final bool initialDarkMode;
  const SuperLocalizaApp({super.key, required this.initialDarkMode});

  @override
  State<SuperLocalizaApp> createState() => _SuperLocalizaAppState();
}

class _SuperLocalizaAppState extends State<SuperLocalizaApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  void toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SúperLocaliza',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green.shade50,
        appBarTheme: AppBarTheme(backgroundColor: Colors.green.shade700),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: LoginScreenWithTheme(toggleTheme: toggleTheme),
    );
  }
}

// --------------------------------------------------
// LoginScreen adaptado para pasar toggle al HomePage
// --------------------------------------------------
class LoginScreenWithTheme extends StatelessWidget {
  final VoidCallback toggleTheme;
  const LoginScreenWithTheme({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      onLoginSuccess: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(toggleTheme: toggleTheme)),
        );
      },
    );
  }
}

// --------------------------------------------------
// HomePage con navegación inferior y toggle
// --------------------------------------------------
class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const HomePage({super.key, required this.toggleTheme});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _productToHighlight;

  late final List<Widget> _screens = [
    const SearchScreen(),
    MapScreen(highlightedProduct: null),
    NotificationsScreen(),
  ];

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setMapScreenProduct(String product) {
    setState(() {
      _productToHighlight = product;
      _screens[1] = MapScreen(highlightedProduct: _productToHighlight);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SúperLocaliza"),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: changeTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
        ],
      ),
    );
  }
}
