import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/maze_level.dart';

class ProgressData {
  const ProgressData({
    required this.unlockedLevel,
    required this.bestTimes,
    required this.introSeen,
    required this.coins,
    required this.musicVolume,
    required this.sfxVolume,
    required this.controlMode,
    required this.equippedItem,
    required this.ownedItems,
  });

  final int unlockedLevel;
  final Map<int, int> bestTimes;
  final bool introSeen;
  final int coins;
  final double musicVolume;
  final double sfxVolume;
  final String controlMode;
  final String equippedItem;
  final Set<String> ownedItems;
}

class ProgressService {
  static const _unlockedKey = 'unlocked_level';
  static const _bestTimePrefix = 'best_time_level_';
  static const _introSeenKey = 'intro_seen';
  static const _coinsKey = 'coins';
  static const _musicVolumeKey = 'music_volume';
  static const _sfxVolumeKey = 'sfx_volume';
  static const _controlModeKey = 'control_mode';
  static const _equippedItemKey = 'equipped_item';
  static const _ownedItemsKey = 'owned_items';
  static const _rewardClaimedPrefix = 'reward_claimed_level_';
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
    final ownedItems =
        await _preferences.getStringList(_ownedItemsKey) ?? <String>['explorer'];
    return ProgressData(
      unlockedLevel: unlocked.clamp(1, mazeLevelCount).toInt(),
      bestTimes: bestTimes,
      introSeen: await _preferences.getBool(_introSeenKey) ?? false,
      coins: await _preferences.getInt(_coinsKey) ?? 0,
      musicVolume: await _preferences.getDouble(_musicVolumeKey) ?? .7,
      sfxVolume: await _preferences.getDouble(_sfxVolumeKey) ?? .8,
      controlMode: await _preferences.getString(_controlModeKey) ?? 'dpad',
      equippedItem: await _preferences.getString(_equippedItemKey) ?? 'explorer',
      ownedItems: ownedItems.toSet(),
    );
  }

  static Future<int> completeLevel({
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

    final rewardKey = '$_rewardClaimedPrefix$level';
    if (await _preferences.getBool(rewardKey) ?? false) {
      return 0;
    }
    final reward = 25 + level * 10;
    await _preferences.setBool(rewardKey, true);
    await _preferences.setInt(
      _coinsKey,
      (await _preferences.getInt(_coinsKey) ?? 0) + reward,
    );
    return reward;
  }

  static Future<void> setIntroSeen() =>
      _preferences.setBool(_introSeenKey, true);

  static Future<void> setMusicVolume(double value) =>
      _preferences.setDouble(_musicVolumeKey, value.clamp(0, 1).toDouble());

  static Future<void> setSfxVolume(double value) =>
      _preferences.setDouble(_sfxVolumeKey, value.clamp(0, 1).toDouble());

  static Future<void> setControlMode(String value) =>
      _preferences.setString(_controlModeKey, value);

  static Future<void> purchaseAndEquip({
    required String itemId,
    required int price,
  }) async {
    final owned = await _preferences.getStringList(_ownedItemsKey) ??
        <String>['explorer'];
    if (owned.contains(itemId)) {
      await _preferences.setString(_equippedItemKey, itemId);
      return;
    }
    final coins = await _preferences.getInt(_coinsKey) ?? 0;
    if (coins < price) {
      throw StateError('No tienes suficientes monedas.');
    }
    owned.add(itemId);
    await _preferences.setStringList(_ownedItemsKey, owned);
    await _preferences.setInt(_coinsKey, coins - price);
    await _preferences.setString(_equippedItemKey, itemId);
  }

  static Future<void> clearProgress() async {
    await _preferences.clear();
  }
}
