import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'map.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late Timer _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _fetchProducts();

    // 🔹 Configurar refresco automático cada 5 segundos
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchProducts();
    });
  }

  // 🔹 Función para traer productos desde la API Django
  Future<void> _fetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    if (token == null || refreshToken == null) {
      await _logout();
      return;
    }

    final url = Uri.parse('http://192.168.1.86:8000/api/productos/');
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        products = data.cast<Map<String, dynamic>>();
        filteredProducts = List.from(products);
      });
    } else if (response.statusCode == 401) {
      // Token expirado → refresh
      final refreshUrl = Uri.parse(
        'http://192.168.1.86:8000/api/token/refresh/',
      );
      final refreshResponse = await http.post(
        refreshUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (refreshResponse.statusCode == 200) {
        final newToken = jsonDecode(refreshResponse.body)['access'];
        await prefs.setString('accessToken', newToken);
        _fetchProducts(); // reintentar
      } else {
        await _logout();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al obtener productos: ${response.statusCode}"),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sesión expirada. Inicia sesión nuevamente."),
      ),
    );
  }

  // 🔹 Función de búsqueda
  void _searchProduct() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products
          .where((p) => p['nombre'].toString().toLowerCase().contains(query))
          .toList();
      _animationController.forward(from: 0);
    });
  }

  // 🔹 Mostrar información del producto en modal
  void _showProductInfo(Map<String, dynamic> product) {
    double precio = double.tryParse(product['precio'].toString()) ?? 0.0;
    String precioFormateado = (precio % 1 == 0)
        ? precio.toInt().toString()
        : precio.toString();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_grocery_store, color: Colors.green.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    product['nombre'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 🔹 Validar si existe precio con descuento
            if (double.tryParse(
                      product['precio_con_descuento']?.toString() ?? '',
                    ) !=
                    null &&
                double.parse(product['precio_con_descuento'].toString()) <
                    double.parse(product['precio'].toString()))
              Row(
                children: [
                  Text(
                    "\$${precio.toInt()}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough, // 🔹 Tachado
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "\$${double.parse(product['precio_con_descuento'].toString()).toInt()}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.red, // 🔹 Precio promocional en rojo
                    ),
                  ),
                ],
              )
            else
              Text(
                "\$${precioFormateado}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),

            const SizedBox(height: 5),
            Text(
              "Stock: ${product['stock']}",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 5),
            Text(
              "Categoría: ${product['categoria'] ?? 'N/A'}",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 5),
            Text(
              "Ubicación: Pasillo ${product['pasillo']}, Estante ${product['estanteria']}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.map, color: Colors.white),
                label: const Text(
                  "Ver en el mapa",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapScreen(highlightedProduct: product),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    _autoRefreshTimer.cancel(); // Cancelar el timer al cerrar la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onSubmitted: (_) => _searchProduct(),
                decoration: InputDecoration(
                  hintText: "Buscar producto...",
                  prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                      color: Colors.green.shade700,
                    ),
                    onPressed: _searchProduct,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  double precio =
                      double.tryParse(product['precio'].toString()) ?? 0.0;
                  String precioFormateado = (precio % 1 == 0)
                      ? precio.toInt().toString()
                      : precio.toString();
                  return GestureDetector(
                    onTap: () => _showProductInfo(product),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_grocery_store,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              product['nombre'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ),
                          // 🔹 Precio con descuento en modal
                          if (double.tryParse(
                                    product['precio_con_descuento']
                                            ?.toString() ??
                                        '',
                                  ) !=
                                  null &&
                              double.parse(
                                    product['precio_con_descuento'].toString(),
                                  ) <
                                  double.parse(product['precio'].toString()))
                            Row(
                              children: [
                                Text(
                                  "\$${precio.toInt()} ",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                Text(
                                  "\$${double.parse(product['precio_con_descuento'].toString()).toInt()}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              "\$${precioFormateado}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade800,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
