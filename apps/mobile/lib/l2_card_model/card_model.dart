import 'package:flutter/material.dart';

class CardModel {
  final String exerciseName;
  final Color color;
  bool isFlipped;
  String weight;
  String reps;

  CardModel({
    required this.exerciseName,
    required this.color,
    this.isFlipped = false,
    this.weight = '',
    this.reps = '',
  });

  CardModel copyWith({
    String? exerciseName,
    Color? color,
    bool? isFlipped,
    String? weight,
    String? reps,
  }) {
    return CardModel(
      exerciseName: exerciseName ?? this.exerciseName,
      color: color ?? this.color,
      isFlipped: isFlipped ?? this.isFlipped,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
    );
  }
}
