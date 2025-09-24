import 'package:flutter/material.dart';

class ProductLocation {
  final int aisle; // pasillo (1..3)
  final int shelf; // estante (1..6, ahora dividido)
  final String name;
  const ProductLocation({
    required this.aisle,
    required this.shelf,
    required this.name,
  });
}

class MapScreen extends StatefulWidget {
  final String? highlightedProduct;
  const MapScreen({super.key, this.highlightedProduct});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  ProductLocation? _location;

  // Catálogo DEMO -> mapea productos a Pasillo/Estante
  static const Map<String, ProductLocation> _demoCatalog = {
    "Leche": ProductLocation(aisle: 1, shelf: 1, name: "Leche"),
    "Pan": ProductLocation(aisle: 2, shelf: 1, name: "Pan"),
    "Arroz": ProductLocation(aisle: 1, shelf: 3, name: "Arroz"),
    "Huevos": ProductLocation(aisle: 3, shelf: 1, name: "Huevos"),
    "Frutas": ProductLocation(aisle: 2, shelf: 2, name: "Frutas"),
    "Verduras": ProductLocation(aisle: 3, shelf: 2, name: "Verduras"),
    "Azúcar": ProductLocation(aisle: 3, shelf: 3, name: "Azúcar"),
  };

  // Productos por pasillo y estante
  static const Map<int, Map<int, List<String>>> aisleShelfProducts = {
    1: {
      1: ["Leche"],
      2: ["Huevos"],
      3: ["Arroz"],
      4: [],
      5: [],
      6: [],
    },
    2: {
      1: ["Pan"],
      2: ["Frutas"],
      3: [],
      4: [],
      5: [],
      6: [],
    },
    3: {
      1: ["Huevos"],
      2: ["Verduras"],
      3: ["Azúcar"],
      4: [],
      5: [],
      6: [],
    },
  };

  @override
  void initState() {
    super.initState();
    if (widget.highlightedProduct != null) {
      _location = _demoCatalog[widget.highlightedProduct!];
    }
  }

  bool _isHighlighted(int aisle, int shelf) {
    return _location != null &&
        _location!.aisle == aisle &&
        _location!.shelf == shelf;
  }

  void _showProducts(int aisle, int shelf) {
    final products = aisleShelfProducts[aisle]?[shelf] ?? [];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Pasillo $aisle • Estante $shelf"),
        content: products.isEmpty
            ? const Text("No hay productos")
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: products.map((p) => Text("- $p")).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            if (_location != null) _LocationBadge(location: _location!),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _LegendChip(text: "Pasillo 1"),
                _LegendChip(text: "Pasillo 2"),
                _LegendChip(text: "Pasillo 3"),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 12.0;
                  final cols = 3;
                  final rows = 6; // ahora 6 estantes por pasillo
                  final cellWidth =
                      (constraints.maxWidth - spacing * (cols - 1)) / cols;
                  final cellHeight =
                      (constraints.maxHeight - spacing * (rows - 1)) / rows;

                  return Column(
                    children: List.generate(rows, (rowIndex) {
                      final shelf = rowIndex + 1; // 1..6
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: rowIndex == rows - 1 ? 0 : spacing,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(cols, (colIndex) {
                            final aisle = colIndex + 1;
                            final highlighted = _isHighlighted(aisle, shelf);
                            return _MapCell(
                              width: cellWidth,
                              height: cellHeight,
                              aisle: aisle,
                              shelf: shelf,
                              highlighted: highlighted,
                              onTap: () {
                                setState(() {
                                  _location = ProductLocation(
                                    aisle: aisle,
                                    shelf: shelf,
                                    name: _demoCatalog.values
                                        .firstWhere(
                                          (p) =>
                                              p.aisle == aisle &&
                                              p.shelf == shelf,
                                          orElse: () => ProductLocation(
                                            aisle: aisle,
                                            shelf: shelf,
                                            name: "",
                                          ),
                                        )
                                        .name,
                                  );
                                });
                                _showProducts(aisle, shelf);
                              },
                            );
                          }),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _MapCell extends StatelessWidget {
  final double width;
  final double height;
  final int aisle;
  final int shelf;
  final bool highlighted;
  final VoidCallback onTap;

  const _MapCell({
    required this.width,
    required this.height,
    required this.aisle,
    required this.shelf,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseBorder = Border.all(color: Colors.grey.shade300, width: 1.5);
    final highlightBorder = Border.all(
      color: Colors.green.shade800,
      width: 2.5,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: highlighted ? Colors.green.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: highlighted ? highlightBorder : baseBorder,
            boxShadow: [
              BoxShadow(
                color: highlighted
                    ? Colors.green.withOpacity(0.25)
                    : Colors.black12,
                blurRadius: highlighted ? 10 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "P$aisle",
                  style: TextStyle(
                    color: highlighted
                        ? Colors.green.shade900
                        : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "E$shelf",
                  style: TextStyle(
                    color: highlighted
                        ? Colors.green.shade900
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (highlighted)
                Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.location_on,
                    color: Colors.green.shade800,
                    size: 28,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationBadge extends StatelessWidget {
  final ProductLocation location;
  const _LocationBadge({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info, color: Colors.green.shade700, size: 20),
          const SizedBox(width: 8),
          Text(
            "${location.name.isNotEmpty ? "${location.name} • " : ""}"
            "Pasillo ${location.aisle} · Estante ${location.shelf}",
            style: TextStyle(
              color: Colors.green.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String text;
  const _LegendChip({required this.text});
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        text,
        style: TextStyle(
          color: Colors.green.shade900,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.green.shade200),
      elevation: 0,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
