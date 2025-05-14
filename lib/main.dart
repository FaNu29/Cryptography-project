// main.dart
import 'package:crpto/algorithm_list_page.dart';
import 'package:flutter/material.dart';


void main() => runApp(const CryptoVisualizerApp());

class CryptoVisualizerApp extends StatelessWidget {
  const CryptoVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AlgorithmListPage(),
    );
  }
}
