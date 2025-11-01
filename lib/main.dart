import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repository/word_repository.dart';
import 'repository/stats_repository.dart';
import 'viewmodel/game_view_model.dart';
import 'view/game_screen.dart';
import 'view/stats_page.dart';
import 'view/home_screen.dart';
import 'view/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final wordRepo =
        await WordRepository.loadFromAssets('assets/english_dict.txt');
    runApp(MyApp(wordRepo: wordRepo));
  } catch (e) {
    runApp(ErrorApp(message: 'Failed to load dictionary: $e'));
  }
}

class MyApp extends StatelessWidget {
  final WordRepository? wordRepo;
  const MyApp({super.key, this.wordRepo});

  @override
  Widget build(BuildContext context) {
    final WordRepository repo = wordRepo ??
        WordRepository.fromWords(
            ['apple', 'world', 'would', 'other', 'house', 'stack', 'games']);

    return MultiProvider(
      providers: [
        Provider<WordRepository>.value(value: repo),
        Provider<StatsRepository>(create: (_) => StatsRepository()),
        ChangeNotifierProvider<GameViewModel>(
          create: (context) => GameViewModel(
            wordRepository: repo,
            statsRepository:
                Provider.of<StatsRepository>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Wordle App',
        theme: ThemeData(primarySwatch: Colors.indigo),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (_) => HomeScreen(),
          '/game': (_) => const GameScreen(),
          '/stats': (_) => const StatsPage(),
          '/settings': (_) => const SettingsPage(),
        },
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
