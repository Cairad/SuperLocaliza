import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'home_screen.dart'; // Asegúrate de importar tu HomeScreen
import 'login_screen.dart'; // Asegúrate de importar tu LoginScreen

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia la verificación tan pronto como se construye el widget
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    // Espera un poco para que la transición no sea tan brusca
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return; // Comprueba si el widget todavía está en el árbol

    if (token != null && !JwtDecoder.isExpired(token)) {
      // Si el token existe y no ha expirado, ve al Home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Si no hay token o ha expirado, ve al Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Muestra un indicador de carga mientras se realiza la verificación
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}