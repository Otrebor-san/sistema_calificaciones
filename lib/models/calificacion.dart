class Calificacion {
  final int? id;
  final String nombreEstudiante;
  final String materia;
  final String profesor;
  final double notaFinal;
  final String estado; // 'A' = Activo, 'I' = Inactivo

  Calificacion({
    this.id,
    required this.nombreEstudiante,
    required this.materia,
    required this.profesor,
    required this.notaFinal,
    this.estado = 'A',
  });

  // Convierte el objeto a un Map para guardarlo en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombreEstudiante': nombreEstudiante,
      'materia': materia,
      'profesor': profesor,
      'notaFinal': notaFinal,
      'estado': estado,
    };
  }

  // Crea un objeto Calificacion desde un Map de SQLite
  factory Calificacion.fromMap(Map<String, dynamic> map) {
    return Calificacion(
      id: map['id'],
      nombreEstudiante: map['nombreEstudiante'],
      materia: map['materia'],
      profesor: map['profesor'],
      notaFinal: map['notaFinal'],
      estado: map['estado'],
    );
  }

  // Para poder editar una calificacion existente
  Calificacion copyWith({
    int? id,
    String? nombreEstudiante,
    String? materia,
    String? profesor,
    double? notaFinal,
    String? estado,
  }) {
    return Calificacion(
      id: id ?? this.id,
      nombreEstudiante: nombreEstudiante ?? this.nombreEstudiante,
      materia: materia ?? this.materia,
      profesor: profesor ?? this.profesor,
      notaFinal: notaFinal ?? this.notaFinal,
      estado: estado ?? this.estado,
    );
  }
}