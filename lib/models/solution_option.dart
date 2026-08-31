import 'package:flutter/material.dart';

class SolutionOption {
  const SolutionOption({
    required this.title,
    required this.badge,
    required this.subtitle,
    required this.description,
    required this.accent,
  });

  final String title;
  final String badge;
  final String subtitle;
  final String description;
  final Color accent;
}
