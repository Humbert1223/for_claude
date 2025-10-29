import 'package:flutter/material.dart';
import 'package:novacole/pages/quiz/models/quiz_user_model.dart';

enum AchievementType {
  firstGame,
  perfectScore,
  speedDemon,
  persistent,
  centurion,
  weekWarrior,
  scholar,
  master,
}

class Achievement {
  final AchievementType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool Function(QuizUser user) checkUnlocked;

  Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.checkUnlocked,
  });
}

class AchievementSystem {
  static final List<Achievement> achievements = [
    Achievement(
      type: AchievementType.firstGame,
      title: 'Premier Pas',
      description: 'Jouer votre première partie',
      icon: Icons.play_circle_outline,
      color: Colors.blue,
      checkUnlocked: (user) => (user.scores?.length ?? 0) >= 1,
    ),
    Achievement(
      type: AchievementType.perfectScore,
      title: 'Parfait !',
      description: 'Obtenir un score de 100%',
      icon: Icons.emoji_events,
      color: Colors.amber,
      checkUnlocked: (user) {
        return user.scores?.any((s) => s.percentage == 100) ?? false;
      },
    ),
    Achievement(
      type: AchievementType.speedDemon,
      title: 'Éclair',
      description: 'Réussir 5 parties avec le chronomètre',
      icon: Icons.timer,
      color: Colors.orange,
      checkUnlocked: (user) {
        return (user.scores?.where((s) => s.usedTimer).length ?? 0) >= 5;
      },
    ),
    Achievement(
      type: AchievementType.persistent,
      title: 'Persévérant',
      description: 'Jouer 10 parties',
      icon: Icons.trending_up,
      color: Colors.green,
      checkUnlocked: (user) => (user.scores?.length ?? 0) >= 10,
    ),
    Achievement(
      type: AchievementType.centurion,
      title: 'Centurion',
      description: 'Jouer 100 parties',
      icon: Icons.military_tech,
      color: Colors.purple,
      checkUnlocked: (user) => (user.scores?.length ?? 0) >= 100,
    ),
    Achievement(
      type: AchievementType.weekWarrior,
      title: 'Guerrier',
      description: 'Jouer pendant 7 jours consécutifs',
      icon: Icons.calendar_today,
      color: Colors.red,
      checkUnlocked: (user) {
        if (user.scores == null || user.scores!.length < 7) return false;

        final sortedDates = user.scores!
            .map((s) => DateTime(s.playedAt.year, s.playedAt.month, s.playedAt.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

        int consecutive = 1;
        for (int i = 0; i < sortedDates.length - 1; i++) {
          final diff = sortedDates[i].difference(sortedDates[i + 1]).inDays;
          if (diff == 1) {
            consecutive++;
            if (consecutive >= 7) return true;
          } else {
            consecutive = 1;
          }
        }
        return false;
      },
    ),
    Achievement(
      type: AchievementType.scholar,
      title: 'Érudit',
      description: 'Moyenne supérieure à 80%',
      icon: Icons.school,
      color: Colors.indigo,
      checkUnlocked: (user) {
        if (user.scores == null || user.scores!.isEmpty) return false;
        final avg = user.scores!.fold<double>(
          0,
              (sum, s) => sum + s.percentage,
        ) /
            user.scores!.length;
        return avg >= 80;
      },
    ),
    Achievement(
      type: AchievementType.master,
      title: 'Maître',
      description: 'Obtenir 3 scores parfaits',
      icon: Icons.stars,
      color: Colors.pink,
      checkUnlocked: (user) {
        return (user.scores?.where((s) => s.percentage == 100).length ?? 0) >= 3;
      },
    ),
  ];

  static List<Achievement> getUnlockedAchievements(QuizUser user) {
    return achievements.where((a) => a.checkUnlocked(user)).toList();
  }

  static List<Achievement> getLockedAchievements(QuizUser user) {
    return achievements.where((a) => !a.checkUnlocked(user)).toList();
  }

  static int getUnlockedCount(QuizUser user) {
    return getUnlockedAchievements(user).length;
  }

  static double getProgressPercentage(QuizUser user) {
    return (getUnlockedCount(user) / achievements.length) * 100;
  }
}