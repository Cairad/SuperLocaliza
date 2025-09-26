import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductLocation {
  final String id;
  final String name;
  const ProductLocation({required this.id, required this.name});
}

// 🔹 Mapeo de bloques a productos de ejemplo (opcional, se puede eliminar)
const Map<String, List<String>> productsMap = {
  "milk": ["Leche", "Yogurt"],
  "deli": ["Jamón", "Queso"],
  "bakery": ["Pan", "Croissant"],
  "fruit": ["Manzana", "Pera"],
  "checkout": ["Caja 1", "Caja 2"],
};

// 🔹 Mapeo de productos a pasillo/estantería
final Map<String, Map<String, int>> productLocationMapping = {
  "milk": {"pasillo": 1, "estanteria": 1},
  "deli": {"pasillo": 1, "estanteria": 2},
  "bakery": {"pasillo": 2, "estanteria": 1},
  "fruit": {"pasillo": 2, "estanteria": 2},
  "checkout": {"pasillo": 3, "estanteria": 1},
};

final Map<String, int> idToPasillo = {
  "milk": 1,
  "deli": 1,
  "bakery": 2,
  "fruit": 2,
  "checkout": 3,
};

final Map<String, int> idToEstanteria = {
  "milk": 1,
  "deli": 2,
  "bakery": 1,
  "fruit": 2,
  "checkout": 1,
};

class MapScreen extends StatelessWidget {
  final Map<String, dynamic>? highlightedProduct;
  const MapScreen({super.key, this.highlightedProduct});

  // 🔹 Verifica si un bloque debe estar resaltado
  bool _isHighlighted(String id) {
    if (highlightedProduct == null) return false;

    // Tomamos el pasillo y estantería del producto directamente
    final prodPasillo =
        int.tryParse(highlightedProduct!['pasillo'].toString()) ?? 0;
    final prodEstante =
        int.tryParse(highlightedProduct!['estanteria'].toString()) ?? 0;

    final blockPasillo = idToPasillo[id] ?? 0;
    final blockEstante = idToEstanteria[id] ?? 0;

    return prodPasillo == blockPasillo && prodEstante == blockEstante;
  }

  // 🔹 Función para mostrar productos de un estante desde la API
  void _showProductsByShelf(BuildContext context, String id) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    if (token == null || refreshToken == null) return;

    final url = Uri.parse('http://192.168.1.86:8000/api/productos/');
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    List<Map<String, dynamic>> allProducts = [];
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      allProducts = data.cast<Map<String, dynamic>>();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al obtener productos: ${response.statusCode}"),
        ),
      );
      return;
    }

    // 🔹 Filtrar productos por pasillo y estante
    final pasillo = idToPasillo[id] ?? 0;
    final estante = idToEstanteria[id] ?? 0;

    final productsInShelf = allProducts.where((p) {
      final pPasillo = int.tryParse(p['pasillo'].toString()) ?? 0;
      final pEstante = int.tryParse(p['estanteria'].toString()) ?? 0;
      return pPasillo == pasillo && pEstante == estante;
    }).toList();

    // 🔹 Mostrar productos en modal
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: productsInShelf.isEmpty
            ? const Text("No hay productos en este estante")
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: productsInShelf.map((product) {
                  double precio =
                      double.tryParse(product['precio'].toString()) ?? 0.0;
                  String precioFormateado = (precio % 1 == 0)
                      ? precio.toInt().toString()
                      : precio.toString();

                  return ListTile(
                    title: Text(product['nombre']),
                    subtitle: Text(
                      "Precio: \$${precioFormateado} | Stock: ${product['stock']}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MapScreen(highlightedProduct: product),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _zoneBlock(BuildContext context, String id, {required Color color}) {
    final isHighlighted = _isHighlighted(id);

    return Expanded(
      child: GestureDetector(
        onTap: () => _showProductsByShelf(context, id),
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: isHighlighted ? color : color.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHighlighted ? Colors.black : Colors.grey.shade400,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isHighlighted ? color.withOpacity(0.5) : Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              id.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pasilloVertical() {
    return const SizedBox(
      width: 24,
      child: Center(
        child: Icon(Icons.arrow_upward, size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _flechasHorizontales() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_back, size: 16, color: Colors.grey),
          SizedBox(width: 4),
          Text(
            "Pasillo horizontal",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _rowWithPasillo(
    BuildContext context,
    String leftId,
    String rightId, {
    required Color leftColor,
    required Color rightColor,
  }) {
    return Column(
      children: [
        Row(
          children: [
            _zoneBlock(context, leftId, color: leftColor),
            _pasilloVertical(),
            _zoneBlock(context, rightId, color: rightColor),
          ],
        ),
        _flechasHorizontales(),
      ],
    );
  }

  Widget _buildMap(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _rowWithPasillo(
          context,
          "milk",
          "deli",
          leftColor: Colors.orange,
          rightColor: Colors.redAccent,
        ),
        _rowWithPasillo(
          context,
          "bakery",
          "fruit",
          leftColor: Colors.amber,
          rightColor: Colors.green,
        ),
        _rowWithPasillo(
          context,
          "checkout",
          "checkout",
          leftColor: Colors.black,
          rightColor: Colors.black,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _zoneBlock(context, "entrada", color: Colors.blueAccent),
            _pasilloVertical(),
            _zoneBlock(context, "salida", color: Colors.brown),
          ],
        ),
        _flechasHorizontales(),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(child: SingleChildScrollView(child: _buildMap(context))),
    );
  }
}
