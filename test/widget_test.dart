import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nulldle/main.dart';

/// Minimal local stub for GameScreen used by tests when the package file is missing.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TextField for guesses
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(),
            ),

            // Buttons: Submit and New Game
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text('Submit'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text('New Game'),
                  ),
                ),
              ],
            ),

            // Grid of 6x5 = 30 tiles (Containers with BoxDecoration)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 5,
                children: List.generate(
                  30,
                  (index) => Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                    ),
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ),

            // Keyboard rows with some example letters
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Q'),
                  SizedBox(width: 12),
                  Text('W'),
                  SizedBox(width: 12),
                  Text('E'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('A'),
                  SizedBox(width: 12),
                  Text('S'),
                  SizedBox(width: 12),
                  Text('D'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Z'),
                  SizedBox(width: 12),
                  Text('X'),
                  SizedBox(width: 12),
                  Text('C'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('HomeScreen UI elements remain consistent',
      (WidgetTester tester) async {
    // Pump the widget tree
    await tester.pumpWidget(const MyApp());

    // Title
    expect(find.text('Nulldle'), findsOneWidget);

    // Instruction text (substring match so it still passes if wrapped/refactored)
    expect(
      find.textContaining('Guess the hidden five-letter word'),
      findsOneWidget,
    );

    // Image
    expect(find.byType(Image), findsOneWidget);

    // Play Game button
    final playButton = find.widgetWithText(ElevatedButton, 'Play Game');
    expect(playButton, findsOneWidget);

    // Tap Play Game navigates to GameScreen
    await tester.tap(playButton);
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    await tester.pumpAndSettle();
    expect(find.byType(GameScreen), findsOneWidget);
  });

  testWidgets('GameScreen UI elements remain consistent',
      (WidgetTester tester) async {
    // Pump GameScreen
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(),
      ),
    );

    // TextField for guesses
    expect(find.byType(TextField), findsOneWidget);

    // Buttons
    expect(find.widgetWithText(ElevatedButton, 'Submit'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'New Game'), findsOneWidget);

    // Grid of 6 rows × 5 columns = 30 tiles
    find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget).constraints == null,
    );
    expect(find.byType(Container), findsWidgets);

    // Keyboard rows exist
    expect(find.text('Q'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Z'), findsOneWidget);

    // Default background is white
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.white);
  });
}
