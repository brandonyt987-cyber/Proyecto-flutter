// models/nota.dart: Modelo para notas.

class Nota {
  int? id;
  int materiaId;
  String nombreNota;
  int? estudianteId;
  double? calificacion;

  Nota({
    this.id,
    required this.materiaId,
    required this.nombreNota,
    this.estudianteId,
    this.calificacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materia_id': materiaId,
      'nombre_nota': nombreNota,
      'estudiante_id': estudianteId,
      'calificacion': calificacion,
    };
  }

  factory Nota.fromMap(Map<String, dynamic> map) {
    return Nota(
      id: map['id'],
      materiaId: map['materia_id'],
      nombreNota: map['nombre_nota'],
      estudianteId: map['estudiante_id'],
      calificacion: map['calificacion'],
    );
  }
}