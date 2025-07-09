// lib/views/achievements/achievements_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class AchievementsView extends StatelessWidget {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0C0F1A), // Fondo principal
      child: Padding(
        padding: const EdgeInsets.only(
          top: 24,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mis Logros',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemCount: _achievements.length,
                itemBuilder: (context, index) {
                  final achievement = _achievements[index];
                  return _AchievementCard(achievement: achievement);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Achievement {
  final String title;
  final String description;
  final bool unlocked;

  const Achievement({
    required this.title,
    required this.description,
    this.unlocked = false,
  });
}

final List<Achievement> _achievements = [
  Achievement(
    title: 'Semana Perfecta',
    description: 'Mantviste una racha de 7 días.',
    unlocked: true,
  ),
  Achievement(
    title: 'Fuerza de Voluntad',
    description: '15 días sin recaídas.',
    unlocked: false,
  ),
  Achievement(
    title: 'Maratonista de Hábitos',
    description: '50 registros de hábitos.',
    unlocked: false,
  ),
  Achievement(
    title: 'Logro de los 100 días',
    description: '100 días de racha.',
    unlocked: false,
  ),
];

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  achievement.unlocked
                      ? Colors.amber.withOpacity(0.8)
                      : Colors.white10,
              width: 1.5,
            ),
            boxShadow: [
              if (achievement.unlocked)
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                achievement.unlocked
                    ? Icons.emoji_events_rounded
                    : Icons.lock_outline_rounded,
                color: achievement.unlocked ? Colors.amber : Colors.white30,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: achievement.unlocked ? Colors.white : Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: achievement.unlocked ? Colors.white70 : Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
