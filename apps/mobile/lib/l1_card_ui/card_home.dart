import 'package:flutter/material.dart';

class CardHomePage extends StatefulWidget {
  const CardHomePage({super.key});

  @override
  State<CardHomePage> createState() => _CardHomePageState();
}

class _CardHomePageState extends State<CardHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Home'),
      ),
      body: const Center(
        child: Text(
          'Card Interface POC',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
