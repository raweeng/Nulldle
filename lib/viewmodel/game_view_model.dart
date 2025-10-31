import 'package:flutter/foundation.dart';
import '../model/guess.dart';
import '../model/letter_result.dart';
import '../model/tile_status.dart';
import '../repository/word_repository.dart';
import '../repository/stats_repository.dart';

/// A ChangeNotifier that contains the core game logic and exposes state to the UI.
class GameViewModel extends ChangeNotifier {
  final WordRepository wordRepository;
  final StatsRepository statsRepository;

  late String _targetWord;
  final List<Guess> _guesses = [];
  String _currentGuess = '';
  bool _isGameOver = false;
  bool _hasWon = false;
  DateTime? _startTime;

  GameViewModel({required this.wordRepository, required this.statsRepository}) {
    _startNewGame();
  }

  List<Guess> get guesses => List.unmodifiable(_guesses);
  String get currentGuess => _currentGuess;
  bool get isGameOver => _isGameOver;
  bool get hasWon => _hasWon;
  String get targetWord => _targetWord;

  /// Handles character input from the UI.
  void updateCurrentGuess(String value) {
    if (_isGameOver) return;
    if (value.length > 5) return;
    _currentGuess = value.toLowerCase();
    notifyListeners();
  }

  /// Submits the current guess, evaluates it and updates state.
  Future<void> submitGuess() async {
    if (_isGameOver) return;
    if (_currentGuess.length != 5) return;
    if (!wordRepository.isValidWord(_currentGuess)) {
      // Invalid word; ignore submission.
      return;
    }
    final results = _evaluateGuess(_currentGuess);
    _guesses.add(Guess(results));
    // Determine outcome
    if (_currentGuess == _targetWord) {
      _isGameOver = true;
      _hasWon = true;
      final incorrectGuesses = _guesses.length;
      await statsRepository.recordResult(
          win: true, incorrectGuesses: incorrectGuesses);
      if (_startTime != null) {
        final durationMs =
            DateTime.now().difference(_startTime!).inMilliseconds;
        await statsRepository.recordDuration(durationMs);
      }
    } else if (_guesses.length >= 6) {
      _isGameOver = true;
      _hasWon = false;
      final incorrectGuesses = _guesses.length;
      await statsRepository.recordResult(
          win: false, incorrectGuesses: incorrectGuesses);
      if (_startTime != null) {
        final durationMs =
            DateTime.now().difference(_startTime!).inMilliseconds;
        await statsRepository.recordDuration(durationMs);
      }
    }
    _currentGuess = '';
    notifyListeners();
  }

  /// Starts a new game by selecting a new target word and resetting state.
  void _startNewGame() {
    _targetWord = wordRepository.randomWord();
    _guesses.clear();
    _currentGuess = '';
    _isGameOver = false;
    _hasWon = false;
    _startTime = DateTime.now();
    notifyListeners();
  }

  /// Allows setting a custom target word. The custom word must be valid and five letters.
  void setCustomWord(String word) {
    final w = word.toLowerCase();
    if (wordRepository.isValidWord(w) && w.length == 5) {
      _targetWord = w;
      _guesses.clear();
      _currentGuess = '';
      _isGameOver = false;
      _hasWon = false;
      notifyListeners();
    }
  }

  /// Public method to reset the game.
  void resetGame() {
    _startNewGame();
  }

  /// Returns a list of LetterResult for each letter of the guess.
  List<LetterResult> _evaluateGuess(String guess) {
    final target = _targetWord.split('');
    final guessLetters = guess.split('');
    final results = <LetterResult>[];
    final letterCounts = <String, int>{};
    for (final letter in target) {
      letterCounts[letter] = (letterCounts[letter] ?? 0) + 1;
    }
    // First pass: mark correct positions
    for (var i = 0; i < 5; i++) {
      final letter = guessLetters[i];
      if (letter == target[i]) {
        results.add(LetterResult(letter: letter, status: TileStatus.correct));
        letterCounts[letter] = letterCounts[letter]! - 1;
      } else {
        results.add(const LetterResult(letter: '', status: TileStatus.absent));
      }
    }
    // Second pass: mark present letters
    for (var i = 0; i < 5; i++) {
      if (results[i].letter.isNotEmpty) continue; // Already marked correct
      final letter = guessLetters[i];
      if (letterCounts.containsKey(letter) && letterCounts[letter]! > 0) {
        results[i] = LetterResult(letter: letter, status: TileStatus.present);
        letterCounts[letter] = letterCounts[letter]! - 1;
      } else {
        results[i] = LetterResult(letter: letter, status: TileStatus.absent);
      }
    }
    return results;
  }
}
