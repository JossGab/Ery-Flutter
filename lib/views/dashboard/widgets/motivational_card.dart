import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MotivationalCard extends StatefulWidget {
  const MotivationalCard({super.key});

  @override
  State<MotivationalCard> createState() => _MotivationalCardState();
}

class _MotivationalCardState extends State<MotivationalCard> {
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
    _displayQuote = _randomQuote();
  }

  String _randomQuote() {
    return _quotes[Random().nextInt(_quotes.length)];
  }

  void _nextQuote() {
    setState(() {
      _displayQuote = _randomQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (_) => _nextQuote(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF818CF8).withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(14),
                  child: const Icon(
                    Icons.format_quote_rounded,
                    color: Color(0xFF818CF8),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      constraints: const BoxConstraints(maxWidth: 380),
                      alignment: Alignment.center,
                      child: Text(
                        _displayQuote,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
