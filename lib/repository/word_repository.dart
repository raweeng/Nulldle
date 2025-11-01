import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

/// Repository responsible for loading words and providing random words.
class WordRepository {
  final List<String> _words;

  WordRepository._(this._words);

  factory WordRepository.fromWords(List<String> words) {
    final filtered = words
        .map((w) => w.trim().toLowerCase())
        .where((w) => w.length == 5)
        .toList();
    return WordRepository._(filtered);
  }

  factory WordRepository.empty() => WordRepository._(<String>[]);

  static Future<WordRepository> loadFromAssets(String path) async {
    final content = await rootBundle.loadString(path);
    final words = content
        .split('\n')
        .map((e) => e.trim().toLowerCase())
        .where((w) => w.length == 5)
        .toList();
    return WordRepository._(words);
  }

  String randomWord() {
    final rand = Random();
    return _words[rand.nextInt(_words.length)];
  }

  bool isValidWord(String word) {
    return _words.contains(word.toLowerCase());
  }
}
