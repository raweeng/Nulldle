import 'package:shared_preferences/shared_preferences.dart';

/// Repository responsible for persisting win/loss statistics.
class StatsRepository {
  static const _winsKey = 'wins';
  static const _lossesKey = 'losses';
  static const _gamesKey = 'games';
  static const _incorrectKey = 'incorrectGuesses';
  static const _durationsKey = 'durations';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Records the outcome of a game, including whether the player won and how many
  /// incorrect guesses were made (a loss counts all guesses).
  Future<void> recordResult(
      {required bool win, required int incorrectGuesses}) async {
    final prefs = await _prefs;
    final wins = prefs.getInt(_winsKey) ?? 0;
    final losses = prefs.getInt(_lossesKey) ?? 0;
    final games = prefs.getInt(_gamesKey) ?? 0;
    final list = prefs.getStringList(_incorrectKey) ?? <String>[];
    if (win) {
      await prefs.setInt(_winsKey, wins + 1);
    } else {
      await prefs.setInt(_lossesKey, losses + 1);
    }
    await prefs.setInt(_gamesKey, games + 1);
    list.add(incorrectGuesses.toString());
    await prefs.setStringList(_incorrectKey, list);
  }

  Future<int> get wins async {
    final prefs = await _prefs;
    return prefs.getInt(_winsKey) ?? 0;
  }

  Future<int> get losses async {
    final prefs = await _prefs;
    return prefs.getInt(_lossesKey) ?? 0;
  }

  Future<int> get games async {
    final prefs = await _prefs;
    return prefs.getInt(_gamesKey) ?? 0;
  }

  /// Returns a list of incorrect guesses per game.
  Future<List<int>> get incorrectGuesses async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_incorrectKey) ?? <String>[];
    return list.map((e) => int.tryParse(e) ?? 0).toList();
  }

  /// Records the duration (in milliseconds) taken to finish a game.
  Future<void> recordDuration(int durationMillis) async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_durationsKey) ?? <String>[];
    list.add(durationMillis.toString());
    await prefs.setStringList(_durationsKey, list);
  }

  /// Returns a list of durations (in milliseconds) sorted ascending.
  Future<List<int>> get durations async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_durationsKey) ?? <String>[];
    final ints = list.map((e) => int.tryParse(e) ?? 0).toList();
    ints.sort();
    return ints;
  }
}
