import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
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
                    "Crear una nueva cuenta",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: const Text.rich(
                      TextSpan(
                        text: "¿Ya tienes una cuenta? ",
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

                  // Botón Google
                  ElevatedButton.icon(
                    onPressed: () {},
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
                      Expanded(
                        child: _buildTextField("Nombre *", _nameController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField("Apellido", _lastNameController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildTextField("Correo Electrónico *", _emailController),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          "Contraseña *",
                          _passwordController,
                          obscure: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          "Confirmar Contraseña *",
                          _confirmPasswordController,
                          obscure: true,
                        ),
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
                  _buildTextField("Teléfono", _phoneController),
                  const SizedBox(height: 16),
                  _buildTextField("Dirección", _addressController),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField("Ciudad", _cityController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField("País", _countryController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text("Crear Cuenta con Email"),
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
        if (label.contains('*') && (value == null || value.isEmpty)) {
          return 'Campo obligatorio';
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
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(data: ThemeData.dark(), child: child!);
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
