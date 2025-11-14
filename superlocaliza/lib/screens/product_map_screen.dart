import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'product.dart';
import 'settings_screen.dart';

class ProductMapScreen extends StatefulWidget {
  final Product? producto;
  final List<Product>? productos;

  const ProductMapScreen({super.key, this.producto, this.productos});

  @override
  State<ProductMapScreen> createState() => _ProductMapScreenState();
}

class _ProductMapScreenState extends State<ProductMapScreen> {
  bool _modalShown = false;

  @override
  void initState() {
    super.initState();
    _checkAndShowModal();
  }

  // --- MODIFICADO: Ahora usa el nombre del pasillo ---
  void _checkAndShowModal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.producto != null &&
          widget.producto!.pasillo != null &&
          widget.producto!.estante != null &&
          !_modalShown) {
        setState(() {
          _modalShown = true;
        });

        try {
          // Obtenemos el nombre del pasillo (ej: "Lacteos")
          final String aisleCategoryName = widget.producto!.pasillo!;

          // Parsea el string "Estanteria X" para obtener el número X
          final int shelfNum = int.parse(
            widget.producto!.estante!.split(' ').last,
          );

          // Llama a la función que muestra el modal del estante
          _showShelfContentsModal(context, aisleCategoryName, shelfNum);
        } catch (e) {
          debugPrint('Error al parsear pasillo/estante: $e');
        }
      }
    });
  }

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
                        child: Row(
                          children: [
                            _buildAisleColumn(isLeft: true, context: context),
                            _buildFullVerticalAisle(),
                            _buildAisleColumn(isLeft: false, context: context),
                          ],
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

  Widget _buildFullVerticalAisle() {
    return Container(
      width: 24,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border.symmetric(
          vertical: BorderSide(color: Colors.grey.shade400, width: 2),
        ),
      ),
      alignment: Alignment.center,
      child: RotatedBox(
        quarterTurns: 3,
        child: Text(
          'PASILLO CENTRAL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
            letterSpacing: 2,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  String _getAisleCategoryName(int aisleNumber, bool isLeft) {
    switch (aisleNumber) {
      case 1:
        return isLeft ? 'FRUTAS' : 'VERDURAS';
      case 2:
        return isLeft ? 'SNACKS' : 'BEBIDAS';
      case 3:
        return isLeft ? 'LACTEOS' : 'PASTAS';
      case 4:
        return 'CONGELADOS';
      default:
        return 'PASILLO $aisleNumber';
    }
  }

  Widget _buildAisleColumn({
    required bool isLeft,
    required BuildContext context,
  }) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Column(
          children: List.generate(4, (index) {
            final aisleNumber = 4 - index; // 4, 3, 2, 1
            return _buildAisleSegment(
              aisleNumber,
              3, // 3 estantes por lado
              isLeft,
              context,
            );
          }).reversed.toList(),
        ),
      ),
    );
  }

  // --- MODIFICADO: Ahora pasa el nombre de la categoría a _buildShelf ---
  Widget _buildAisleSegment(
    int aisleNumber,
    int shelfCountPerSide, // 3
    bool isLeft,
    BuildContext context,
  ) {
    final topRowStart = isLeft ? 1 : (shelfCountPerSide + 1);
    final bottomRowStart = isLeft
        ? (shelfCountPerSide * 2 + 1)
        : (shelfCountPerSide * 3 + 1);

    // Obtiene el nombre de la categoría para este segmento
    final String aisleCategoryName = _getAisleCategoryName(aisleNumber, isLeft);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          // Fila superior
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(shelfCountPerSide, (index) {
              final shelfNumber = index + topRowStart;
              // Pasa el nombre de la categoría al estante
              return _buildShelf(aisleCategoryName, shelfNumber, context);
            }),
          ),

          // Barra de Nombre de Pasillo
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
                aisleCategoryName, // Muestra el nombre de la categoría
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                  letterSpacing: 2,
                  fontSize: 10,
                ),
              ),
            ),
          ),

          // Fila inferior
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(shelfCountPerSide, (index) {
              final shelfNumber = index + bottomRowStart;
              // Pasa el nombre de la categoría al estante
              return _buildShelf(aisleCategoryName, shelfNumber, context);
            }),
          ),
        ],
      ),
    );
  }

  // --- MODIFICADO: Compara por nombre de categoría, no por número ---
  Widget _buildShelf(
    String aisleCategoryName,
    int shelfNum,
    BuildContext context,
  ) {
    bool isHighlighted = false;

    if (widget.producto != null) {
      if (widget.producto!.pasillo != null &&
          widget.producto!.estante != null) {
        String productAisleName = widget.producto!.pasillo ?? '';
        String productShelfName = widget.producto!.estante ?? '';

        // Compara el nombre del pasillo del producto (ej: "Lacteos")
        // con el nombre de la categoría del mapa (ej: "LACTEOS")
        if (productAisleName.trim().toUpperCase() ==
                aisleCategoryName.trim().toUpperCase() &&
            productShelfName.trim() == 'Estanteria $shelfNum') {
          isHighlighted = true;
        }
      }
    }

    return GestureDetector(
      onTap: () {
        // Pasa el nombre de la categoría al modal
        _showShelfContentsModal(context, aisleCategoryName, shelfNum);
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

  // --- MODIFICADO: Filtra por nombre de categoría, no por número ---
  void _showShelfContentsModal(
    BuildContext context,
    String aisleCategoryName,
    int shelfNum,
  ) {
    final List<Product> productsOnShelf =
        widget.productos
            ?.where(
              (p) =>
                  p.pasillo != null &&
                  p.estante != null &&
                  p.pasillo!.trim().toUpperCase() ==
                      aisleCategoryName.trim().toUpperCase() &&
                  p.estante!.trim() == 'Estanteria $shelfNum',
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
                'Productos en Estanteria $shelfNum, $aisleCategoryName',
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
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: (productOnList.imagen != null)
                                ? NetworkImage(productOnList.imagen!)
                                : null,
                            child: (productOnList.imagen == null)
                                ? Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.grey.shade600,
                                    size: 20,
                                  )
                                : null,
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

  /// Construye el widget de precio para el modal.
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
