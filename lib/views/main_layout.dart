/*
================================================================================
 ARCHIVO: lib/views/main_layout.dart (Versión Final y Refactorizada)
================================================================================
*/
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

// Vistas
import '../widgets/sidebar_drawer.dart';
import 'dashboard/dashboard_view.dart';
import 'habits/habits_view.dart';
import 'achievements/achievements_view.dart';
import 'profile/profile_view.dart';

class _NavigationItem {
  final String title;
  final Widget view;
  const _NavigationItem({required this.title, required this.view});
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_NavigationItem> _navigationItems = const [
    _NavigationItem(title: 'Mi Dashboard', view: DashboardView()),
    _NavigationItem(title: 'Mis Hábitos', view: HabitsView()),
    _NavigationItem(title: 'Mis Logros', view: AchievementsView()),
    _NavigationItem(title: 'Mi Perfil', view: ProfileView()),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Diálogo de confirmación si el usuario está en la pestaña principal
  Future<bool> _handleBackPress() async {
    if (_controller.selectedIndex == 0) {
      // Si ya estás en Dashboard, mostrar diálogo de salir
      return await _showExitConfirmationDialog();
    } else {
      // Si estás en otra pestaña, volver al Dashboard
      _controller.selectIndex(0);
      return false;
    }
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: AlertDialog(
                  backgroundColor: const Color(0xFF1B1D2A).withOpacity(0.85),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    '¿Salir de la aplicación?',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    '¿Estás seguro de que quieres cerrar Ery?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Salir',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final currentItem = _navigationItems[_controller.selectedIndex];

    return WillPopScope(
      onWillPop:
          _handleBackPress, // <- Aquí controlamos la navegación hacia atrás
      child: Scaffold(
        key: _scaffoldKey,
        appBar:
            isMobile
                ? AppBar(
                  backgroundColor: const Color(0xFF1B1D2A),
                  elevation: 0,
                  title: Text(
                    currentItem.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    icon: const Icon(Icons.menu, color: Colors.white),
                  ),
                )
                : null,
        drawer: SidebarDrawer(controller: _controller),
        body: Row(
          children: [
            if (!isMobile) SidebarDrawer(controller: _controller),
            Expanded(child: currentItem.view),
          ],
        ),
      ),
    );
  }
}
