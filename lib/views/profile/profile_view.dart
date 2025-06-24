import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart'; // Asegúrate de importar tu modelo de usuario

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario del AuthProvider
    final User? user = Provider.of<AuthProvider>(context).user;

    // Si por alguna razón el usuario es nulo, mostramos un mensaje.
    if (user == null) {
      return const Center(
        child: Text("No se pudieron cargar los datos del usuario."),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Para que tome el color del layout
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFF1B1D2A),
                child: Icon(
                  Icons.person_outline,
                  size: 70,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                // --- CORRECCIÓN ---
                // Si user.name es nulo, muestra 'Nombre no disponible'
                user.name ?? 'Nombre no disponible',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                // --- CORRECCIÓN ---
                user.email ?? 'Email no disponible',
                style: const TextStyle(fontSize: 16, color: Colors.white60),
              ),
              const SizedBox(height: 32),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              // --- CORRECCIÓN ---
              // Manejamos la posibilidad de que roles sea nulo o vacío
              _buildProfileInfoTile(
                Icons.shield_outlined,
                "Rol",
                user.roles.isNotEmpty ? user.roles.join(', ') : 'No asignado',
              ),
              _buildProfileInfoTile(
                Icons.numbers,
                "ID de Usuario",
                user.id ?? 'N/A',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
