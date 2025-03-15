import 'package:flutter/material.dart';

class SettingsWidget extends StatelessWidget {
  final List<SettingsOption?> options;

  const SettingsWidget({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: Colors.grey[100],
      icon: const Icon(Icons.settings, size: 28),
      elevation: 8,
      onSelected: (index) => options[index]!.onTap(),
      itemBuilder: (context) => List.generate(
        options.length,
        (index) => PopupMenuItem(
          value: index,
          child: Text(options[index]!.label),
        ),
      ),
      offset: const Offset(0, 50),
    );
  }
}

class SettingsOption {
  final String label;
  final VoidCallback onTap;

  SettingsOption({required this.label, required this.onTap});
}