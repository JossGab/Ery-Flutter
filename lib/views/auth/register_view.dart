import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  DateTime? _birthDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).register(
        name: '${_nameController.text} ${_lastNameController.text}'.trim(),
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro exitoso! Por favor, inicia sesión.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: const Color(0xFF0E0F1A)),

          // Capa borrosa de fondo
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "Crear una nueva cuenta",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        child: const Text.rich(
                          TextSpan(
                            text: "¿Ya tienes una cuenta? ",
                            style: TextStyle(color: Colors.white60),
                            children: [
                              TextSpan(
                                text: "Inicia sesión aquí",
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Inicio de sesión con Google no disponible temporalmente.',
                              ),
                            ),
                          );
                        },
                        icon: Image.network(
                          'https://img.icons8.com/color/48/google-logo.png',
                          width: 20,
                          height: 20,
                        ),
                        label: const Text("Registrarse con Google"),
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
                              "O continuar con correo",
                              style: TextStyle(color: Colors.white60),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField("Nombre *", _nameController)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField("Apellido", _lastNameController)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField("Correo Electrónico *", _emailController,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField("Contraseña *", _passwordController,
                                obscure: true),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField("Confirmar Contraseña *",
                                _confirmPasswordController,
                                obscure: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Información Adicional (opcional)",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDatePicker(),
                      const SizedBox(height: 16),
                      _buildTextField("Teléfono", _phoneController,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildTextField("Dirección", _addressController),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField("Ciudad", _cityController)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField("País", _countryController)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                minimumSize: const Size.fromHeight(50),
                              ),
                              child: const Text(
                                "Registrarse",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (label.contains('*') && (value == null || value.isEmpty)) {
          return 'Campo obligatorio';
        }
        if (label.contains('Correo') && value != null && !value.contains('@')) {
          return 'Email no válido.';
        }
        if (label.contains('Contraseña *') && value != null && value.length < 8) {
          return 'Mínimo 8 caracteres.';
        }
        if (label.contains('Confirmar') && value != _passwordController.text) {
          return 'Las contraseñas no coinciden.';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Colors.blueAccent,
                  onPrimary: Colors.white,
                  surface: Color(0xFF1B1D2A),
                  onSurface: Colors.white,
                ),
                dialogBackgroundColor: const Color(0xFF0E0F1A),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() => _birthDate = date);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Text(
              _birthDate == null
                  ? 'Fecha de nacimiento'
                  : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
              style: const TextStyle(color: Colors.white70),
            ),
            const Spacer(),
            const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
