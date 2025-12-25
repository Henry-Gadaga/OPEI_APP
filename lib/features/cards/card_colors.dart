import 'package:flutter/material.dart';

class CardColorOption {
  final String key;
  final String label;
  final List<Color> gradient;
  final List<String> aliases;
  final String description;

  const CardColorOption({
    required this.key,
    required this.label,
    required this.gradient,
    required this.description,
    this.aliases = const [],
  });

  bool matches(String? raw) {
    if (raw == null) return false;
    final sanitized = _normalize(raw);
    if (sanitized == key) return true;
    return aliases.map(_normalize).contains(sanitized);
  }

  static String normalizeKey(String raw) => _normalize(raw);

  static String _normalize(String raw) => raw.trim().toLowerCase().replaceAll(RegExp(r'[\s_]+'), '-');
}

class CardColorPalette {
  static const List<CardColorOption> options = [
    const CardColorOption(
      key: 'sky-blue',
      label: 'Sky Blue',
      gradient: const [
        Color(0xFF5AA9F5),
        Color(0xFF1F7BDF),
        Color(0xFF0F4DA2),
      ],
      description: 'Signature sky blue finish for every virtual card.',
      aliases: ['blue', 'default', 'royal-blue', 'eon-green', 'black'],
    ),
  ];

  static CardColorOption? get defaultOption => options.isNotEmpty ? options.first : null;

  static CardColorOption? fromKey(String? raw) {
    if (options.isEmpty) {
      return null;
    }
    if (raw == null || raw.trim().isEmpty) {
      return options.first;
    }

    for (final option in options) {
      if (option.matches(raw)) {
        return option;
      }
    }

    final normalized = CardColorOption.normalizeKey(raw);
    for (final option in options) {
      if (option.key == normalized) {
        return option;
      }
    }

    return options.first;
  }
}