import 'package:flutter/material.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({
    required this.hintText,
    required this.onTap,
    super.key,
  });

  final String hintText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
        filled: true,
      ),
    );
  }
}
