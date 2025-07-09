import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rankings_provider.dart';
import '../../providers/auth_provider.dart';

class RankingsView extends StatelessWidget {
  const RankingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RankingsProvider>(
      builder: (context, rankingsProvider, child) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: const Color(0xFF1B1D2A),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: const Border(
                    bottom: BorderSide(color: Colors.white24, width: 0.5),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const TabBar(
                        indicator: BoxDecoration(
                          color: Colors.amberAccent,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.white70,
                        labelStyle: TextStyle(fontWeight: FontWeight.w600),
                        tabs: [Tab(text: '🏆 Global'), Tab(text: '🌎 País')],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: const TabBarView(
              children: [
                _RankingList(
                  scope: 'global',
                  key: PageStorageKey('global_ranking'),
                ),
                _RankingList(
                  scope: 'country',
                  key: PageStorageKey('country_ranking'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RankingsProvider>().setScope(widget.scope);
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
          style: const TextStyle(color: Colors.redAccent),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        itemBuilder: (context, index) {
          final user = rankingsProvider.rankings[index];
          final isCurrentUser = user.userId.toString() == currentUserId;

          final place = switch (index) {
            0 => '🥇',
            1 => '🥈',
            2 => '🥉',
            _ => '#${index + 1}',
          };

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color:
                  isCurrentUser
                      ? Colors.amber.withOpacity(0.25)
                      : Colors.white.withOpacity(0.04),
              border: Border.all(color: Colors.white24, width: 0.6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white10,
                    child: Text(
                      place,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  title: Text(
                    user.nombre,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.amber : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Text(
                    '${user.score} días',
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
