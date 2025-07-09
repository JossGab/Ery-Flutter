// lib/views/profile/profile_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_view.dart';
// Importamos la StatCard rediseñada
import '../dashboard/widgets/stat_card.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    // Nos aseguramos de que los datos del perfil se carguen al entrar a la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchProfile();
      // También refrescamos los datos del dashboard para tener las estadísticas actualizadas
      context.read<AuthProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileData = authProvider.userProfile;

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Fondo transparente para el layout principal
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileView()),
          ).then((_) {
            // Refresca el perfil al volver de la pantalla de edición
            authProvider.fetchProfile();
          });
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // El RefreshIndicator ahora actualiza tanto el perfil como los hábitos
          await authProvider.fetchProfile();
          await authProvider.fetchDashboardData();
        },
        child:
            authProvider.isLoading && profileData == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 100),
                  children: [
                    // --- Tarjeta principal del perfil rediseñada ---
                    _buildProfileHeader(context, profileData),
                    const SizedBox(height: 24),

                    // --- Sección de Estadísticas ---
                    Text(
                      "Tu Progreso General",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- MEJORA: Fila de StatCards ---
                    Row(
                      children: [
                        StatCard(
                          icon: Icons.checklist_rtl_rounded,
                          title: "Hábitos Activos",
                          value: authProvider.activeHabitsCount.toString(),
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(width: 12),
                        StatCard(
                          icon: Icons.local_fire_department_rounded,
                          title: "Mejor Racha",
                          value: "${authProvider.bestStreak} días",
                          color: Colors.orangeAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const StatCard(
                          icon: Icons.emoji_events_rounded,
                          title: "Logros",
                          value:
                              "0/15", // Este valor puede venir del provider de logros
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 12),
                        const StatCard(
                          icon: Icons.task_alt_rounded,
                          title: "Completados",
                          value: "76%", // Este valor debería ser calculado
                          color: Colors.greenAccent,
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }

  /// Widget para la tarjeta principal del perfil.
  Widget _buildProfileHeader(
    BuildContext context,
    Map<String, dynamic>? profileData,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            children: [
              // Avatar con un borde degradado para un look más premium
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Colors.purpleAccent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF1B1D2A),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 60,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profileData?['nombre'] ?? 'Cargando...',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profileData?['email'] ?? 'Cargando...',
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
