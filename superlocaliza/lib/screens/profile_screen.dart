import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'lib/user_profile.dart';
import 'lib/edit_profile_screen.dart';
import 'lib/change_password_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final userId = decodedToken['user_id'];

    final url = Uri.parse('http://192.168.1.200:8000/api/clientes/$userId/');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (mounted && response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _userProfile = UserProfile.fromJson(data);
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNCIÓN PARA CONFIRMAR Y ELIMINAR CUENTA ---
  Future<void> _confirmDeleteAccount() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Cuenta'),
          content: const Text(
            '¿Estás seguro? Esta acción es permanente y no se puede deshacer.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar Definitivamente'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }

  // --- FUNCIÓN PARA LLAMAR A LA API Y ELIMINAR CUENTA ---
  Future<void> _deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) return;

    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final userId = decodedToken['user_id'];

    final url = Uri.parse('http://192.168.1.200:8000/api/clientes/$userId/');

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (mounted) {
        if (response.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cuenta eliminada con éxito.')),
          );
          // Cierra la sesión
          await prefs.remove('accessToken');
          await prefs.remove('refreshToken');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar la cuenta.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error de conexión.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar Perfil',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              if (result == true && mounted) {
                setState(() {
                  _isLoading = true;
                });
                await _loadProfileData();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
          ? const Center(
              child: Text('No se pudieron cargar los datos del perfil.'),
            )
          : _buildProfileView(),
    );
  }

  Widget _buildProfileView() {
    final DateFormat formatter = DateFormat(
      'dd \'de\' MMMM \'de\' yyyy',
      'es_ES',
    );
    final String joinDate = formatter.format(_userProfile!.fechaRegistro);

    return RefreshIndicator(
      onRefresh: _loadProfileData,
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white70,
                  child: Text(
                    '${_userProfile!.nombre[0]}${_userProfile!.apellido[0]}'
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${_userProfile!.nombre} ${_userProfile!.apellido}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Miembro desde $joinDate',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información de la Cuenta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        subtitle: _userProfile!.email,
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        icon: Icons.phone_outlined,
                        title: 'Teléfono',
                        subtitle: _userProfile!.telefono ?? 'No especificado',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Gestión de la Cuenta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.lock_outline,
                        title: 'Cambiar Contraseña',
                        isAction: true,
                        onTap: () {
                          // --- NAVEGACIÓN CORREGIDA ---
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        icon: Icons.delete_forever_outlined,
                        title: 'Eliminar Cuenta',
                        color: Colors.redAccent,
                        isAction: true,
                        onTap:
                            _confirmDeleteAccount, // --- FUNCIONALIDAD AÑADIDA ---
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListTile _buildInfoTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color color = Colors.black87,
    bool isAction = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: isAction ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: isAction ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }
}
