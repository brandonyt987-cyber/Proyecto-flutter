// models/materia.dart: Modelo para materias.

import 'dart:convert';

class Materia {
  int? id;
  String nombre;
  int profesorId;
  List<String> dias;
  String horarioInicio;
  String horarioFin;
  int salon;
  List<String> cursosAsignados;

  Materia({
    this.id,
    required this.nombre,
    required this.profesorId,
    required this.dias,
    required this.horarioInicio,
    required this.horarioFin,
    required this.salon,
    required this.cursosAsignados,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': _capitalize(nombre),
      'profesor_id': profesorId,
      'dias': jsonEncode(dias),
      'horario_inicio': horarioInicio,
      'horario_fin': horarioFin,
      'salon': salon,
      'cursos_asignados': jsonEncode(cursosAsignados),
    };
  }

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      id: map['id'],
      nombre: map['nombre'],
      profesorId: map['profesor_id'],
      dias: List<String>.from(jsonDecode(map['dias'])),
      horarioInicio: map['horario_inicio'],
      horarioFin: map['horario_fin'],
      salon: map['salon'],
      cursosAsignados: List<String>.from(jsonDecode(map['cursos_asignados'])),
    );
  }

  static String _capitalize(String s) => s[0].toUpperCase() + s.substring(1).toLowerCase();
}