import 'dart:ui';
import 'package:flutter/material.dart';

class CustomSidebar extends StatelessWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;
  final String userName;
  final String userRole;

  const CustomSidebar({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
    this.userName = "Usuario",
    this.userRole = "Miembro",
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
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
                    icon: Icons.auto_graph_rounded,
                    label: "Mis Rutinas",
                    index: 2,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.emoji_events_outlined,
                    label: "Mis Logros",
                    index: 3,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.leaderboard_rounded,
                    label: "Rankings",
                    index: 4,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.group_rounded,
                    label: "Comunidad",
                    index: 5,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.sports_esports,
                    label: "Competiciones",
                    index: 6,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    label: "Mi Perfil",
                    index: 7,
                  ),

                  const Spacer(),
                  const Divider(color: Colors.white24),

                  // Logout
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white),
                    title: const Text(
                      "Cerrar Sesión",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                      // Puedes llamar también a AuthProvider.logout() si lo deseas.
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
    final isSelected = index == selectedIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: isSelected ? Colors.white12 : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.amberAccent : Colors.white,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.amberAccent : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.of(context).pop(); // Oculta el drawer
          onItemSelected(index); // Cambia de pestaña
        },
      ),
    );
  }
}
