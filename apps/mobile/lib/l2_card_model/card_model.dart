import 'package:flutter/material.dart';

class CardModel {
  final int number;
  final Color color;
  bool isFlipped;

  CardModel({
    required this.number,
    required this.color,
    this.isFlipped = false,
  });

  CardModel copyWith({
    int? number,
    Color? color,
    bool? isFlipped,
  }) {
    return CardModel(
      number: number ?? this.number,
      color: color ?? this.color,
      isFlipped: isFlipped ?? this.isFlipped,
    );
  }
}
