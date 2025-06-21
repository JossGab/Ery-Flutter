import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? error;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacementNamed(context, '/dashboard');

    setState(() => isLoading = false);
  }

  Future<void> _signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      print("Usuario de Google: ${googleUser.email}");
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1D2A),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    "Iniciar Sesión",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: const Text.rich(
                      TextSpan(
                        text: "¿No tienes una cuenta? ",
                        children: [
                          TextSpan(
                            text: "Regístrate aquí",
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: Image.network(
                      'https://img.icons8.com/color/48/google-logo.png',
                      width: 20,
                      height: 20,
                    ),
                    label: const Text("Iniciar sesión con Google"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "O con correo electrónico",
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildTextField("Correo Electrónico", _emailController),
                  const SizedBox(height: 16),

                  _buildTextField(
                    "Contraseña",
                    _passwordController,
                    obscure: true,
                  ),
                  const SizedBox(height: 24),

                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),

                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text("Ingresar"),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obligatorio';
        if (label.contains('Contraseña') && value.length < 6) {
          return 'Mínimo 6 caracteres';
        }
        return null;
      },
    );
  }
}
