import 'package:flutter/material.dart';
import 'package:flash_card/screens/flashcard_app.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(DevicePreview(enabled: true, builder: (context) => FlashcardApp()));
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flash Card',
      theme: ThemeData(
        appBarTheme: AppBarTheme(centerTitle: true, color: Colors.amber),
      ),
      debugShowCheckedModeBanner: false,
      home: FlashcardHome(),
    );
  }
}
