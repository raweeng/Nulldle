import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository/stats_repository.dart';

/// Screen that displays win/loss statistics.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final statsRepo = Provider.of<StatsRepository>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: FutureBuilder(
        future: Future.wait([
          statsRepo.wins,
          statsRepo.losses,
          statsRepo.games,
          statsRepo.incorrectGuesses,
          statsRepo.durations,
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final wins = snapshot.data![0] as int;
          final losses = snapshot.data![1] as int;
          final games = snapshot.data![2] as int;
          final incorrects = snapshot.data![3] as List<int>;
          final durations = snapshot.data![4] as List<int>;
          final avgIncorrect = games > 0
              ? (incorrects.isNotEmpty
                  ? incorrects.reduce((a, b) => a + b) / incorrects.length
                  : 0.0)
              : 0.0;
          // Convert durations to seconds and pick top 5
          final topDurations =
              durations.map((ms) => ms / 1000.0).take(5).toList();
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Games played: $games',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Wins: $wins',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Losses: $losses',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                      'Average incorrect guesses per game: ${avgIncorrect.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('Leaderboard (fastest times in seconds):',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...topDurations.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final time = entry.value;
                    return Text('$index. ${time.toStringAsFixed(2)} s',
                        style: Theme.of(context).textTheme.titleMedium);
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
