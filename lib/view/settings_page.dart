import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/game_view_model.dart';
import '../widgets/nulldle_text.dart';

/// Screen that allows the user to set a custom hidden word.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<GameViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Set Custom Word')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NulldleText('Enter a five‑letter word from the dictionary'),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLength: 5,
              decoration: InputDecoration(
                hintText: 'Enter word',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final word = _controller.text.trim().toLowerCase();
                if (word.length != 5 || !vm.wordRepository.isValidWord(word)) {
                  setState(() {
                    _error = 'Please enter a valid 5‑letter word.';
                  });
                  return;
                }
                vm.setCustomWord(word);
                Navigator.pop(context);
              },
              child: const Text('Set Word'),
            ),
          ],
        ),
      ),
    );
  }
}
