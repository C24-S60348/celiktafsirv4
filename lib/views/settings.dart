import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/download_service.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedFont = 'Default';
  double _fontSize = 16.0;
  String _selectedTheme = 'Light';
  bool _isInitialized = false;

  final List<String> _fontOptions = [
    'Default',
    'Amiri',
    'Scheherazade',
    'Lateef',
    'Noto Sans Arabic'
  ];

  final List<String> _themeOptions = [
    'Light',
    'Dark',
    'Sepia',
    'Green'
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
      _selectedTheme = prefs.getString('selected_theme') ?? 'Light';
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
                  onChanged: (String? value) {
                    setState(() {
                      _selectedTheme = value!;
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
      body: Stack(
        children: [
          Image.asset(
            'assets/images/bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Font Selection
                // Container(
                //   padding: EdgeInsets.all(16.0),
                //   decoration: BoxDecoration(
                //     color: Colors.white.withOpacity(0.9),
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         'Tulisan',
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.black,
                //         ),
                //       ),
                //       SizedBox(height: 10),
                //       InkWell(
                //         onTap: _showFontDialog,
                //         child: Container(
                //           padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                //           decoration: BoxDecoration(
                //             border: Border.all(color: Colors.grey),
                //             borderRadius: BorderRadius.circular(8),
                //           ),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Text(_selectedFont),
                //               Icon(Icons.arrow_drop_down),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(height: 16),

                // Font Size
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Saiz Tulisan'),
                          SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            ),
                            onPressed: _resetFontSize,
                            child: Text('Reset'),
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('Kecil'),
                          Expanded(
                            child: Slider(
                              value: _fontSize,
                              min: 12.0,
                              max: 24.0,
                              divisions: 12,
                              onChanged: (value) {
                                setState(() {
                                  _fontSize = value;
                                });
                                _saveSettings();
                              },
                            ),
                          ),
                          Text('Besar'),
                        ],
                      ),
                      Center(
                        child: Text(
                          'Saiz: ${_fontSize.round()}',
                          style: TextStyle(fontSize: _fontSize),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // // Theme Selection
                // Container(
                //   padding: EdgeInsets.all(16.0),
                //   decoration: BoxDecoration(
                //     color: Colors.white.withOpacity(0.9),
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         'Tema',
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.black,
                //         ),
                //       ),
                //       SizedBox(height: 10),
                //       InkWell(
                //         onTap: _showThemeDialog,
                //         child: Container(
                //           padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                //           decoration: BoxDecoration(
                //             border: Border.all(color: Colors.grey),
                //             borderRadius: BorderRadius.circular(8),
                //           ),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Text(_selectedTheme),
                //               Icon(Icons.arrow_drop_down),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(height: 16),

                // How to Use Button
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ElevatedButton(
                    onPressed: _showHowToUse,
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
                SizedBox(height: 16),
                
                // Clear Cache Button
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
