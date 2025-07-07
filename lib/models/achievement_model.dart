import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String? iconUrl;
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    this.isUnlocked = false,
  });
}
