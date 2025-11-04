import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/usuario.dart';
import '../models/estudiantes.dart';
import '../models/profesor.dart';
import '../services/database_services.dart';  // Ajusta si es services.dart

class AuthProvider with ChangeNotifier {
  Usuario? _usuarioActual;
  Estudiante? _estudianteActual;
  Profesor? _profesorActual;
  Usuario? get usuarioActual => _usuarioActual;

  bool validarNombreApellido(String valor) {
    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]{3,40}$');
    return regex.hasMatch(valor);
  }

  bool validarPassword(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&_-])[A-Za-z\d@$!%*?&_-]{8,}$');
    return regex.hasMatch(password);
  }

  int determinarRol(String email) {
    if (email.endsWith('@gmail.com')) return 1;
    if (email.endsWith('@profesor.com')) return 2;
    throw Exception('Dominio no válido');
  }

  Future<void> register({
    required String nombre, required String apellido, required String email,
    required String password, required String confirmPassword,
    String? curso, String? area, List<String>? cursosAsignados,
  }) async {
    if (!validarNombreApellido(nombre)) throw Exception('Nombre inválido');
    if (!validarNombreApellido(apellido)) throw Exception('Apellido inválido');
    if (password != confirmPassword) throw Exception('Contraseñas no coinciden');
    if (!validarPassword(password)) throw Exception('Contraseña débil');

    final rol = determinarRol(email);
    final usuarioMap = {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'password': password,
      'rol': rol,
    };
    final usuarioId = await DatabaseService.instance.insertUsuario(usuarioMap);

    if (rol == 1) {
      if (curso == null) throw Exception('Curso requerido para estudiante');
      final estudianteMap = {
        'usuario_id': usuarioId,
        'curso': curso,
      };
      final estudianteId = await DatabaseService.instance.insertEstudiante(estudianteMap);
      _estudianteActual = Estudiante.fromMap({...estudianteMap, 'id': estudianteId});
    } else if (rol == 2) {
      if (area == null || cursosAsignados == null) throw Exception('Área y cursos requeridos para profesor');
      final profesorMap = {
        'usuario_id': usuarioId,
        'area': area,
        'cursos_asignados': jsonEncode(cursosAsignados),
      };
      final profesorId = await DatabaseService.instance.insertProfesor(profesorMap);
      _profesorActual = Profesor.fromMap({...profesorMap, 'id': profesorId});
    }

    _usuarioActual = Usuario.fromMap({...usuarioMap, 'id': usuarioId});
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final usuarioMap = await DatabaseService.instance.getUsuarioByEmail(email);
    if (usuarioMap == null || usuarioMap['password'] != password) throw Exception('Credenciales inválidas');

    _usuarioActual = Usuario.fromMap(usuarioMap);
    final rol = usuarioMap['rol'] as int;

    if (rol == 1) {
      final estudianteMap = await DatabaseService.instance.getEstudianteByUsuarioId(usuarioMap['id']);
      if (estudianteMap != null) _estudianteActual = Estudiante.fromMap(estudianteMap);
    } else if (rol == 2) {
      final profesorMap = await DatabaseService.instance.getProfesorByUsuarioId(usuarioMap['id']);
      if (profesorMap != null) _profesorActual = Profesor.fromMap(profesorMap);
    }

    notifyListeners();
  }

  void logout() {
    _usuarioActual = null;
    _estudianteActual = null;
    _profesorActual = null;
    notifyListeners();
  }

  // Getters adicionales si necesitas
  Estudiante? get estudianteActual => _estudianteActual;
  Profesor? get profesorActual => _profesorActual;
}