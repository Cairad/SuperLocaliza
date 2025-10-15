import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'product.dart';
import 'settings_screen.dart';

class ProductMapScreen extends StatelessWidget {
  final Product? producto;
  final List<Product>? productos;

  const ProductMapScreen({super.key, this.producto, this.productos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'SuperLocaliza',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        // --- NUEVO WIDGET: Botón de información en el AppBar ---
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showInfoModal(context);
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // La leyenda se mueve al modal de información
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildStoreEntrance(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            // --- CAMBIO: Se invierte el orden de los pasillos ---
                            children:
                                List.generate(4, (index) {
                                      final aisleNumber =
                                          4 - index; // 4, 3, 2, 1
                                      return _buildAisle(
                                        aisleNumber,
                                        5,
                                        context,
                                      );
                                    }).reversed
                                    .toList(), // Para que el 1 quede abajo al inicio
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: SizedBox(
                height: 60,
                width: 60,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(
                    Icons.search,
                    size: 30,
                    color: Color(0xFF4A90E2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la UI para la entrada del supermercado.
  Widget _buildStoreEntrance() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      margin: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_downward, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            'ENTRADA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_upward, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  // --- NUEVA FUNCIÓN: Muestra un modal con información y leyenda ---
  void _showInfoModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Información del Mapa',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Este mapa te ayuda a encontrar tus productos rápidamente dentro del supermercado.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              const Text(
                'Leyenda:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(width: 20, height: 20, color: Colors.orangeAccent),
                  const SizedBox(width: 8),
                  const Text('Ubicación de tu producto buscado'),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Container(width: 20, height: 20, color: Colors.brown),
                  const SizedBox(width: 8),
                  const Text('Otros estantes disponibles'),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Toca cualquier estante para ver los productos disponibles en él!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAisle(
    int aisleNumber,
    int shelfCountPerSide,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(shelfCountPerSide, (index) {
              final shelfNumber = index + 1;
              return _buildShelf(aisleNumber, shelfNumber, context);
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                border: Border.symmetric(
                  horizontal: BorderSide(color: Colors.grey.shade400, width: 2),
                ),
              ),
              child: Text(
                'PASILLO $aisleNumber',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(shelfCountPerSide, (index) {
              final shelfNumber = index + 1 + shelfCountPerSide;
              return _buildShelf(aisleNumber, shelfNumber, context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildShelf(int aisleNum, int shelfNum, BuildContext context) {
    bool isHighlighted = false;

    if (producto != null) {
      if (producto!.pasillo.trim() == 'Pasillo $aisleNum' &&
          producto!.estante.trim() == 'Estanteria $shelfNum') {
        isHighlighted = true;
      }
    }

    return GestureDetector(
      onTap: () {
        _showShelfContentsModal(context, aisleNum, shelfNum);
      },
      child: Container(
        width: 50,
        height: 35,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.orangeAccent : Colors.brown.shade300,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isHighlighted
                ? Colors.orange.shade800
                : Colors.brown.shade600,
            width: 2,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: Colors.orangeAccent.withOpacity(0.7),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          '$shelfNum',
          style: TextStyle(
            color: isHighlighted ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showShelfContentsModal(
    BuildContext context,
    int aisleNum,
    int shelfNum,
  ) {
    final List<Product> productsOnShelf =
        productos
            ?.where(
              (p) =>
                  p.pasillo.trim() == 'Pasillo $aisleNum' &&
                  p.estante.trim() == 'Estanteria $shelfNum',
            )
            .toList() ??
        [];

    final currencyFormat = NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Productos en Estanteria $shelfNum, Pasillo $aisleNum',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (productsOnShelf.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    'No hay productos registrados en esta ubicación.',
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: productsOnShelf.length,
                    itemBuilder: (context, index) {
                      final productOnList = productsOnShelf[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Color(0xFF4A90E2),
                          ),
                          title: Text(
                            productOnList.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(productOnList.categoria),
                          trailing: _buildModalPrice(
                            productOnList,
                            currencyFormat,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalPrice(Product product, NumberFormat format) {
    final double precioOriginal = double.tryParse(product.precio) ?? 0;
    final double? precioFinal = double.tryParse(
      product.precioConDescuento ?? '',
    );
    final bool enOferta = precioFinal != null && precioFinal < precioOriginal;

    if (enOferta) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            format.format(precioOriginal),
            style: TextStyle(
              color: Colors.grey.shade500,
              decoration: TextDecoration.lineThrough,
              fontSize: 12,
            ),
          ),
          Text(
            format.format(precioFinal),
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      );
    } else {
      return Text(
        format.format(precioOriginal),
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      );
    }
  }
}
