import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/search.dart';
import 'screens/map.dart';
import 'screens/notifications.dart';

void main() {
  runApp(const SuperLocalizaApp());
}

class SuperLocalizaApp extends StatelessWidget {
  const SuperLocalizaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SúperLocaliza',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LoginScreen(), // comienza en Login
    );
  }
}

// --------------------------------------------------
// HomePage con navegación inferior
// --------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState(); // Publica la clase
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _productToHighlight; // Producto para resaltar en el mapa

  // Pantallas del HomePage
  late final List<Widget> _screens = [
    const SearchScreen(),
    MapScreen(highlightedProduct: _productToHighlight),
    NotificationsScreen(),
  ];

  // Cambiar pestaña
  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Seleccionar producto para resaltar en el mapa
  void setMapScreenProduct(String product) {
    setState(() {
      _productToHighlight = product;
      _screens[1] = MapScreen(highlightedProduct: _productToHighlight);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SúperLocaliza")),
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
