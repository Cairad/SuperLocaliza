// lib/product.dart

class Product {
  final String nombre;
  final String categoria;
  final String pasillo;
  final String estante;
  final String precio;
  final String? descripcion;
  final String? imagen;
  
  // --- CAMPOS NUEVOS PARA PROMOCIONES ---
  final String? precioConDescuento;
  final String? descuentoActivo; // Guardará el porcentaje, ej: "15.00"

  Product({
    required this.nombre,
    required this.categoria,
    required this.pasillo,
    required this.estante,
    required this.precio,
    this.descripcion,
    this.precioConDescuento, // <-- AÑADIDO
    this.descuentoActivo,   // <-- AÑADIDO
    this.imagen,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      nombre: json['nombre'] ?? 'Sin nombre',
      categoria: json['categoria'] ?? 'Sin categoría',
      pasillo: json['pasillo'] ?? 'Sin pasillo',
      estante: json['estante'] ?? 'Sin estante',
      precio: json['precio'] ?? '0.00',
      descripcion: json['descripcion'],
      // --- MAPEO DE NUEVOS CAMPOS ---
      precioConDescuento: json['precio_con_descuento']?.toString(),
      descuentoActivo: json['descuento_activo']?.toString(),
      imagen: json['imagen'],
    );
  }
}