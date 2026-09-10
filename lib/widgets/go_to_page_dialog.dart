import 'package:flutter/material.dart';

/// Prompts for a page/article number and returns the chosen 0-based index,
/// or null if the reader cancelled.
///
/// Shared by all six reading pages via the tappable position label in
/// [ArticleReadTopNav] / [ArticleReadBottomNav], so "Halaman 3 / 140" and
/// "Artikel 2 / 6" both jump the same way -- only the label text differs.
Future<int?> showGoToPageDialog({
  required BuildContext context,
  required int total,
  required int currentIndex,
  required String themeName,
  String label = 'Halaman',
}) {
  if (total <= 1) return Future.value(null);

  final controller = TextEditingController(text: '${currentIndex + 1}');
  final isDark = themeName == 'Gelap';

  return showDialog<int>(
    context: context,
    builder: (dialogContext) {
      String? errorText;

      return StatefulBuilder(
        builder: (dialogContext, setState) {
          void submit() {
            final value = int.tryParse(controller.text.trim());
            if (value == null || value < 1 || value > total) {
              setState(() {
                errorText = 'Masukkan nombor antara 1 dan $total';
              });
              return;
            }
            Navigator.of(dialogContext).pop(value - 1);
          }

          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            title: Text(
              'Pergi ke $label',
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: '1 - $total',
                errorText: errorText,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => submit(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: submit,
                child: const Text('Pergi'),
              ),
            ],
          );
        },
      );
    },
  );
}
