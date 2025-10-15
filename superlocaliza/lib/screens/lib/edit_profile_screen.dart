import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();

  bool _isLoading = true;
  dynamic _userId;
  String? _accessToken;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');

    if (_accessToken == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final Map<String, dynamic> decodedToken = JwtDecoder.decode(_accessToken!);
    _userId = decodedToken['user_id'];

    if (_userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse('http://192.168.1.200:8000/api/clientes/$_userId/');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (mounted && response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        _usernameController.text = data['username'] ?? '';
        _nombreController.text = data['nombre'] ?? '';
        _apellidoController.text = data['apellido'] ?? '';
        _emailController.text = data['email'] ?? '';
        _telefonoController.text = data['telefono'] ?? '';

        if (data['fecha_nacimiento'] != null) {
          _selectedDate = DateTime.parse(data['fecha_nacimiento']);
          _fechaNacimientoController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(_selectedDate!);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar datos.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse('http://192.168.1.200:8000/api/clientes/$_userId/');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // No enviamos el 'username' porque es de solo lectura.
        body: jsonEncode({
          'username': _usernameController.text,
          'nombre': _nombreController.text,
          'apellido': _apellidoController.text,
          'email': _emailController.text,
          'telefono': _telefonoController.text,
          'fecha_nacimiento': _selectedDate != null
              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
              : null,
        }),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado con éxito.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de conexión.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaNacimientoController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Nombre de Usuario',
                    icon: Icons.account_circle_outlined,
                    enabled: true,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'El nombre de usuario no puede estar vacío'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nombreController,
                    label: 'Nombre',
                    icon: Icons.person_outline,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'El nombre no puede estar vacío'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _apellidoController,
                    label: 'Apellido',
                    icon: Icons.person_outline,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'El apellido no puede estar vacío'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El email no puede estar vacío';
                      }
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return 'Ingresa un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _telefonoController,
                    label: 'Teléfono',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fechaNacimientoController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Fecha de Nacimiento',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Cambios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
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
  }

  // --- CORRECCIÓN: Se asegura que el TextFormField use el parámetro 'enabled' ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled, // El campo se puede habilitar o deshabilitar
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        // Cambia el color de fondo si el campo está deshabilitado
        fillColor: enabled ? Colors.grey.shade100 : Colors.grey.shade200,
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }
}
