// lib/widgets/custom_sidebar.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class CustomSidebar extends StatelessWidget {
  final Function(int) onItemSelected;
  final String userName;
  final String userRole;

  const CustomSidebar({
    super.key,
    required this.onItemSelected,
    this.userName = "Joseph Tiznado",
    this.userRole = "Usuario",
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userRole,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white12, thickness: 0.5),
                  const SizedBox(height: 12),

                  // Menu Items
                  _buildMenuItem(
                    context,
                    icon: Icons.dashboard_customize_rounded,
                    label: "Mi Dashboard",
                    index: 0,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.track_changes_rounded,
                    label: "Mis Hábitos",
                    index: 1,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.emoji_events_outlined,
                    label: "Mis Logros",
                    index: 2,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    label: "Mi Perfil",
                    index: 3,
                  ),

                  const Spacer(),

                  const Divider(color: Colors.white24, height: 1),

                  // Logout button
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white),
                    title: const Text(
                      "Cerrar Sesión",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      // TODO: Aquí deberías cerrar sesión
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.of(context).pop(); // Oculta el sidebar
        onItemSelected(index);
      },
    );
  }
}
