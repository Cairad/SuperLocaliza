import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'home.dart'; // para ir al Home después de registrarse

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  DateTime? fechaNacimiento;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Función para registrar cliente en Django
  Future<void> registrarCliente() async {
    final String username = usernameController.text.trim(); // <-- CORRECTO
    final String nombre = nameController.text.trim();
    final String apellido = apellidoController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String telefono = telefonoController.text.trim();
    final String direccion = direccionController.text.trim();
    final String fechaNac = fechaNacimiento != null
        ? DateFormat('yyyy-MM-dd').format(fechaNacimiento!)
        : '';

    if (username.isEmpty ||
        nombre.isEmpty ||
        apellido.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        telefono.isEmpty ||
        direccion.isEmpty ||
        fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    final url = Uri.parse('http://192.168.1.92:8000/api/clientes/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'nombre': nombre,
          'apellido': apellido,
          'email': email,
          'password': password,
          'telefono': telefono,
          'direccion': direccion,
          'fecha_nacimiento': fechaNac,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(toggleTheme: () {})),
        );
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        String errorMsg = data['detail'] ?? 'Error al registrar el cliente';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale("es", "ES"),
    );
    if (seleccionada != null && seleccionada != fechaNacimiento) {
      setState(() {
        fechaNacimiento = seleccionada;
      });
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green),
      filled: true,
      fillColor: Colors.green.shade50,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green.shade700, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green.shade300, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.green.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icono/logo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_grocery_store,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Título
                    Text(
                      "Crea tu cuenta",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Username
                    TextField(
                      controller: usernameController,
                      decoration: _inputDecoration("Username", Icons.person),
                    ),
                    const SizedBox(height: 20),

                    // Nombre
                    TextField(
                      controller: nameController,
                      decoration: _inputDecoration("Nombre", Icons.person),
                    ),
                    const SizedBox(height: 20),

                    // Apellido
                    TextField(
                      controller: apellidoController,
                      decoration: _inputDecoration(
                        "Apellido",
                        Icons.person_outline,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email
                    TextField(
                      controller: emailController,
                      decoration: _inputDecoration("Correo", Icons.email),
                    ),
                    const SizedBox(height: 20),

                    // Teléfono
                    TextField(
                      controller: telefonoController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration("Teléfono", Icons.phone),
                    ),
                    const SizedBox(height: 20),

                    // Dirección
                    TextField(
                      controller: direccionController,
                      decoration: _inputDecoration("Dirección", Icons.home),
                    ),
                    const SizedBox(height: 20),

                    // Fecha nacimiento
                    InkWell(
                      onTap: () => _seleccionarFecha(context),
                      child: InputDecorator(
                        decoration: _inputDecoration(
                          "Fecha nacimiento",
                          Icons.cake,
                        ),
                        child: Text(
                          fechaNacimiento == null
                              ? "Selecciona tu fecha"
                              : DateFormat(
                                  "dd/MM/yyyy",
                                ).format(fechaNacimiento!),
                          style: TextStyle(
                            color: fechaNacimiento == null
                                ? Colors.grey.shade600
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contraseña
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _inputDecoration("Contraseña", Icons.lock),
                    ),
                    const SizedBox(height: 30),

                    // Botón Registrar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: registrarCliente, // Llamada al API
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.black45,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ).copyWith(elevation: WidgetStateProperty.all(6)),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade700,
                                Colors.green.shade400,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              "Registrarse",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Volver a login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "¿Ya tienes cuenta? ",
                          style: TextStyle(color: Colors.green.shade800),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Inicia sesión",
                            style: TextStyle(
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
