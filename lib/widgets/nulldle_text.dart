import 'package:flutter/material.dart';

/// A reusable custom text widget for the Nulldle app.
class NulldleText extends StatelessWidget {
  final String text;
  final double size;

  const NulldleText(this.text, {super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Courier',
        color: Colors.pink,
        fontWeight: FontWeight.bold,
        fontSize: size,
      ),
    );
  }
}
