import 'package:flutter/material.dart';
import 'user_login_screen.dart';
import 'register_screen.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4A90E2), // azul principal
                Color(0xFF50E3C2), // verde aqua suave
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  // Animación Lottie del carrito de compras
                  SizedBox(
                    height: 280, // más pequeño
                    child: Image.asset(
                      'assets/lottie/logo.gif',
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: 40),
                  // Botón Login con Google
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.account_circle,
                      color: Colors.red,
                      size: 24,
                    ),
                    label: Text('Continuar con Google'),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Botón Login con Facebook
                  ElevatedButton.icon(
                    icon: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/0/05/Facebook_Logo_%282019%29.png',
                      height: 24,
                    ),
                    label: Text('Continuar con Facebook'),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Botón Login con Usuario
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserLoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Iniciar sesión con Usuario',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  SizedBox(height: 16),
                  // Botón Registro
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      '¿No tienes cuenta? Regístrate',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
