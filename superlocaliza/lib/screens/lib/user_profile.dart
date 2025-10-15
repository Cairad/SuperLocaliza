class UserProfile {
  final String username;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final DateTime fechaRegistro;

  UserProfile({
    required this.username,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    required this.fechaRegistro,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'],
      fechaRegistro: DateTime.tryParse(json['fecha_registro'] ?? '') ?? DateTime.now(),
    );
  }
}