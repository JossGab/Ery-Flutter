import 'dart:async';
import 'dart:ui';
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
      icon: const Icon(Icons.person_add_alt),
      label: const Text("Agregar"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _statusButton(IconData icon, String text, Color color) {
    return ElevatedButton.icon(
      onPressed: null,
      icon: Icon(icon, color: Colors.white),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: color.withOpacity(0.4),
        disabledForegroundColor: Colors.white,
      ),
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
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o email',
              hintStyle: const TextStyle(color: Colors.white60),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        Expanded(
          child: Consumer<FriendsProvider>(
            builder: (context, provider, child) {
              if (provider.isLoadingSearch) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (provider.searchResults.isEmpty &&
                  _searchController.text.isNotEmpty) {
                return const Center(
                  child: Text(
                    'No se encontraron usuarios.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: provider.searchResults.length,
                itemBuilder: (context, index) {
                  final user = provider.searchResults[index];
                  final userName = user?['nombre'] ?? 'Usuario';
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent.withOpacity(
                                0.2,
                              ),
                              child: Text(
                                userName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            trailing: _buildActionButton(
                              provider,
                              user,
                              currentUserId,
                            ),
                          ),
                        ),
                      ),
                    ),
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
