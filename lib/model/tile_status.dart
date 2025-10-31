enum TileStatus {
  /// The letter is in the correct position (green)
  correct,

  /// The letter exists in the word but is in the wrong position (yellow)
  present,

  /// The letter does not exist in the word (grey)
  absent,
}
