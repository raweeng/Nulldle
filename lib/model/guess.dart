import 'letter_result.dart';

/// Represents a single guess composed of letter results.
class Guess {
  final List<LetterResult> letters;

  Guess(this.letters) : assert(letters.length == 5);
}
