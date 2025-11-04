class Estudiante {
  int id;
  int usuarioId;
  String curso;

  Estudiante({
    required this.id,
    required this.usuarioId,
    required this.curso,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'curso': curso,
    };
  }

  factory Estudiante.fromMap(Map<String, dynamic> map) {
    return Estudiante(
      id: map['id'],
      usuarioId: map['usuario_id'],
      curso: map['curso'],
    );
  }
}