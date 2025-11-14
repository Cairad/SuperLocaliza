import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'home_screen.dart';
import 'login_screen.dart'; // Importa tu pantalla de login principal

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _verifyTokenAndNavigate();
  }

  Future<void> _verifyTokenAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    // 1. Verificar Access Token
    if (token != null && !JwtDecoder.isExpired(token)) {
      if (!mounted) return;
      // Redirigir a Home
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      return;
    }

    // 2. Si el Access Token falló, intentar refrescar
    if (refreshToken != null) {
      final refreshUrl = Uri.parse(
        'https://superlocaliza-backend.onrender.com/api/clientes/token/refresh/',
      );
      try {
        final refreshResponse = await http.post(
          refreshUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh': refreshToken}),
        );

        if (refreshResponse.statusCode == 200) {
          final newData = jsonDecode(refreshResponse.body);
          final newToken = newData['access'] as String;
          await prefs.setString('accessToken', newToken);

          if (!mounted) return;
          // Redirigir a Home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          return;
        }
      } catch (e) {
        // Error de conexión, seguir al login
      }
    }

    // 3. Si todo falla, limpiar sesión y redirigir a Login
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContextF) {
    // Muestra un indicador de carga mientras se verifica todo
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
