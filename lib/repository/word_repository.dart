import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

/// Repository responsible for loading words and providing random words.
class WordRepository {
  final List<String> _words;

  WordRepository._(this._words);

  /// Loads the word list from the given asset path.
  static Future<WordRepository> loadFromAssets(String path) async {
    final content = await rootBundle.loadString(path);
    final words = content
        .split('\n')
        .map((e) => e.trim().toLowerCase())
        .where((w) => w.length == 5)
        .toList();
    return WordRepository._(words);
  }

  /// Returns a random 5‑letter word from the list.
  String randomWord() {
    final rand = Random();
    return _words[rand.nextInt(_words.length)];
  }

  /// Returns true if [word] exists in the list (case‑insensitive).
  bool isValidWord(String word) {
    return _words.contains(word.toLowerCase());
  }
}
