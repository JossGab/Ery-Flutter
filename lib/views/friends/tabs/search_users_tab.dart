import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      context.read<FriendsProvider>().searchUsers(query);
    });
  }

  Widget _buildActionButton(
    FriendsProvider provider,
    dynamic user,
    String? currentUserId,
  ) {
    if (user == null ||
        user['id'] == null ||
        user['id'].toString() == currentUserId) {
      return const SizedBox.shrink();
    }
    final userId = user['id'];

    // 1. Verificar si ya es amigo
    final isFriend = provider.friends.any((friend) => friend?['id'] == userId);
    if (isFriend) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        label: const Text('Amigo'),
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.green.withOpacity(0.4),
          disabledForegroundColor: Colors.white,
        ),
      );
    }

    // --- CORRECCIÓN CLAVE ---
    // Se verifica la clave 'solicitado_id' directamente.
    final hasSentRequest = provider.sentInvitations.any(
      (req) => req?['solicitado_id'] == userId,
    );
    // --- FIN DE LA CORRECCIÓN ---

    if (hasSentRequest) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.hourglass_top, color: Colors.white),
        label: const Text('Pendiente'),
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.orange.withOpacity(0.4),
          disabledForegroundColor: Colors.white,
        ),
      );
    }

    return ElevatedButton(
      onPressed: () {
        provider.sendFriendInvitation(userId).then((success) {
          if (mounted && success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Solicitud enviada!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      },
      child: const Text('Agregar'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthProvider>().user?.id;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar por nombre o email',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        Expanded(
          child: Consumer<FriendsProvider>(
            builder: (context, provider, child) {
              if (provider.isLoadingSearch) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.searchResults.isEmpty &&
                  _searchController.text.isNotEmpty) {
                return const Center(
                  child: Text(
                    'No se encontraron usuarios.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return ListView.builder(
                itemCount: provider.searchResults.length,
                itemBuilder: (context, index) {
                  final user = provider.searchResults[index];
                  // El filtrado del propio usuario se hace ahora en _buildActionButton
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user?['nombre']?[0].toUpperCase() ?? '?'),
                    ),
                    title: Text(
                      user?['nombre'] ?? 'Usuario no válido',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: _buildActionButton(provider, user, currentUserId),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
