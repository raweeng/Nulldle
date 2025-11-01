import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Relative imports to the root-level model and viewmodel directories.
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
/// forwards user actions to the view model.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The game screen does not show an app bar so that it more closely
      // resembles the original design. The application title appears
      // only in the window chrome.
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<GameViewModel>(
          builder: (context, vm, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // The 6×5 grid of guesses and current guess
                _buildGuessGrid(vm),
                const SizedBox(height: 24),
                // Show result message when game is over
                vm.isGameOver
                    ? _buildResultMessage(vm)
                    : const SizedBox.shrink(),
                // Text field for entering guesses
                _buildTextField(vm, context),
                const SizedBox(height: 16),
                // Row of action buttons
                _buildActionButtons(vm, context),
                const SizedBox(height: 24),
                // On‑screen keyboard showing letter layout
                _buildKeyboard(),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds the 6×5 grid of tiles representing guesses. Completed guesses
  /// show their colour statuses; the current guess shows as border-only tiles;
  /// unused rows show empty tiles.
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

  /// Builds the text field used to enter guesses. This version applies
  /// custom styling to match the provided design, including a purple
  /// border and a hint. The field updates the view model as the user
  /// types and submits the guess when the user presses the return key.
  ///
  /// It captures the [ScaffoldMessenger] before awaiting an async call to
  /// avoid using the [BuildContext] across an async gap, per the
  /// `use_build_context_synchronously` lint.
  Widget _buildTextField(GameViewModel vm, BuildContext context) {
    return TextField(
      maxLength: 5,
      onChanged: (v) => vm.updateCurrentGuess(v),
      onSubmitted: (_) async {
        // Capture messenger first; don't use context after an await
        final messenger = ScaffoldMessenger.of(context);
        await vm.submitGuess();
        final error = vm.errorMessage;
        if (error != null) {
          messenger.showSnackBar(SnackBar(content: Text(error)));
        }
      },
      decoration: InputDecoration(
        hintText: 'Enter your guess',
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.purpleAccent, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.purple, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.purpleAccent, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  /// Builds the row of action buttons (Submit and New Game). The buttons
  /// are styled with a white background and pink text to match the
  /// reference design. After submitting, this function checks for
  /// an error and displays it via SnackBar.  It captures the
  /// [ScaffoldMessenger] before awaiting to avoid using the context
  /// across an async gap.
  Widget _buildActionButtons(GameViewModel vm, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await vm.submitGuess();
            final error = vm.errorMessage;
            if (error != null) {
              messenger.showSnackBar(SnackBar(content: Text(error)));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.pink,
            shape: const StadiumBorder(),
            side: const BorderSide(color: Colors.pink),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('Submit'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            vm.resetGame();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.pink,
            shape: const StadiumBorder(),
            side: const BorderSide(color: Colors.pink),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('New Game'),
        ),
      ],
    );
  }

  /// Builds the on‑screen keyboard. It displays three rows of keys
  /// corresponding to the QWERTY layout. The keys are styled as light
  /// grey rounded rectangles. Currently, the keyboard is purely visual
  /// and does not handle taps; input is handled via the text field.
  Widget _buildKeyboard() {
    const keyboardRows = [
      'QWERTYUIOP',
      'ASDFGHJKL',
      'ZXCVBNM',
    ];
    return Column(
      children: keyboardRows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.split('').map((letter) {
              return Container(
                width: 40,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                alignment: Alignment.center,
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  /// Builds the end-of-game message. Shows whether the player won or lost and
  /// reveals the correct target word when necessary.
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
