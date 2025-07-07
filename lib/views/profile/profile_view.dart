/*
================================================================================
 ARCHIVO: lib/views/profile/profile_view.dart (Versión con UI ajustada)
================================================================================
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileData = authProvider.userProfile;

    return Scaffold(
      backgroundColor:
          Colors
              .transparent, // Hacemos el fondo transparente para que tome el del MainLayout
      // --- AÑADIDO: Botón flotante para editar ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegamos a la pantalla de edición.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileView()),
          );
        },
        label: const Text('Editar Perfil'),
        icon: const Icon(Icons.edit_outlined),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),

      // --- ELIMINADO: Se quitó el AppBar de aquí ---

      // Si está cargando y no hay datos, muestra un spinner.
      body:
          authProvider.isLoading && profileData == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () => authProvider.fetchProfile(),
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    const SizedBox(
                      height: 20,
                    ), // Espacio superior para compensar la falta de AppBar
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
                    Center(
                      child: Text(
                        profileData?['nombre'] ?? 'Cargando nombre...',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        profileData?['email'] ?? 'Cargando email...',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(color: Colors.white24),
                    _buildInfoTile(
                      Icons.shield_outlined,
                      "Rol",
                      (profileData?['roles'] as List<dynamic>?)?.join(', ') ??
                          'Sin rol',
                    ),
                    _buildInfoTile(
                      Icons.numbers,
                      "ID de Usuario",
                      profileData?['id']?.toString() ?? '--',
                    ),
                    const SizedBox(
                      height: 80,
                    ), // Espacio extra al final para que el FAB no tape contenido
                  ],
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
