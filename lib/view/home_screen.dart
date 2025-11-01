import 'package:flutter/material.dart';
import '../widgets/nulldle_text.dart';

/// The landing screen showing the title, game blurb, and navigation buttons.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // <- const constructor fixes the lint

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 60),
          const Center(
            child: Text(
              'Nulldle',
              style: TextStyle(
                fontFamily: 'Courier',
                color: Colors.pink,
                fontWeight: FontWeight.bold,
                fontSize: 48.0,
              ),
            ),
          ),
          Center(
            child: Image.asset(
              'assets/title.png',
              width: 200,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: NulldleText(
                // Use a standard hyphen between "five" and "letter" so substring tests match.
                'Guess the hidden five-letter word in just six tries! After each guess, tiles will light up, green means the letter is in the right spot, yellow means the letter is in the word but in the wrong spot, and grey means the letter is not in the word at all.',
                size: 14.0,
              ),
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade100,
                ),
                child: const Text(
                  'Play Game',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/game');
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade100,
                ),
                child: const Text(
                  'Statistics',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/stats');
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade100,
                ),
                child: const Text(
                  'Set Word',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
