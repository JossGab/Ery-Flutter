// lib/views/friends/tabs/my_friends_tab.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/friends_provider.dart';

class MyFriendsTab extends StatefulWidget {
  const MyFriendsTab({super.key});

  @override
  State<MyFriendsTab> createState() => _MyFriendsTabState();
}

class _MyFriendsTabState extends State<MyFriendsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendsProvider>().fetchFriends();
    });
  }

  void _showDeleteConfirmation(BuildContext context, dynamic friend) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1F2937),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Eliminar Amigo',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              '¿Estás seguro de que quieres eliminar a ${friend['nombre']} de tu lista de amigos?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white54),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  context.read<FriendsProvider>().deleteFriend(friend['id']);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingFriends) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.friends.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchFriends(),
          backgroundColor: Theme.of(context).colorScheme.primary,
          color: Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
            itemCount: provider.friends.length,
            itemBuilder: (context, index) {
              final friend = provider.friends[index];
              return Card(
                    elevation: 0,
                    color: Colors.white.withOpacity(0.05),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent.withOpacity(0.2),
                        child: Text(
                          friend['nombre'][0].toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        friend['nombre'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        friend['email'],
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white54,
                        ),
                        onPressed:
                            () => _showDeleteConfirmation(context, friend),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: (50 * index).ms, duration: 400.ms)
                  .slideX(begin: 0.2, curve: Curves.easeOut);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- INICIO DE LA CORRECCIÓN ---
            const Icon(Icons.person_search, size: 100, color: Colors.white24),
            // --- FIN DE LA CORRECCIÓN ---
            const SizedBox(height: 20),
            Text(
              'Aún no tienes amigos',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Ve a la pestaña "Buscar" para encontrar y añadir a tus compañeros de viaje.',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
      ),
    );
  }
}
