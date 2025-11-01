import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repository/word_repository.dart';
import 'repository/stats_repository.dart';
import 'viewmodel/game_view_model.dart';
import 'view/game_screen.dart';
import 'view/stats_page.dart';
import 'view/home_screen.dart';
import 'view/settings_page.dart';

/// Entry point of the application. This function ensures the Flutter
/// environment is initialised, then attempts to load the list of valid
/// words before starting the app. If the dictionary fails to load, an
/// error widget is shown instead of leaving the user with an infinite
/// progress indicator.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Load the dictionary from english_dict.txt as specified in pubspec.yaml.
    final wordRepo =
        await WordRepository.loadFromAssets('assets/english_dict.txt');
    runApp(MyApp(wordRepo: wordRepo));
  } catch (e) {
    // If the dictionary cannot be loaded, display an error screen so
    // the developer knows what went wrong instead of showing a spinner.
    runApp(ErrorApp(message: 'Failed to load dictionary: $e'));
  }
}

/// Root widget for the Wordle app with dependency injection. All
/// repositories and view models are provided to descendants via
/// [Provider] and [ChangeNotifierProvider].
class MyApp extends StatelessWidget {
  /// The repository of valid words. If null, a small default dictionary
  /// is used so that the widget tree can be constructed without
  /// providing a word list (e.g., during tests). See
  /// [WordRepository.fromWords] for details.
  final WordRepository? wordRepo;
  const MyApp({super.key, this.wordRepo});

  @override
  Widget build(BuildContext context) {
    // Provide a fallback list of words if no repository was supplied.
    // This ensures that tests or other callers can construct MyApp
    // without explicitly supplying a wordRepo. The fallback contains a
    // handful of common five-letter words.
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
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        // Remove the debug banner from the top-right corner in debug mode.
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

/// A simple error display used when the dictionary cannot be loaded.
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
