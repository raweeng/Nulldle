import 'tile_status.dart';

/// Represents a single letter guess and its evaluated status.
class LetterResult {
  final String letter;
  final TileStatus status;

  const LetterResult({required this.letter, required this.status});
}
