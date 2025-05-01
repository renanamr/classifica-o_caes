import 'package:flutter/material.dart';

class ButtonCore extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const ButtonCore({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      )
    );
  }
}