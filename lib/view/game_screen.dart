import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/guess.dart';
import '../model/tile_status.dart';
import '../viewmodel/game_view_model.dart';

/// The main play screen for the Nulldle/Wordle game.
///
/// This stateless widget consumes the [GameViewModel] provided higher up
/// in the widget tree via [Provider]. It displays a 6×5 grid of previous
/// guesses, an input row for the current guess, and controls to submit a
/// guess or start a new game. When the game is over it shows a message
/// revealing whether the player won or lost and the correct word.
///
/// The architecture follows MVVM: all game logic lives in the view model
/// (see `game_view_model.dart`), so this widget merely reflects state and
/// forwards user actions to the view model:contentReference[oaicite:0]{index=0}.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nulldle Game'),
        actions: [
          // Navigate to the statistics/leaderboard screen
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Navigator.of(context).pushNamed('/stats'),
          ),
          // Navigate to the settings screen to set a custom word
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<GameViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                // The grid showing previous guesses and the current guess
                _buildGuessGrid(vm),
                const SizedBox(height: 16),
                // Show input row only if the game is still active
                if (!vm.isGameOver) _buildInputRow(vm),
                // Show result message when the game ends
                if (vm.isGameOver) _buildResultMessage(vm),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => vm.resetGame(),
                  child: const Text('New Game'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds the 6×5 grid of tiles representing guesses.
  Widget _buildGuessGrid(GameViewModel vm) {
    final rows = <Widget>[];
    for (var i = 0; i < 6; i++) {
      if (i < vm.guesses.length) {
        // Completed guess
        rows.add(_buildGuessRow(vm.guesses[i]));
      } else if (i == vm.guesses.length && !vm.isGameOver) {
        // Current partial guess (border only)
        final letters = vm.currentGuess.padRight(5).split('');
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final letter =
                letters[index].isEmpty ? '' : letters[index].toUpperCase();
            return _buildTile(letter, TileStatus.absent, borderOnly: true);
          }),
        ));
      } else {
        // Empty row
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              5, (_) => _buildTile('', TileStatus.absent, borderOnly: true)),
        ));
      }
      rows.add(const SizedBox(height: 8));
    }
    return Column(children: rows);
  }

  /// Builds a single row of tiles for a completed guess.
  Widget _buildGuessRow(Guess guess) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: guess.letters.map((lr) {
        return _buildTile(lr.letter.toUpperCase(), lr.status);
      }).toList(),
    );
  }

  /// Builds an individual tile showing a letter and its status. If
  /// [borderOnly] is true, the tile is empty with just a border.
  Widget _buildTile(String letter, TileStatus status,
      {bool borderOnly = false}) {
    Color background;
    Color border;
    switch (status) {
      case TileStatus.correct:
        background = Colors.green;
        border = Colors.green;
        break;
      case TileStatus.present:
        background = Colors.amber;
        border = Colors.amber;
        break;
      case TileStatus.absent:
        background = borderOnly ? Colors.transparent : Colors.grey.shade400;
        border = Colors.grey.shade400;
        break;
    }
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  /// Builds the input row with a text field and submit button.
  Widget _buildInputRow(GameViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            maxLength: 5,
            onChanged: (v) => vm.updateCurrentGuess(v),
            onSubmitted: (_) => vm.submitGuess(),
            decoration: const InputDecoration(
              hintText: 'Enter word',
              counterText: '',
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => vm.submitGuess(),
          child: const Text('Submit'),
        ),
      ],
    );
  }

  /// Builds the end-of-game message.
  Widget _buildResultMessage(GameViewModel vm) {
    final message = vm.hasWon
        ? 'You won! 🎉'
        : 'You lost! The word was ${vm.targetWord.toUpperCase()}';
    return Text(
      message,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
