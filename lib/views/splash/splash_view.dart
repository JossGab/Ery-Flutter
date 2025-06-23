import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen desde URL
          SizedBox.expand(
            child: Image.network(
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=2070&auto=format&fit=crop',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Center(child: Text("Error cargando la imagen")),
            ),
          ),

          // Capa oscura encima de la imagen (¡CORREGIDO!)
          Container(color: const Color.fromRGBO(0, 0, 0, 0.6)),

          // Contenido principal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Ery",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ), // Es bueno definir una fuente consistente
                    children: [
                      TextSpan(
                        text: "Transforma tus Hábitos, ",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: "Eleva tu Vida.",
                        style: TextStyle(color: Color(0xFF6D6DFF)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '"Ery" es tu compañero digital para construir rutinas positivas, superar malos hábitos y gamificar tu progreso personal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D6DFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // ¡CORREGIDO!
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    "Registrarse",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // ¡CORREGIDO!
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    "Iniciar Sesión",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
