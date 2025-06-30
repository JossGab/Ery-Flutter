import 'dart:math';
import 'package:flutter/material.dart';

class MotivationalCard extends StatefulWidget {
  const MotivationalCard({super.key});

  @override
  State<MotivationalCard> createState() => _MotivationalCardState();
}

class _MotivationalCardState extends State<MotivationalCard> {
  // Lista de 20 frases motivadoras
  static const List<String> _quotes = [
    "La disciplina es el puente entre las metas y los logros.",
    "El secreto del éxito es la constancia en el propósito.",
    "Cae siete veces, levántate ocho.",
    "El futuro depende de lo que hagas hoy.",
    "No cuentes los días, haz que los días cuenten.",
    "La mejor forma de predecir el futuro es creándolo.",
    "Un pequeño progreso cada día suma grandes resultados.",
    "La voluntad de ganar es importante, pero la voluntad de prepararse es vital.",
    "Cree que puedes y ya estarás a medio camino.",
    "La acción es la clave fundamental de todo éxito.",
    "El dolor que sientes hoy será la fuerza que sentirás mañana.",
    "No tengas miedo de renunciar a lo bueno para ir por lo grandioso.",
    "El éxito no es el final, el fracaso no es la ruina, el coraje de continuar es lo que cuenta.",
    "Tu único límite es tu mente.",
    "La motivación nos impulsa a comenzar y el hábito nos permite continuar.",
    "Si buscas resultados distintos, no hagas siempre lo mismo.",
    "La vida es un 10% lo que te pasa y un 90% cómo reaccionas a ello.",
    "El experto en algo fue una vez un principiante.",
    "No esperes. El momento nunca será el 'perfecto'.",
    "Haz de cada día tu obra maestra.",
  ];

  late String _displayQuote;

  @override
  void initState() {
    super.initState();
    // Al iniciar el widget, seleccionamos una frase al azar
    _displayQuote = _quotes[Random().nextInt(_quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: Color(0xFF818CF8),
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            _displayQuote,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.5, // Espacio entre líneas para mejor lectura
            ),
          ),
        ],
      ),
    );
  }
}
