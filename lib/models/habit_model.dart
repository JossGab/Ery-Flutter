// lib/models/habit_model.dart

class Habit {
  final int id;
  final String nombre;
  final String? descripcion;
  final String tipo; // 'SI_NO', 'MEDIBLE_NUMERICO', 'MAL_HABITO'
  final int? metaObjetivo;
  final DateTime fechaCreacion;
  final int rachaActual;

  Habit({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tipo,
    this.metaObjetivo,
    required this.fechaCreacion,
    required this.rachaActual,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      tipo: json['tipo'] as String,
      metaObjetivo: json['meta_objetivo'] as int?,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      rachaActual: json['racha_actual'] as int? ?? 0, // Asignamos 0 si es nulo
    );
  }

  // --- AÑADIDO: Método para convertir el objeto a un Map (JSON) ---
  /// Convierte la instancia de Habit a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo': tipo,
      'meta_objetivo': metaObjetivo,
      // No incluimos id, fechaCreacion o rachaActual porque generalmente
      // son gestionados por el backend y no se envían al crear/actualizar.
    };
  }
}
