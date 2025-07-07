// lib/views/friends/tabs/my_friends_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // Cargamos la lista de amigos al iniciar la pestaña
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendsProvider>().fetchFriends();
    });
  }

  void _showDeleteConfirmation(BuildContext context, dynamic friend) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Eliminar Amigo'),
            content: Text(
              '¿Estás seguro de que quieres eliminar a ${friend['nombre']} de tu lista de amigos?',
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
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
          return const Center(
            child: Text(
              'Aún no tienes amigos. ¡Busca y añade a alguien!',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchFriends(),
          child: ListView.builder(
            itemCount: provider.friends.length,
            itemBuilder: (context, index) {
              final friend = provider.friends[index];
              return Card(
                color: const Color(0xFF1F2937),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(friend['nombre'][0].toUpperCase()),
                  ),
                  title: Text(
                    friend['nombre'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    friend['email'],
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white54),
                    onPressed: () => _showDeleteConfirmation(context, friend),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
