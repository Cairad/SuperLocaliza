import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'settings_screen.dart';
import 'product_map_screen.dart';
import 'product.dart';
import 'user_login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _productos = [];
  List<Product> _resultados = [];
  String? _categoriaFiltro;

  String? _accessToken;
  String? _refreshToken;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_aplicarFiltros);
    _loadTokensAndFetchProducts();
  }

  @override
  void dispose() {
    _searchController.removeListener(_aplicarFiltros);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTokensAndFetchProducts() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
    if (_accessToken != null) {
      await _cargarProductos();
    } else {
      _handleSessionExpired(showError: false);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;
    final url = Uri.parse('https://superlocaliza-backend.onrender.com/api/clientes/token/refresh/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', _accessToken!);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _cargarProductos() async {
    if (!mounted) return;
    if (_accessToken == null) {
      _handleSessionExpired(showError: false);
      return;
    }
    final url = Uri.parse('https://superlocaliza-backend.onrender.com/api/productos/');
    try {
      http.Response response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      if (response.statusCode == 401) {
        final bool refreshed = await _refreshAccessToken();
        if (refreshed) {
          response = await http.get(
            url,
            headers: {'Authorization': 'Bearer $_accessToken'},
          );
        } else {
          _handleSessionExpired();
          return;
        }
      }
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _productos = data.map((json) => Product.fromJson(json)).toList();
          });
          _aplicarFiltros();
        }
      } else {
        _handleSessionExpired();
      }
    } catch (e) {
      if (mounted) _mostrarError('Error de conexión al servidor');
    }
  }

  void _aplicarFiltros() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _resultados = _productos.where((p) {
        final matchesQuery = p.nombre.toLowerCase().contains(query);
        final matchesCategoria =
            _categoriaFiltro == null || p.categoria == _categoriaFiltro;
        return matchesQuery && matchesCategoria;
      }).toList();
    });
  }

  void _handleSessionExpired({bool showError = true}) async {
    if (mounted && showError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tu sesión ha expirado.'),
            backgroundColor: Colors.redAccent),
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const UserLoginScreen()),
        (route) => false,
      );
    }
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _mostrarModalProducto(Product producto) {
      final currencyFormat =
          NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);
      final double precioOriginal = double.tryParse(producto.precio) ?? 0;
      final double? precioFinal =
          double.tryParse(producto.precioConDescuento ?? '');
      final bool enOferta =
          precioFinal != null && precioFinal < precioOriginal;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          bool isExpanded = false; // Variable de estado para el "Ver más"

          // --- SOLO NECESITAS ESTE STATEFULBUILDER ---
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              
              // --- LA LÓGICA DE LA DESCRIPCIÓN DEBE IR AQUÍ DENTRO ---
              const int descriptionLimit = 100;
              final bool isLongDescription =
                  (producto.descripcion?.length ?? 0) > descriptionLimit;

              String displayedDescription =
                  producto.descripcion ?? 'No disponible';
              if (isLongDescription && !isExpanded) {
                displayedDescription =
                    '${producto.descripcion!.substring(0, descriptionLimit)}...';
              }
              // --- FIN DE LA LÓGICA DE DESCRIPCIÓN ---

              // --- AHORA RETORNA EL SingleChildScrollView DIRECTAMENTE ---
              return SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- WIDGET DE IMAGEN ---
                      if (producto.imagen != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.network(
                              producto.imagen!,
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                  height: 250,
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  height: 250,
                                  child: Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),

                      // --- RESTO DEL CONTENIDO ---
                      Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Descripción:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayedDescription, // Usa la variable calculada
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87, height: 1.4),
                      ),
                      if (isLongDescription)
                        InkWell(
                          onTap: () {
                            // Este setModalState ahora funciona
                            setModalState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  isExpanded ? 'Ver menos' : 'Ver más',
                                  style: const TextStyle(
                                    color: Color(0xFF4A90E2),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: const Color(0xFF4A90E2),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const Divider(height: 32),
                      _buildInfoRow('Categoría:', producto.categoria),
                      _buildInfoRow('Pasillo:', producto.pasillo ?? 'N/A'),
                      _buildInfoRow('Estantería:', producto.estante ?? 'N/A'),
                      const Divider(height: 32),
                      if (enOferta) ...[
                        Text(
                          'Precio Original:',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          currencyFormat.format(precioOriginal),
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black45,
                              decoration: TextDecoration.lineThrough),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Precio Oferta:',
                            currencyFormat.format(precioFinal),
                            isPrice: true),
                      ] else ...[
                        _buildInfoRow('Precio:',
                            currencyFormat.format(precioOriginal),
                            isPrice: true),
                      ],
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductMapScreen(
                                producto: producto,
                                productos: _productos,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.location_on, color: Colors.white),
                        label: const Text(
                          'Ver en el mapa',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

  Widget _buildInfoRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isPrice ? 20 : 16,
              color: isPrice ? Colors.green.shade700 : Colors.black87,
              fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarFiltros() {
    final categorias = _productos.map((p) => p.categoria).toSet().toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Filtrar por categoría',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A90E2))),
            const SizedBox(height: 16),
            ...categorias.map(
              (cat) => RadioListTile<String>(
                title: Text(cat),
                value: cat,
                groupValue: _categoriaFiltro,
                onChanged: (value) {
                  setState(() => _categoriaFiltro = value);
                  _aplicarFiltros();
                  Navigator.pop(context);
                },
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _categoriaFiltro = null);
                _aplicarFiltros();
                Navigator.pop(context);
              },
              child: const Text('Quitar filtro'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF4A90E2),
          centerTitle: true,
          title: const Text('SuperLocaliza',
              style: TextStyle(color: Colors.white)),
        ),
        
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child:
              const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    final currencyFormat =
        NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);

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
      ),
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Buscar producto...',
                          hintStyle: const TextStyle(color: Colors.black38),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.black54,
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 56,
                      width: 56,
                      child: FloatingActionButton(
                        heroTag: 'filtro',
                        backgroundColor: Colors.white,
                        onPressed: _mostrarFiltros,
                        child: const Icon(
                          Icons.filter_list,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _cargarProductos,
                    color: Colors.white,
                    backgroundColor: const Color(0xFF4A90E2),
                    child: _resultados.isEmpty
                        ? Center(
                            child: Text(
                              _isLoading ? 'Cargando...' : 'No se encontraron productos',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _resultados.length,
                            itemBuilder: (context, index) {
                              final producto = _resultados[index];
                              final String? descuento = producto.descuentoActivo;

                              return Stack(
                                children: [
                                  Card(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 4),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.white.withOpacity(0.5),
                                        //backgroundImage tomará la NetworkImage si no es nula
                                        backgroundImage: (producto.imagen != null)
                                            ? NetworkImage(producto.imagen!)
                                            : null,
                                        // Si la imagen es nula, muestra el ícono original
                                        child: (producto.imagen == null)
                                            ? const Icon(
                                                Icons.shopping_bag,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      title: Text(
                                        producto.nombre,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        producto.categoria,
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                      trailing: _buildPriceColumn(
                                          producto, currencyFormat),
                                      onTap: () =>
                                          _mostrarModalProducto(producto),
                                    ),
                                  ),
                                  if (descuento != null)
                                    Positioned(
                                      top: 10,
                                      left: 0,
                                      child: _buildOfferBanner(descuento),
                                    ),
                                ],
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductMapScreen(productos: _productos),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(
                        Icons.map,
                        size: 30,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferBanner(String discount) {
    final double discountValue = double.tryParse(discount) ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: Text(
        '-${discountValue.toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPriceColumn(Product producto, NumberFormat format) {
    final double precioOriginal = double.tryParse(producto.precio) ?? 0;
    final double? precioFinal =
        double.tryParse(producto.precioConDescuento ?? '');
    final bool enOferta =
        precioFinal != null && precioFinal < precioOriginal;

    if (enOferta) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            format.format(precioOriginal),
            style: const TextStyle(
              color: Colors.white54,
              decoration: TextDecoration.lineThrough,
              fontSize: 12,
            ),
          ),
          Text(
            format.format(precioFinal),
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      );
    } else {
      // --- CORRECCIÓN FINAL ---
      // Se elimina el 'Center' que causaba el error de layout.
      return Text(
        format.format(precioOriginal),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }
  }
}