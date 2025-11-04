// providers/notas_provider.dart: Provider para notas.

import 'package:flutter/material.dart';
import '../models/nota.dart';
import '../services/database_services.dart';

class NotasProvider with ChangeNotifier {
  List<Nota> _notas = [];

  Future<void> crearNota(int materiaId, String nombreNota, List<int> estudianteIds) async {
    await DatabaseService.instance.asignarNotaAEstudiantes(materiaId, nombreNota, estudianteIds);
    notifyListeners();
  }

  Future<void> loadNotasForEstudiante(int materiaId, int estudianteId) async {
    final list = await DatabaseService.instance.getNotasForEstudiante(materiaId, estudianteId);
    _notas = list.map((n) => Nota.fromMap(n)).toList();
    notifyListeners();
  }

  Future<void> updateCalificacion(int notaId, double calificacion) async {
    await DatabaseService.instance.updateCalificacion(notaId, calificacion);
    notifyListeners();
  }

  List<Nota> get notas => _notas;
}