import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repository/word_repository.dart';
import 'repository/stats_repository.dart';
import 'viewmodel/game_view_model.dart';
import 'view/game_screen.dart';
import 'view/stats_page.dart';
import 'view/home_screen.dart';
import 'view/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WordRepository>(
      future: WordRepository.loadFromAssets('assets/words.txt'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final wordRepo = snapshot.data!;
        return MultiProvider(
          providers: [
            Provider<WordRepository>.value(value: wordRepo),
            Provider<StatsRepository>(create: (_) => StatsRepository()),
            ChangeNotifierProvider<GameViewModel>(
              create: (context) => GameViewModel(
                wordRepository: wordRepo,
                statsRepository: context.read<StatsRepository>(),
              ),
            ),
          ],
          child: MaterialApp(
            title: 'Wordle App',
            theme: ThemeData(
              primarySwatch: Colors.indigo,
            ),
            initialRoute: '/',
            routes: {
              '/': (_) => HomeScreen(),
              '/game': (_) => const GameScreen(),
              '/stats': (_) => const StatsPage(),
              '/settings': (_) => const SettingsPage(),
            },
          ),
        );
      },
    );
  }
}
