import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/usuario.dart';
import '../models/estudiantes.dart';
import '../models/profesor.dart';
import '../services/database_services.dart';

class AuthProvider with ChangeNotifier {
  Usuario? _usuarioActual;
  Estudiante? _estudianteActual;
  Profesor? _profesorActual;

  Usuario? get usuarioActual => _usuarioActual;
  Estudiante? get estudianteActual => _estudianteActual;
  Profesor? get profesorActual => _profesorActual;

  bool validarNombreApellido(String valor) {
    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]{6,40}$');
    return regex.hasMatch(valor);
  }

  bool validarPassword(String password) {
    final regex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&_-])[A-Za-z\d@$!%*?&_-]{8,}$');
    return regex.hasMatch(password);
  }

  int determinarRol(String email) {
    // Remover @admin si existe para determinar el rol real
    final emailLimpio = email.replaceAll('@admin', '');
    
    if (emailLimpio.endsWith('@gmail.com')) return 1;
    if (emailLimpio.endsWith('@profesor.com')) return 2;
    throw Exception('Dominio no válido');
  }

  // ✅ VERIFICAR SI ES ADMIN (Puerta trasera)
  bool esAdmin(String email) {
    return email.contains('@admin');
  }

  // ✅ ELIMINAR USUARIO ADMIN
  Future<void> eliminarUsuarioAdmin(String email) async {
    // Remover el @admin para obtener el email real
    final emailReal = email.replaceAll('@admin', '');
    await DatabaseService.instance.deleteUsuarioByEmail(emailReal);
  }

  Future<void> register({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String confirmPassword,
    String? curso,
    String? area,
    List<String>? cursosAsignados,
  }) async {
    // Validaciones
    if (!validarNombreApellido(nombre)) {
      throw Exception('Nombre inválido (6-40 caracteres, solo letras)');
    }
    if (!validarNombreApellido(apellido)) {
      throw Exception('Apellido inválido (6-40 caracteres, solo letras)');
    }
    if (password != confirmPassword) {
      throw Exception('Las contraseñas no coinciden');
    }
    if (!validarPassword(password)) {
      throw Exception(
          'Contraseña débil (mín. 8 caracteres, mayúscula, minúscula, número y símbolo)');
    }

    // Determinar rol y guardar email limpio
    final emailLimpio = email.replaceAll('@admin', '');
    final rol = determinarRol(emailLimpio);

    final usuarioMap = {
      'nombre': nombre,
      'apellido': apellido,
      'email': emailLimpio, // Guardar email sin @admin
      'password': password,
      'rol': rol,
    };

    try {
      final usuarioId =
          await DatabaseService.instance.insertUsuario(usuarioMap);

      if (rol == 1) {
        // ESTUDIANTE
        if (curso == null || curso.isEmpty) {
          throw Exception('Curso requerido para estudiante');
        }
        final estudianteMap = {
          'usuario_id': usuarioId,
          'curso': curso,
        };
        final estudianteId =
            await DatabaseService.instance.insertEstudiante(estudianteMap);
        _estudianteActual =
            Estudiante.fromMap({...estudianteMap, 'id': estudianteId});
      } else if (rol == 2) {
        // PROFESOR
        if (area == null || area.isEmpty) {
          throw Exception('Área requerida para profesor');
        }
        if (cursosAsignados == null || cursosAsignados.isEmpty) {
          throw Exception('Debe seleccionar al menos un curso');
        }
        final profesorMap = {
          'usuario_id': usuarioId,
          'area': area,
          'cursos_asignados': jsonEncode(cursosAsignados),
        };
        final profesorId =
            await DatabaseService.instance.insertProfesor(profesorMap);
        _profesorActual =
            Profesor.fromMap({...profesorMap, 'id': profesorId});
      }

      _usuarioActual = Usuario.fromMap({...usuarioMap, 'id': usuarioId});
      notifyListeners();
    } catch (e) {
      // Re-lanzar con mensaje limpio
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> login(String email, String password) async {
    try {
      // Limpiar email antes de buscar
      final emailLimpio = email.replaceAll('@admin', '');
      
      final usuarioMap =
          await DatabaseService.instance.getUsuarioByEmail(emailLimpio);
      
      if (usuarioMap == null) {
        throw Exception('Usuario no encontrado');
      }
      
      if (usuarioMap['password'] != password) {
        throw Exception('Contraseña incorrecta');
      }

      _usuarioActual = Usuario.fromMap(usuarioMap);
      final rol = usuarioMap['rol'] as int;

      if (rol == 1) {
        final estudianteMap = await DatabaseService.instance
            .getEstudianteByUsuarioId(usuarioMap['id']);
        if (estudianteMap != null) {
          _estudianteActual = Estudiante.fromMap(estudianteMap);
        }
      } else if (rol == 2) {
        final profesorMap = await DatabaseService.instance
            .getProfesorByUsuarioId(usuarioMap['id']);
        if (profesorMap != null) {
          _profesorActual = Profesor.fromMap(profesorMap);
        }
      }

      notifyListeners();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void logout() {
    _usuarioActual = null;
    _estudianteActual = null;
    _profesorActual = null;
    notifyListeners();
  }
}