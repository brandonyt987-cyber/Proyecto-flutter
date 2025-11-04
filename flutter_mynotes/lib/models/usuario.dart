// models/usuario.dart: Modelo para usuarios básicos.

class Usuario {
  int id;
  String nombre;
  String apellido;
  String email;
  String password;
  int rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.password,
    required this.rol,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'password': password,
      'rol': rol,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      email: map['email'],
      password: map['password'],
      rol: map['rol'],
    );
  }
}