/*
================================================================================
 ARCHIVO: lib/views/profile/profile_view.dart (Versión Actualizada)
================================================================================
*/
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'edit_profile_view.dart';

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
      backgroundColor: const Color(0xFF0E0F1A),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person_outline,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    user.name ?? 'Nombre no disponible',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Colors.white24),
                  _buildInfoTile(
                    Icons.shield_outlined,
                    "Rol",
                    user.roles.isNotEmpty ? user.roles.join(', ') : "Sin rol",
                  ),
                  _buildInfoTile(Icons.numbers, "ID de Usuario", user.id),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: Colors.white60),
      title: Text(title, style: const TextStyle(color: Colors.white54)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
