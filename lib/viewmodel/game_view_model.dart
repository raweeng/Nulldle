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
  String? _errorMessage;
  DateTime? _startTime;

  GameViewModel({
    required this.wordRepository,
    required this.statsRepository,
  }) {
    _startNewGame();
  }

  List<Guess> get guesses => List.unmodifiable(_guesses);
  String get currentGuess => _currentGuess;
  bool get isGameOver => _isGameOver;
  bool get hasWon => _hasWon;
  String get targetWord => _targetWord;
  String? get errorMessage => _errorMessage;

  void updateCurrentGuess(String value) {
    if (_isGameOver) return;
    if (value.length > 5) return;
    _currentGuess = value.toLowerCase();
    notifyListeners();
  }

  Future<void> submitGuess() async {
    if (_isGameOver) return;
    if (_currentGuess.length != 5) return;

    if (!wordRepository.isValidWord(_currentGuess)) {
      _errorMessage = 'Not a valid word! Try again.';
      notifyListeners();
      return;
    }

    _errorMessage = null;

    final results = _evaluateGuess(_currentGuess);
    _guesses.add(Guess(results));

    if (_currentGuess == _targetWord) {
      _isGameOver = true;
      _hasWon = true;
      final incorrectGuesses = _guesses.length;
      await statsRepository.recordResult(
        win: true,
        incorrectGuesses: incorrectGuesses,
      );
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
        win: false,
        incorrectGuesses: incorrectGuesses,
      );
      if (_startTime != null) {
        final durationMs =
            DateTime.now().difference(_startTime!).inMilliseconds;
        await statsRepository.recordDuration(durationMs);
      }
    }

    _currentGuess = '';
    notifyListeners();
  }

  void _startNewGame() {
    _targetWord = wordRepository.randomWord();
    _guesses.clear();
    _currentGuess = '';
    _isGameOver = false;
    _hasWon = false;
    _startTime = DateTime.now();
    notifyListeners();
  }

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

  void resetGame() {
    _startNewGame();
  }

  List<LetterResult> _evaluateGuess(String guess) {
    final target = _targetWord.split('');
    final guessLetters = guess.split('');
    final results = <LetterResult>[];
    final letterCounts = <String, int>{};

    for (final letter in target) {
      letterCounts[letter] = (letterCounts[letter] ?? 0) + 1;
    }

    for (var i = 0; i < 5; i++) {
      final letter = guessLetters[i];
      if (letter == target[i]) {
        results.add(
          LetterResult(letter: letter, status: TileStatus.correct),
        );
        letterCounts[letter] = letterCounts[letter]! - 1;
      } else {
        results.add(const LetterResult(letter: '', status: TileStatus.absent));
      }
    }

    for (var i = 0; i < 5; i++) {
      if (results[i].letter.isNotEmpty) continue;
      final letter = guessLetters[i];
      if (letterCounts.containsKey(letter) && letterCounts[letter]! > 0) {
        results[i] = LetterResult(
          letter: letter,
          status: TileStatus.present,
        );
        letterCounts[letter] = letterCounts[letter]! - 1;
      } else {
        results[i] = LetterResult(
          letter: letter,
          status: TileStatus.absent,
        );
      }
    }

    return results;
  }
}
