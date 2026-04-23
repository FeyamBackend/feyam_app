import 'package:flutter/material.dart';

class FeyamApp extends StatelessWidget {
  const FeyamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feyam App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Hello, Feyam App!'),
        ),
      ),
    );
  }
}