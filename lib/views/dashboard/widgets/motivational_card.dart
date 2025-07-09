// lib/views/dashboard/widgets/motivational_card.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Modelo para una frase, permitiendo incluir autor.
class Quote {
  final String text;
  final String author;

  const Quote(this.text, {this.author = "Anónimo"});
}

/// Una tarjeta que muestra una frase motivacional aleatoria cada vez que se construye.
class MotivationalCard extends StatelessWidget {
  const MotivationalCard({super.key});

  // --- MEJORA: Lista de frases ampliada y más variada ---
  static const List<Quote> _quotes = [
    Quote(
      "La disciplina es el puente entre las metas y los logros.",
      author: "Jim Rohn",
    ),
    Quote(
      "El secreto del éxito es la constancia en el propósito.",
      author: "Benjamin Disraeli",
    ),
    Quote("Cae siete veces, levántate ocho.", author: "Proverbio Japonés"),
    Quote("El futuro depende de lo que hagas hoy.", author: "Mahatma Gandhi"),
    Quote(
      "No cuentes los días, haz que los días cuenten.",
      author: "Muhammad Ali",
    ),
    Quote(
      "La mejor forma de predecir el futuro es creándolo.",
      author: "Peter Drucker",
    ),
    Quote("Un pequeño progreso cada día suma grandes resultados."),
    Quote(
      "Cree que puedes y ya estarás a medio camino.",
      author: "Theodore Roosevelt",
    ),
    Quote(
      "La acción es la clave fundamental de todo éxito.",
      author: "Pablo Picasso",
    ),
    Quote("El dolor que sientes hoy será la fuerza que sentirás mañana."),
    Quote("Tu único límite es tu mente."),
    Quote(
      "La motivación nos impulsa a comenzar y el hábito nos permite continuar.",
      author: "Jim Ryun",
    ),
    Quote(
      "El 80% del éxito se basa simplemente en insistir.",
      author: "Woody Allen",
    ),
    Quote("El éxito es la suma de pequeños esfuerzos repetidos día tras día."),
    Quote("No te detengas hasta que te sientas orgulloso."),
    Quote(
      "La pregunta no es quién me va a dejar, es quién me va a detener.",
      author: "Ayn Rand",
    ),
    Quote("Convierte tus heridas en sabiduría.", author: "Oprah Winfrey"),
    Quote("Si no te gustan las cosas, ¡cámbialas! No eres un árbol."),
    Quote(
      "Un objetivo sin un plan es solo un deseo.",
      author: "Antoine de Saint-Exupéry",
    ),
    Quote(
      "La vida se encoge o se expande en proporción al coraje de uno.",
      author: "Anaïs Nin",
    ),
    Quote(
      "Lo que la mente del hombre puede concebir y creer, puede lograr.",
      author: "Napoleon Hill",
    ),
    Quote(
      "El momento en que quieres renunciar es el momento en que debes seguir insistiendo.",
    ),
    Quote(
      "La inspiración existe, pero tiene que encontrarte trabajando.",
      author: "Pablo Picasso",
    ),
    Quote(
      "No juzgues cada día por la cosecha que recoges, sino por las semillas que plantas.",
    ),
  ];

  /// Obtiene una frase aleatoria de la lista.
  Quote _getRandomQuote() {
    return _quotes[Random().nextInt(_quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    // --- MEJORA: Se obtiene una nueva frase cada vez que el widget se redibuja ---
    // Esto sucede al volver al dashboard, garantizando una frase fresca.
    final currentQuote = _getRandomQuote();

    return Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6366F1).withOpacity(0.1),
                const Color(0xFF818CF8).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lightbulb_circle_outlined,
                color: Colors.amberAccent,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                '"${currentQuote.text}"',
                key: ValueKey(
                  currentQuote.text,
                ), // Key para que la animación se reinicie
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ).animate().fadeIn(
                duration: 600.ms,
              ), // Animación sutil de entrada
              const SizedBox(height: 12),
              Text(
                "— ${currentQuote.author}",
                key: ValueKey(currentQuote.author), // Key para la animación
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ).animate().fadeIn(duration: 600.ms),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .move(begin: const Offset(0, 30), curve: Curves.easeOutCubic);
  }
}
