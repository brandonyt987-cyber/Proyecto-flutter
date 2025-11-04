import 'dart:convert';

class Profesor {
  int id;
  int usuarioId;
  String area;
  List<String> cursosAsignados;

  Profesor({
    required this.id,
    required this.usuarioId,
    required this.area,
    required this.cursosAsignados,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'area': area,
      'cursos_asignados': jsonEncode(cursosAsignados),
    };
  }

  factory Profesor.fromMap(Map<String, dynamic> map) {
    return Profesor(
      id: map['id'],
      usuarioId: map['usuario_id'],
      area: map['area'],
      cursosAsignados: List<String>.from(jsonDecode(map['cursos_asignados'])),
    );
  }
}