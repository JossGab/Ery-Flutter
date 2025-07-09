// lib/views/rankings/rankings_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/rankings_provider.dart';
import '../../providers/auth_provider.dart';

class RankingsView extends StatefulWidget {
  const RankingsView({super.key});

  @override
  State<RankingsView> createState() => _RankingsViewState();
}

class _RankingsViewState extends State<RankingsView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // --- MEJORA: AppBar rediseñado con BackdropFilter y TabBar corregido ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.05),
              automaticallyImplyLeading: false,
              elevation: 0,
              title: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'Clasificación',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              centerTitle: true,
              bottom: TabBar(
                controller: _tabController,
                // --- INICIO DE LA CORRECCIÓN ---
                indicatorSize:
                    TabBarIndicatorSize
                        .tab, // Asegura que el indicador ocupe toda la pestaña
                indicatorPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.amberAccent,
                ),
                // --- FIN DE LA CORRECCIÓN ---
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white70,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                unselectedLabelStyle: GoogleFonts.poppins(),
                tabs: const [Tab(text: '🏆 Global'), Tab(text: '🌎 País')],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _RankingList(scope: 'global', key: PageStorageKey('global_ranking')),
          _RankingList(
            scope: 'country',
            key: PageStorageKey('country_ranking'),
          ),
        ],
      ),
    );
  }
}

/// Widget que muestra la lista de ranking para un 'scope' específico.
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
      // Establece el scope y carga los datos iniciales
      context.read<RankingsProvider>().setScope(widget.scope);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos 'select' para escuchar solo los cambios relevantes y evitar reconstrucciones innecesarias
    final provider = context.select((RankingsProvider p) => p);
    final currentUserId = context.select((AuthProvider a) => a.user?.id);

    if (provider.isLoading && provider.scope == widget.scope) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error.isNotEmpty && provider.scope == widget.scope) {
      return Center(
        child: Text(
          'Error: ${provider.error}',
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (provider.rankings.isEmpty && provider.scope == widget.scope) {
      return const Center(
        child: Text(
          'No hay datos en la clasificación.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Solo mostramos la lista si el scope del provider coincide con el de este widget
    if (provider.scope != widget.scope) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchRankings(),
      child: ListView.builder(
        itemCount: provider.rankings.length,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
        itemBuilder: (context, index) {
          final user = provider.rankings[index];
          final isCurrentUser = user.userId.toString() == currentUserId;

          final place = switch (index) {
            0 => '🥇',
            1 => '🥈',
            2 => '🥉',
            _ => '#${index + 1}',
          };

          // --- MEJORA: Tarjeta de usuario con diseño premium ---
          return Card(
                elevation: 0,
                color:
                    isCurrentUser
                        ? Colors.amber.withOpacity(0.15)
                        : Colors.white.withOpacity(0.05),
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side:
                      isCurrentUser
                          ? const BorderSide(color: Colors.amber, width: 1.5)
                          : BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Text(
                    place,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          isCurrentUser ? Colors.amber.shade200 : Colors.white,
                    ),
                  ),
                  title: Text(
                    user.nombre,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Text(
                    '${user.score} días',
                    style: GoogleFonts.poppins(
                      color: isCurrentUser ? Colors.white : Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: (50 * index).ms, duration: 400.ms)
              .slideX(begin: 0.2, curve: Curves.easeOut);
        },
      ),
    );
  }
}
