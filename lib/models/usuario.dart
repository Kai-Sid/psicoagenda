class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final String telefono;
  final String rol;

  Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.rol,
  });

  factory Usuario.fromMap(String uid, Map<String, dynamic> data) {
    return Usuario(
      uid: uid,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      telefono: data['telefono'] ?? '',
      rol: data['rol'] ?? 'cliente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'rol': rol,
    };
  }
}
