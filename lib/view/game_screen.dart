import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/guess.dart';
import '../model/tile_status.dart';
import '../viewmodel/game_view_model.dart';
import '../repository/word_repository.dart';
import '../repository/stats_repository.dart';

/// Game screen that runs with or without Providers.
/// - In the app, it uses the provided GameViewModel.
/// - In tests like `MaterialApp(home: GameScreen())`, it falls back to a local VM.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameViewModel? _localVm;

  GameViewModel _ensureVm(BuildContext context) {
    GameViewModel? provided;
    try {
      provided = Provider.of<GameViewModel>(context, listen: true);
    } on ProviderNotFoundException {
      provided = null;
    }

    if (provided != null) return provided;

    // Tiny, deterministic VM for tests / bare usage (no assets).
    _localVm ??= GameViewModel(
      wordRepository: WordRepository.fromWords(
        ['apple', 'world', 'would', 'games', 'house', 'other', 'start'],
      ),
      statsRepository: StatsRepository(),
    );
    return _localVm!;
  }

  @override
  void dispose() {
    _localVm?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _ensureVm(context);

    // AnimatedBuilder keeps the UI reactive without requiring Provider.of here.
    final body = AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                _buildKeyboard(vm), // keyboard colours mirror grid
              ],
            ),
          ),
        );
      },
    );

    // If we created a local VM, expose it to descendants.
    if (_localVm != null) {
      return ChangeNotifierProvider<GameViewModel>.value(
        value: vm,
        child: body,
      );
    }
    return body;
  }

  /// Top row: back on the left, stats & settings on the right.
  Widget _buildTopOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.pushNamed(context, '/'),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.bar_chart),
              tooltip: 'Statistics',
              onPressed: () => Navigator.pushNamed(context, '/stats'),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Set Word',
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ],
    );
  }

  /// 6×5 grid: completed / current / empty rows.
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
      children: guess.letters
          .map((lr) => _buildTile(lr.letter.toUpperCase(), lr.status))
          .toList(),
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
        background = Colors.amberAccent.shade700; // brighter yellow
        border = Colors.amberAccent.shade700;
        break;
      case TileStatus.absent:
        background = borderOnly ? Colors.transparent : Colors.grey.shade500;
        border = Colors.grey.shade500;
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

  /// Text field with clear (×) button and async-safe submission.
  Widget _buildTextField(GameViewModel vm, BuildContext context) {
    final controller = TextEditingController(text: vm.currentGuess);
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    return TextField(
      controller: controller,
      maxLength: 5,
      onChanged: vm.updateCurrentGuess,
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
                onPressed: () => vm.updateCurrentGuess(''),
              )
            : null,
      ),
    );
  }

  /// Submit / New Game buttons.
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
          onPressed: vm.resetGame,
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

  /// On-screen keyboard whose colours mirror the grid.
  /// Priority: green (correct) > yellow (present) > grey (absent) > light grey (unknown).
  Widget _buildKeyboard(GameViewModel vm) {
    final statusByLetter = _computeKeyboardStatuses(vm.guesses);

    Color statusToColor(TileStatus? status) {
      if (status == null) return Colors.grey.shade300; // unknown
      switch (status) {
        case TileStatus.correct:
          return Colors.green;
        case TileStatus.present:
          return Colors.amberAccent.shade700; // bright yellow
        case TileStatus.absent:
          return Colors.grey.shade500;
      }
    }

    const rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.split('').map((letter) {
              final st = statusByLetter[letter];
              final bg = statusToColor(st);
              return Container(
                width: 40,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: (st == null) ? Colors.grey.shade400 : bg,
                  ),
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

  /// Map from letter (A–Z) to highest-priority status seen so far across guesses.
  Map<String, TileStatus> _computeKeyboardStatuses(List<Guess> guesses) {
    final map = <String, TileStatus>{};

    int rank(TileStatus s) =>
        s == TileStatus.correct ? 3 : (s == TileStatus.present ? 2 : 1);

    for (final g in guesses) {
      for (final lr in g.letters) {
        final key = lr.letter.toUpperCase();
        final current = map[key];
        if (current == null || rank(lr.status) > rank(current)) {
          map[key] = lr.status;
        }
      }
    }
    return map;
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
}
