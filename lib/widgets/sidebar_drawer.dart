// sidebar_drawer.dart
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class SidebarDrawer extends StatelessWidget {
  final SidebarXController controller;

  const SidebarDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SidebarX(
        controller: controller,
        theme: SidebarXTheme(
          decoration: const BoxDecoration(color: Color(0xFF1B1D2A)),
          textStyle: const TextStyle(color: Colors.white),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          selectedItemDecoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          iconTheme: const IconThemeData(color: Colors.white54),
          selectedIconTheme: const IconThemeData(color: Colors.white),
        ),
        items: const [
          SidebarXItem(icon: Icons.home_rounded, label: 'Inicio'),
          SidebarXItem(icon: Icons.dashboard_rounded, label: 'Mi Dashboard'),
          SidebarXItem(icon: Icons.person_rounded, label: 'Mi Perfil'),
          SidebarXItem(icon: Icons.edit_note_rounded, label: 'Mis Hábitos'),
        ],
        footerItems: [
          SidebarXItem(
            icon: Icons.logout_rounded,
            label: 'Cerrar Sesión',
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }
}
