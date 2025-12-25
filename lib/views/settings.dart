import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/download_service.dart';
import '../utils/theme_helper.dart';

class SettingsPage extends StatefulWidget {
  final Function(String)? onThemeChanged;
  
  const SettingsPage({super.key, this.onThemeChanged});
  
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedFont = 'Default';
  double _fontSize = 16.0;
  String _selectedTheme = 'Terang';
  bool _isInitialized = false;

  final List<String> _fontOptions = [
    'Default',
    'Amiri',
    'Scheherazade',
    'Lateef',
    'Noto Sans Arabic'
  ];

  final List<String> _themeOptions = [
    'Terang',
    'Gelap'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFont = prefs.getString('selected_font') ?? 'Default';
      _fontSize = prefs.getDouble('font_size') ?? 16.0;
      _selectedTheme = prefs.getString('selected_theme') ?? 'Terang';
      _isInitialized = true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_font', _selectedFont);
    await prefs.setDouble('font_size', _fontSize);
    await prefs.setString('selected_theme', _selectedTheme);
  }

  void _showFontDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Tulisan'),
          content: SingleChildScrollView(
            child: Column(
              children: _fontOptions.map((font) {
                return RadioListTile<String>(
                  title: Text(font),
                  value: font,
                  groupValue: _selectedFont,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedFont = value!;
                    });
                    _saveSettings();
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Tema'),
          content: SingleChildScrollView(
            child: Column(
              children: _themeOptions.map((theme) {
                return RadioListTile<String>(
                  title: Text(theme),
                  value: theme,
                  groupValue: _selectedTheme,
                  onChanged: (String? value) async {
                    setState(() {
                      _selectedTheme = value!;
                    });
                    await _saveSettings();
                    // Notify parent widget about theme change
                    if (widget.onThemeChanged != null) {
                      widget.onThemeChanged!(value!);
                    }
                    // Rebuild this page to show theme changes
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showHowToUse() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cara Menggunakan'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Pilih Surah',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Tap pada surah yang ingin dibaca'),
                SizedBox(height: 10),
                Text(
                  '2. Navigasi Halaman',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Gunakan tombol panah untuk berpindah halaman'),
                SizedBox(height: 10),
                Text(
                  '3. Bookmark',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Tap ikon bookmark untuk menyimpan halaman'),
                SizedBox(height: 10),
                Text(
                  '4. Pengaturan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Ubah font, ukuran, dan tema sesuai preferensi'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/tutorial'),
              child: Text('Tutorial'),
            ),
          ],
        );
      },
    );
  }

  void _resetFontSize() {
    setState(() {
      _fontSize = 16.0;
    });
    _saveSettings();
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kosongkan Cache'),
          content: Text(
            'Adakah anda pasti mahu mengosongkan cache? '
            'Semua kandungan yang telah dimuat turun akan dipadam. '
            'Aplikasi akan memuat turun semula kandungan apabila anda membuka surah.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                
                try {
                  // Clear all caches
                  await DownloadService.clearCache();
                  
                  // Clear surah list cache too
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('cached_surah_names');
                  await prefs.remove('cached_category_urls');
                  await prefs.remove('cached_surah_urls');
                  await prefs.remove('cached_surah_list_timestamp');
                  
                  // Close loading dialog
                  Navigator.of(context).pop();
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cache berjaya dikosongkan!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  // Close loading dialog
                  Navigator.of(context).pop();
                  
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ralat mengosongkan cache: $e'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text(
                'Kosongkan',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Pengaturan'),
          backgroundColor: const Color.fromARGB(255, 52, 21, 104),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 52, 21, 104),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: FutureBuilder<String>(
        future: ThemeHelper.getThemeName(),
        builder: (context, snapshot) {
          final themeName = snapshot.data ?? 'Terang';
          final isDark = themeName == 'Gelap';
          
          return Stack(
            children: [
              // Background image with dark overlay in dark mode
              Image.asset(
                'assets/images/Tetapan_baru.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                color: isDark ? Colors.black54 : null,
                colorBlendMode: isDark ? BlendMode.darken : null,
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double screenHeight = constraints.maxHeight;
                    final double screenWidth = constraints.maxWidth;
                    final double dropdownWidth = screenWidth * 0.48;
                    final double dropdownHeight = 44.0;
                    final double labelWidth = screenWidth * 0.22;
                    final TextStyle labelStyle = TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    );
                    final TextStyle valueStyle = TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    );

                    String fontSizeLabel;
                    if (_fontSize <= 14) {
                      fontSizeLabel = 'Kecil';
                    } else if (_fontSize >= 22) {
                      fontSizeLabel = 'Besar';
                    } else {
                      fontSizeLabel = 'Sederhana';
                    }

                    Widget buildDropdownRow({
                      required String label,
                      required String value,
                      required VoidCallback onTap,
                    }) {
                      return Row(
                        children: [
                          // Label column
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    label,
                                    style: labelStyle,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    ':',
                                    style: labelStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          // Dropdown column
                          Expanded(
                            flex: 7,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: 0.8,
                                child: GestureDetector(
                                  onTap: onTap,
                                  child: Container(
                                    height: dropdownHeight,
                                    padding: EdgeInsets.symmetric(horizontal: 24),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF3A2A12)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(dropdownHeight / 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6B4A16),
                                          offset: Offset(0, 4),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            value,
                                            style: valueStyle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.08,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Spacer for "PAPARAN" title and ornament area
                          SizedBox(height: screenHeight * 0.24),
                          // Tulisan dropdown row
                          buildDropdownRow(
                            label: 'Tulisan',
                            value: _selectedFont,
                            onTap: _showFontDialog,
                          ),
                          SizedBox(height: screenHeight * 0.045),
                          // Saiz dropdown row
                          buildDropdownRow(
                            label: 'Saiz',
                            value: fontSizeLabel,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Pilih Saiz Tulisan'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RadioListTile<String>(
                                          title: Text('Kecil'),
                                          value: 'Kecil',
                                          groupValue: fontSizeLabel,
                                          onChanged: (value) {
                                            setState(() {
                                              _fontSize = 14.0;
                                            });
                                            _saveSettings();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        RadioListTile<String>(
                                          title: Text('Sederhana'),
                                          value: 'Sederhana',
                                          groupValue: fontSizeLabel,
                                          onChanged: (value) {
                                            setState(() {
                                              _fontSize = 18.0;
                                            });
                                            _saveSettings();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        RadioListTile<String>(
                                          title: Text('Besar'),
                                          value: 'Besar',
                                          groupValue: fontSizeLabel,
                                          onChanged: (value) {
                                            setState(() {
                                              _fontSize = 22.0;
                                            });
                                            _saveSettings();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              _resetFontSize();
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Reset'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          SizedBox(height: screenHeight * 0.045),
                          // Tema dropdown row
                          buildDropdownRow(
                            label: 'Tema',
                            value: _selectedTheme,
                            onTap: _showThemeDialog,
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          // Cara Menggunakan button (placed directly under Tema)
                          SizedBox(
                            width: screenWidth * 0.55,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pushNamed('/tutorial'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 52, 21, 104),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Cara Menggunakan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          // Kosongkan Cache button
                          SizedBox(
                            width: screenWidth * 0.55,
                            child: ElevatedButton(
                              onPressed: _showClearCacheDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Kosongkan Cache',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
