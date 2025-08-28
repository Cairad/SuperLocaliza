import 'package:flutter/material.dart';
import 'map.dart'; // Importa el mapa para navegar

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  List<String> results = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Diccionario simulado de productos y ubicaciones
  final Map<String, Map<String, dynamic>> productData = {
    "Leche": {"desc": "Leche entera 1L", "pasillo": 1, "estante": 2},
    "Pan": {"desc": "Pan integral 500g", "pasillo": 2, "estante": 1},
    "Arroz": {"desc": "Arroz grano largo 1kg", "pasillo": 3, "estante": 2},
    "Huevos": {"desc": "Docena de huevos frescos", "pasillo": 1, "estante": 3},
    "Frutas": {"desc": "Manzanas rojas 1kg", "pasillo": 2, "estante": 2},
    "Verduras": {"desc": "Lechuga fresca", "pasillo": 3, "estante": 1},
  };

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
  }

  void searchProduct() {
    setState(() {
      String query = searchController.text.toLowerCase();
      results = productData.keys
          .where((p) => p.toLowerCase().contains(query))
          .toList();
      _animationController.forward(from: 0);
    });
  }

  void showProductInfo(String product) {
    final data = productData[product]!;
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
                Text(
                  product,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              data["desc"],
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 20),
            Text(
              "📍 Ubicación: Pasillo ${data["pasillo"]}, Estante ${data["estante"]}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 25),
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
                  Navigator.pop(context); // Cierra el modal
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
                onSubmitted: (_) => searchProduct(),
                decoration: InputDecoration(
                  hintText: "Buscar producto...",
                  prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                      color: Colors.green.shade700,
                    ),
                    onPressed: searchProduct,
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
                itemCount: results.length,
                itemBuilder: (context, index) {
                  String product = results[index];
                  return GestureDetector(
                    onTap: () => showProductInfo(product),
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
                          Text(
                            product,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade900,
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
