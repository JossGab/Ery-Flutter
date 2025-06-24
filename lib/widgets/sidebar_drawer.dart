import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

import '../providers/auth_provider.dart';

class SidebarDrawer extends StatelessWidget {
  final SidebarXController controller;

  const SidebarDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: SidebarX(
          controller: controller,
          showToggleButton: false, // 🚫 ELIMINA LA FLECHITA
          extendedTheme: SidebarXTheme(
            width: 240,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white12),
            ),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemTextPadding: const EdgeInsets.only(left: 12),
            selectedItemTextPadding: const EdgeInsets.only(left: 12),
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
          headerBuilder: (context, extended) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                if (extended) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user?.name ?? 'Usuario',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          items: const [
            SidebarXItem(icon: Icons.home_rounded, label: 'Inicio'),
            SidebarXItem(icon: Icons.dashboard_rounded, label: 'Mi Dashboard'),
            SidebarXItem(icon: Icons.person_rounded, label: 'Mi Perfil'),
            SidebarXItem(icon: Icons.edit_note_rounded, label: 'Mis Hábitos'),
          ],
          footerBuilder: (context, extended) => Column(
            children: [
              const Divider(color: Colors.white12),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.white),
                title: extended
                    ? const Text("Cerrar Sesión",
                        style: TextStyle(color: Colors.white))
                    : null,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF1B1D2A),
                      title: const Text(
                        "¿Cerrar sesión?",
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        "¿Estás seguro de que deseas cerrar sesión?",
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Cancelar"),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        TextButton(
                          child: const Text("Cerrar sesión"),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await context.read<AuthProvider>().logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: () => controller.toggleExtended(),
                icon: const Icon(Icons.menu, color: Colors.white),
                tooltip: 'Expandir/Colapsar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
