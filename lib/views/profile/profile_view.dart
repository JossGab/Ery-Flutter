/*
================================================================================
 ARCHIVO: lib/views/profile/profile_view.dart (Versión Actualizada)
================================================================================
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'edit_profile_view.dart'; // <-- Importamos la vista de edición

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Center(
        child: Text("No se pudieron cargar los datos del usuario."),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      // --- AÑADIDO ---
      // Botón flotante para acceder a la edición del perfil.
      // Es un estándar de diseño muy reconocible.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Usamos Navigator.push para poner la pantalla de edición ENCIMA de la actual.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileView()),
          );
        },
        label: const Text('Editar Perfil'),
        icon: const Icon(Icons.edit_outlined),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
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
                user.email, // El email no debería ser nulo si el usuario existe
                style: const TextStyle(fontSize: 16, color: Colors.white60),
              ),
              const SizedBox(height: 32),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              _buildProfileInfoTile(
                Icons.shield_outlined,
                "Rol",
                user.roles.isNotEmpty ? user.roles.join(', ') : 'No asignado',
              ),
              _buildProfileInfoTile(Icons.numbers, "ID de Usuario", user.id),
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
