// lib/views/rankings/rankings_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rankings_provider.dart';
import '../../providers/auth_provider.dart'; // Para saber quién es el usuario actual

class RankingsView extends StatelessWidget {
  const RankingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para escuchar los cambios del RankingsProvider
    return Consumer<RankingsProvider>(
      builder: (context, rankingsProvider, child) {
        final currentUserId = context.watch<AuthProvider>().user?.id;

        return DefaultTabController(
          length: 2, // Dos pestañas: Global y País
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: const Color(0xFF1B1D2A),
              automaticallyImplyLeading: false, // Ocultamos el botón de atrás
              flexibleSpace: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TabBar(tabs: [Tab(text: '🏆 Global'), Tab(text: '🌎 País')]),
                ],
              ),
              // Al cambiar de pestaña, llamamos al método setScope del provider
              // No es necesario hacerlo explícitamente, ya que el TabBarController lo manejará internamente
              // si lo conectamos a un listener, pero para este caso, podemos usar on-tap.
            ),
            body: TabBarView(
              children: [
                // Vista para el ranking Global
                _RankingList(
                  key: const PageStorageKey('global_ranking'),
                  scope: 'global',
                ),
                // Vista para el ranking por País
                _RankingList(
                  key: const PageStorageKey('country_ranking'),
                  scope: 'country',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Widget reutilizable para mostrar la lista de rankings
class _RankingList extends StatefulWidget {
  final String scope;
  const _RankingList({super.key, required this.scope});

  @override
  State<_RankingList> createState() => __RankingListState();
}

class __RankingListState extends State<_RankingList> {
  @override
  void initState() {
    super.initState();
    // Cargamos los datos para este scope específico al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RankingsProvider>();
      provider.setScope(widget.scope);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rankingsProvider = context.watch<RankingsProvider>();
    final currentUserId = context.watch<AuthProvider>().user?.id;

    if (rankingsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rankingsProvider.error.isNotEmpty) {
      return Center(
        child: Text(
          'Error: ${rankingsProvider.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (rankingsProvider.rankings.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos en la clasificación.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => rankingsProvider.fetchRankings(),
      child: ListView.builder(
        itemCount: rankingsProvider.rankings.length,
        itemBuilder: (context, index) {
          final rankedUser = rankingsProvider.rankings[index];
          // Verificamos si esta fila corresponde al usuario actual
          final isCurrentUser = rankedUser.userId.toString() == currentUserId;

          return Card(
            color:
                isCurrentUser
                    ? Colors.indigo.withOpacity(0.5)
                    : const Color(0xFF1F2937),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: Text(
                '#${index + 1}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? Colors.amber : Colors.white,
                ),
              ),
              title: Text(
                rankedUser.nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Text(
                '${rankedUser.score} días',
                style: const TextStyle(color: Colors.amberAccent, fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
