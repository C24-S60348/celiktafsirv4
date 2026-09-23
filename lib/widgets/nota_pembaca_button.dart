import 'package:flutter/material.dart';

/// App bar button that opens "Nota Pembaca".
///
/// Shared rather than pasted into each of the six reading pages, so the icon,
/// tooltip and destination stay in one place.
class NotaPembacaButton extends StatelessWidget {
  const NotaPembacaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Nota Pembaca',
      onPressed: () => Navigator.of(context).pushNamed('/nota'),
      icon: const Icon(Icons.edit_note),
    );
  }
}
