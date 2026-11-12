import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/maze_level.dart';

class ProgressData {
  const ProgressData({required this.unlockedLevel, required this.bestTimes});

  final int unlockedLevel;
  final Map<int, int> bestTimes;
}

class ProgressService {
  static const _unlockedKey = 'unlocked_level';
  static const _bestTimePrefix = 'best_time_level_';
  static final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static Future<ProgressData> load() async {
    final unlocked = await _preferences.getInt(_unlockedKey) ?? 1;
    final bestTimes = <int, int>{};
    for (var level = 1; level <= mazeLevelCount; level++) {
      final bestTime = await _preferences.getInt('$_bestTimePrefix$level');
      if (bestTime != null) {
        bestTimes[level] = bestTime;
      }
    }
    return ProgressData(
      unlockedLevel: unlocked.clamp(1, mazeLevelCount).toInt(),
      bestTimes: bestTimes,
    );
  }

  static Future<void> completeLevel({
    required int level,
    required int elapsedSeconds,
  }) async {
    final currentUnlocked = await _preferences.getInt(_unlockedKey) ?? 1;
    final nextUnlocked = level < mazeLevelCount ? level + 1 : mazeLevelCount;
    await _preferences.setInt(_unlockedKey, max(currentUnlocked, nextUnlocked));

    final key = '$_bestTimePrefix$level';
    final previousBest = await _preferences.getInt(key);
    if (previousBest == null || elapsedSeconds < previousBest) {
      await _preferences.setInt(key, elapsedSeconds);
    }
  }

  static Future<void> clearProgress() async {
    await _preferences.clear();
  }
}
