import 'package:flutter/material.dart';
import '../models/materia.dart';
import '../services/database_services.dart';

class MateriasProvider with ChangeNotifier {
  List<Materia> _materias = [];

  Future<void> crearMateria({
    required String nombre, required int profesorId, required List<String> dias,
    required String horarioInicio, required String horarioFin, required int salon,
    required List<String> cursosAsignados,
  }) async {
    if (int.parse(horarioInicio.split(':')[0]) < 6 || int.parse(horarioFin.split(':')[0]) > 18) {
      throw Exception('Horario fuera de rango (06:00-18:00)');
    }

    final materia = Materia(
      nombre: nombre,
      profesorId: profesorId,
      dias: dias,
      horarioInicio: horarioInicio,
      horarioFin: horarioFin,
      salon: salon,
      cursosAsignados: cursosAsignados,
    );
    await DatabaseService.instance.insertMateria(materia.toMap());
    _materias.add(materia);
    notifyListeners();
  }

  Future<void> loadMateriasForProfesor(int profesorId) async {
    final list = await DatabaseService.instance.getMateriasByProfesor(profesorId);
    _materias = list.map((m) => Materia.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> loadMateriasForEstudiante(String curso) async {
    final list = await DatabaseService.instance.getMateriasForEstudiante(curso);
    _materias = list.map((m) => Materia.fromMap(m)).toList();
    notifyListeners();
  }

  List<Materia> get materias => _materias;
}