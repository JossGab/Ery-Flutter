// lib/views/friends/tabs/search_users_tab.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/friends_provider.dart';
import '../../../providers/auth_provider.dart';

class SearchUsersTab extends StatefulWidget {
  const SearchUsersTab({super.key});

  @override
  State<SearchUsersTab> createState() => _SearchUsersTabState();
}

class _SearchUsersTabState extends State<SearchUsersTab> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Ejecuta la búsqueda con un pequeño retraso para no sobrecargar la API.
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (mounted) {
        context.read<FriendsProvider>().searchUsers(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el ID del usuario actual para no mostrarlo en los resultados.
    final currentUserId = context.watch<AuthProvider>().user?.id;

    return Column(
      children: [
        // --- MEJORA: Campo de búsqueda rediseñado ---
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o email...',
              hintStyle: const TextStyle(color: Colors.white60),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        // --- MEJORA: Lista de resultados con estados y diseño mejorados ---
        Expanded(
          child: Consumer<FriendsProvider>(
            builder: (context, provider, child) {
              if (provider.isLoadingSearch) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.searchResults.isEmpty) {
                return _buildInitialOrEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                itemCount: provider.searchResults.length,
                itemBuilder: (context, index) {
                  final user = provider.searchResults[index];
                  return _UserResultCard(
                        user: user,
                        provider: provider,
                        currentUserId: currentUserId,
                      )
                      .animate()
                      .fadeIn(delay: (50 * index).ms, duration: 400.ms)
                      .slideX(begin: 0.2, curve: Curves.easeOut);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Muestra un estado inicial o de "no se encontraron resultados".
  Widget _buildInitialOrEmptyState() {
    // Si el campo de búsqueda está vacío, muestra un mensaje inicial.
    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 80, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'Encuentra nuevos amigos',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escribe en la barra superior para buscar.',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ],
        ),
      ).animate().fadeIn();
    }
    // Si se ha buscado algo pero no hay resultados.
    return Center(
      child: Text(
        'No se encontraron usuarios.',
        style: GoogleFonts.poppins(color: Colors.white70),
      ),
    );
  }
}

/// --- MEJORA: Widget para la tarjeta de resultado de usuario ---
class _UserResultCard extends StatelessWidget {
  final dynamic user;
  final FriendsProvider provider;
  final String? currentUserId;

  const _UserResultCard({
    required this.user,
    required this.provider,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final userName = user?['nombre'] ?? 'Usuario';

    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.indigoAccent.withOpacity(0.2),
          child: Text(
            userName[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.indigoAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          userName,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: _buildActionButton(context),
      ),
    );
  }

  /// Construye el botón de acción correcto (Agregar, Pendiente, Amigo).
  Widget _buildActionButton(BuildContext context) {
    if (user == null ||
        user['id'] == null ||
        user['id'].toString() == currentUserId) {
      return const SizedBox.shrink();
    }

    final userId = user['id'];
    final isFriend = provider.friends.any((friend) => friend?['id'] == userId);
    if (isFriend) {
      return _statusButton(Icons.check_circle, 'Amigo', Colors.greenAccent);
    }

    final hasSentRequest = provider.sentInvitations.any(
      (req) => req?['solicitado_id'] == userId,
    );
    if (hasSentRequest) {
      return _statusButton(
        Icons.hourglass_top,
        'Pendiente',
        Colors.orangeAccent,
      );
    }

    return ElevatedButton.icon(
      onPressed: () {
        provider.sendFriendInvitation(userId).then((success) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Solicitud enviada!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      },
      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
      label: const Text("Agregar"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Botón de estado para 'Amigo' o 'Pendiente'.
  Widget _statusButton(IconData icon, String text, Color color) {
    return ElevatedButton.icon(
      onPressed: null, // Deshabilitado
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: color.withOpacity(0.2),
        disabledForegroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
