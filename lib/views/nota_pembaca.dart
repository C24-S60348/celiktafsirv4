import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/reader_notes.dart';
import '../utils/theme_helper.dart';

/// "Nota Pembaca" -- one free-form notebook shared by the whole app.
///
/// There is no save button on purpose. A reader jotting a thought mid-article
/// should not have to remember to press anything, so typing is written back
/// after a short pause, and again on the way out in case they leave inside
/// that pause.
class NotaPembacaPage extends StatefulWidget {
  const NotaPembacaPage({super.key});

  @override
  State<NotaPembacaPage> createState() => _NotaPembacaPageState();
}

class _NotaPembacaPageState extends State<NotaPembacaPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _saveTimer;
  bool _loading = true;
  String _themeName = 'Terang';
  String _lastSaved = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final themeName = await ThemeHelper.getThemeName();
    final text = await ReaderNotes.load();
    if (!mounted) return;
    setState(() {
      _controller.text = text;
      _lastSaved = text;
      _themeName = themeName;
      _loading = false;
    });
  }

  void _onChanged(String value) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), _save);
  }

  Future<void> _save() async {
    final text = _controller.text;
    if (text == _lastSaved) return;
    await ReaderNotes.save(text);
    _lastSaved = text;
  }

  @override
  void dispose() {
    // Leaving mid-pause must not lose the last keystrokes.
    _saveTimer?.cancel();
    if (_controller.text != _lastSaved) {
      ReaderNotes.save(_controller.text);
    }
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _copyAll() async {
    final text = _controller.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Tiada nota untuk disalin'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Nota disalin'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmClear() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kosongkan nota?'),
        content: const Text('Semua nota akan dipadam. Tindakan ini tidak boleh dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );

    if (shouldClear != true || !mounted) return;
    setState(() => _controller.clear());
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeName == 'Gelap';
    final textColor = ThemeHelper.getTextColor(_themeName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeHelper.getAppBarColor(_themeName),
        title: const Text('Nota Pembaca'),
        actions: [
          IconButton(
            tooltip: 'Salin Nota',
            onPressed: _loading ? null : _copyAll,
            icon: const Icon(Icons.copy),
          ),
          IconButton(
            tooltip: 'Kosongkan Nota',
            onPressed: _loading ? null : _confirmClear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            color: isDark ? Colors.black54 : null,
            colorBlendMode: isDark ? BlendMode.darken : null,
          ),
          if (_loading)
            Center(
              child: CircularProgressIndicator(
                color: ThemeHelper.getLoadingIndicatorColor(_themeName),
              ),
            )
          else
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ThemeHelper.getContentBackgroundColor(_themeName),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: _onChanged,
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    style: TextStyle(
                      color: textColor,
                      fontFamily: ThemeHelper.bodyFontFamily,
                      fontFamilyFallback: ThemeHelper.fontFamilyFallback,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tulis nota anda di sini...',
                      hintStyle: TextStyle(
                        color: textColor.withValues(alpha: 0.5),
                        fontFamily: ThemeHelper.bodyFontFamily,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
