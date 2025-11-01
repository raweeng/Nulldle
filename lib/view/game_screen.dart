import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/guess.dart';
import '../model/tile_status.dart';
import '../viewmodel/game_view_model.dart';

/// The main play screen for the Nulldle/Wordle game.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<GameViewModel>(
          builder: (context, vm, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildTopOptions(context),
                const SizedBox(height: 8),
                _buildGuessGrid(vm),
                if (vm.isGameOver) ...[
                  const SizedBox(height: 16),
                  _buildResultMessage(vm),
                ],
                const SizedBox(height: 24),
                _buildTextField(vm, context),
                const SizedBox(height: 16),
                _buildActionButtons(vm, context),
                const SizedBox(height: 24),
                _buildKeyboard(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGuessGrid(GameViewModel vm) {
    final rows = <Widget>[];
    for (var i = 0; i < 6; i++) {
      if (i < vm.guesses.length) {
        rows.add(_buildGuessRow(vm.guesses[i]));
      } else if (i == vm.guesses.length && !vm.isGameOver) {
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
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (_) => _buildTile('', TileStatus.absent, borderOnly: true),
          ),
        ));
      }
      rows.add(const SizedBox(height: 8));
    }
    return Column(children: rows);
  }

  Widget _buildGuessRow(Guess guess) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: guess.letters.map((lr) {
        return _buildTile(lr.letter.toUpperCase(), lr.status);
      }).toList(),
    );
  }

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

  /// Text field that uses a controller to reflect the current guess and shows
  /// a clear (×) button when there is text.  Pressing the clear button
  /// resets the current guess in the view model, and the text field
  /// rebuilds with an empty string.
  Widget _buildTextField(GameViewModel vm, BuildContext context) {
    final controller = TextEditingController(text: vm.currentGuess);
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    return TextField(
      controller: controller,
      maxLength: 5,
      onChanged: (v) => vm.updateCurrentGuess(v),
      onSubmitted: (_) async {
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
        suffixIcon: vm.currentGuess.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear',
                onPressed: () {
                  vm.updateCurrentGuess('');
                },
              )
            : null,
      ),
    );
  }

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

  Widget _buildResultMessage(GameViewModel vm) {
    final message = vm.hasWon
        ? 'You won! 🎉'
        : 'You lost! The word was ${vm.targetWord.toUpperCase()}';
    return Text(
      message,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  /// Builds the top bar containing navigation options for statistics and
  /// setting a custom word.  This replaces an AppBar to better match
  /// the original design.
  Widget _buildTopOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.bar_chart),
          tooltip: 'Statistics',
          onPressed: () {
            Navigator.pushNamed(context, '/stats');
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Set Word',
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    );
  }
}
