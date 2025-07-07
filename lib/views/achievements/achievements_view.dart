// lib/views/achievements/achievements_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/achievement_service.dart';
import '../../models/achievement_model.dart';

class AchievementsView extends StatefulWidget {
  const AchievementsView({super.key});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementService>().fetchAchievements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementService>(
      builder: (context, achievementService, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body:
              achievementService.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : achievementService.error != null
                  ? Center(
                    child: Text(
                      'Error: ${achievementService.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh: () => achievementService.fetchAchievements(),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                          ),
                      itemCount: achievementService.achievements.length,
                      itemBuilder: (context, index) {
                        final achievement =
                            achievementService.achievements[index];
                        return AchievementCard(achievement: achievement);
                      },
                    ),
                  ),
        );
      },
    );
  }
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    // CORRECCIÓN: Se reemplaza el Icon por un Widget que puede ser
    // una imagen de red o un ícono de respaldo.
    Widget iconWidget;
    if (achievement.iconUrl != null && achievement.iconUrl!.isNotEmpty) {
      iconWidget = Image.network(
        achievement.iconUrl!,
        width: 48,
        height: 48,
        color: achievement.isUnlocked ? null : Colors.grey.shade600,
        colorBlendMode: achievement.isUnlocked ? null : BlendMode.saturation,
        errorBuilder:
            (context, error, stackTrace) => Icon(
              Icons.emoji_events_outlined, // Ícono de fallback si la URL falla
              size: 48,
              color:
                  achievement.isUnlocked
                      ? Colors.amber.shade400
                      : Colors.grey.shade600,
            ),
      );
    } else {
      iconWidget = Icon(
        Icons.emoji_events_outlined,
        size: 48,
        color:
            achievement.isUnlocked
                ? Colors.amber.shade400
                : Colors.grey.shade600,
      );
    }

    final cardContent = Container(
      decoration: BoxDecoration(
        color:
            achievement.isUnlocked
                ? const Color(0xFF1F2937)
                : Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              achievement.isUnlocked
                  ? Colors.amber.shade700
                  : Colors.grey.shade800,
          width: achievement.isUnlocked ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget, // Usamos el widget de ícono/imagen que creamos
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    achievement.isUnlocked
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );

    if (!achievement.isUnlocked) {
      return Opacity(opacity: 0.6, child: cardContent);
    }

    return cardContent;
  }
}
