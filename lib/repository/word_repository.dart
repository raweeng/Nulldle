import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

/// Repository responsible for loading words and providing random words.
class WordRepository {
  final List<String> _words;

  WordRepository._(this._words);

  /// Creates a repository from a pre-defined list of words. This factory
  /// normalises all words to lower-case and ensures only five-letter words
  /// are included. It is useful in tests where a real dictionary is not
  /// available.
  factory WordRepository.fromWords(List<String> words) {
    final filtered = words
        .map((w) => w.trim().toLowerCase())
        .where((w) => w.length == 5)
        .toList();
    return WordRepository._(filtered);
  }

  /// Creates an empty repository. This is primarily intended for tests
  /// where no valid words are required. Random word selection will throw
  /// if called on an empty repository.
  factory WordRepository.empty() => WordRepository._(<String>[]);

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

  /// Returns true if [word] exists in the list (case-insensitive).
  bool isValidWord(String word) {
    return _words.contains(word.toLowerCase());
  }
}
