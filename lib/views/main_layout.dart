import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

// Importamos las vistas que vamos a manejar
import '../widgets/sidebar_drawer.dart';
import 'dashboard/dashboard_view.dart';
import 'profile/profile_view.dart';
import 'profile/edit_profile_view.dart';

// ===================================================================
// CAMBIO 1: Se importa la vista de hábitos.
// Asegúrate de que la ruta a tu archivo 'habits_view.dart' sea correcta.
// ===================================================================
import 'habits/habits_view.dart';

// --- Placeholder (temporal) ---
// Si ya tienes tu propia HabitsView, puedes eliminar esta clase.
// Esto es solo para asegurar que el código no falle si el archivo aún no existe.
class nada extends StatelessWidget {
  const nada({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Vista de Hábitos (HabitsView)',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
// ------------------------------

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Este "oyente" es clave para que la navegación funcione.
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      key: _key,
      appBar:
          isMobile
              ? AppBar(
                backgroundColor: const Color(0xFF1B1D2A),
                title: const Text(
                  'Ery',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  onPressed: () {
                    _key.currentState?.openDrawer();
                  },
                  icon: const Icon(Icons.menu, color: Colors.white),
                ),
              )
              : null,
      drawer: SidebarDrawer(controller: _controller),
      body: Row(
        children: [
          if (!isMobile) SidebarDrawer(controller: _controller),
          Expanded(child: _getViewForIndex(_controller.selectedIndex)),
        ],
      ),
    );
  }

  /// Devuelve la vista correspondiente al índice seleccionado.
  Widget _getViewForIndex(int index) {
    // --- LÓGICA DE NAVEGACIÓN CORREGIDA ---
    switch (index) {
      case 0:
        return const DashboardView();
      // ===================================================================
      // CAMBIO 2: Se reemplaza 'nada()' por la vista de hábitos correcta.
      // ===================================================================
      case 1: // El índice 1 ahora corresponde a "Mis Hábitos"
        return const HabitsView(); // Si ya tienes tu vista, si no, puedes usar `const nada()` temporalmente.
      case 2:
        return const ProfileView();
      case 3:
        return const EditProfileView();
      default:
        return const Center(
          child: Text(
            "Página no encontrada",
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }
}
