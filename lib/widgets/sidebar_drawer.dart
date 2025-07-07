import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
import '../providers/auth_provider.dart';

class SidebarDrawer extends StatelessWidget {
  final SidebarXController controller;
  final void Function(int index)? onItemSelected;

  const SidebarDrawer({
    super.key,
    required this.controller,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white10),
            ),
            child: SidebarX(
              controller: controller,
              showToggleButton: false,
              extendedTheme: SidebarXTheme(
                width: 240,
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
                decoration: const BoxDecoration(color: Colors.transparent),
              ),
              headerBuilder:
                  (context, extended) => Padding(
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
              items: [
                SidebarXItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Mi Dashboard',
                  onTap: () {
                    onItemSelected?.call(0);
                    Navigator.of(context).pop(); // ✅ Oculta el Drawer
                  },
                ),
                SidebarXItem(
                  icon: Icons.edit_note_rounded,
                  label: 'Mis Hábitos',
                  onTap: () {
                    onItemSelected?.call(1);
                    Navigator.of(context).pop();
                  },
                ),
                SidebarXItem(
                  icon: Icons.all_inclusive_rounded,
                  label: 'Mis Rutinas',
                  onTap: () {
                    onItemSelected?.call(2);
                    Navigator.of(context).pop();
                  },
                ),
                SidebarXItem(
                  icon: Icons.emoji_events_rounded,
                  label: 'Mis Logros',
                  onTap: () {
                    onItemSelected?.call(3);
                    Navigator.of(context).pop();
                  },
                ),
                SidebarXItem(
                  icon: Icons.leaderboard_rounded,
                  label: 'Rankings',
                  onTap: () {
                    onItemSelected?.call(4);
                    Navigator.of(context).pop();
                  },
                ),
                SidebarXItem(
                  icon: Icons.groups_rounded,
                  label: 'Comunidad',
                  onTap: () {
                    onItemSelected?.call(5);
                    Navigator.of(context).pop();
                  },
                ),
                SidebarXItem(
                  icon: Icons.emoji_events_outlined,
                  label: 'Competiciones',
                  onTap: () {
                    onItemSelected?.call(6);
                    Navigator.of(context).pop();
                  },
                ),
                SidebarXItem(
                  icon: Icons.person_rounded,
                  label: 'Mi Perfil',
                  onTap: () {
                    onItemSelected?.call(7);
                    Navigator.of(context).pop();
                  },
                ),
              ],
              footerBuilder:
                  (context, extended) => Column(
                    children: [
                      const Divider(color: Colors.white12),
                      ListTile(
                        leading: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                        ),
                        title:
                            extended
                                ? const Text(
                                  "Cerrar Sesión",
                                  style: TextStyle(color: Colors.white),
                                )
                                : null,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (_) => BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: AlertDialog(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.08,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
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
                                        child: const Text(
                                          "Cancelar",
                                          style: TextStyle(
                                            color: Colors.white54,
                                          ),
                                        ),
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                      ),
                                      TextButton(
                                        child: const Text(
                                          "Cerrar sesión",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
                                      ),
                                    ],
                                  ),
                                ),
                          );

                          if (confirm == true && context.mounted) {
                            await context.read<AuthProvider>().logout();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
