import 'package:flutter/material.dart';
import '../utils/proxy_helper.dart';
import '../utils/theme_helper.dart';

/// Configuration for the shared article/list page used by
/// Hujjah, Asmaul Husna, Ilmu Usul Tafsir, Hadis 40, La Tahzan.
class ArticleListConfig {
  final String appBarTitle;
  final String listHeaderTitle;
  final String countLabel;
  final String subtitleLabel;
  final Future<List<Map<String, dynamic>>> Function() loadItems;
  final String routeName;
  /// fullList is provided so Hujjah/Asmaul Husna can pass items for Sebelum/Selepas.
  final Map<String, dynamic> Function(Map<String, dynamic> item, int index, List<Map<String, dynamic>>? fullList) getRouteArguments;
  final int? itemLimit;

  const ArticleListConfig({
    required this.appBarTitle,
    this.listHeaderTitle = 'Pilih Artikel',
    this.countLabel = 'artikel',
    this.subtitleLabel = 'Artikel',
    required this.loadItems,
    required this.routeName,
    required this.getRouteArguments,
    this.itemLimit,
  });
}

/// Shared list page: loads items, shows header + list; tap navigates to read route.
class ArticleListPage extends StatefulWidget {
  final ArticleListConfig config;

  const ArticleListPage({super.key, required this.config});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  bool _hasNoInternet = false;

  Future<void> _loadItems() async {
    final hasInternet = await hasInternetConnection();
    if (!mounted) return;

    try {
      var list = await widget.config.loadItems();
      if (!mounted) return;
      final limit = widget.config.itemLimit;
      if (limit != null && list.length > limit) {
        list = list.take(limit).toList();
      }
      setState(() {
        _items = list;
        _isLoading = false;
        // Only show "no internet" when check failed AND we got no data
        _hasNoInternet = !hasInternet && list.isEmpty;
      });
    } catch (e) {
      print('Error loading ${widget.config.appBarTitle}: $e');
      if (!mounted) return;
      setState(() {
        _items = [];
        _isLoading = false;
        // Only show "no internet" when the connection check actually failed.
        // Other errors (timeout, server error, parse) are not necessarily no internet.
        _hasNoInternet = !hasInternet;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return Scaffold(
      appBar: AppBar(
        title: Text(config.appBarTitle),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder<String>(
        future: ThemeHelper.getThemeName(),
        builder: (context, snapshot) {
          final themeName = snapshot.data ?? 'Terang';
          final textColor = ThemeHelper.getTextColor(themeName);
          final backgroundColor = ThemeHelper.getContentBackgroundColor(themeName);
          final isDark = themeName == 'Gelap';

          return Stack(
            children: [
              Image.asset(
                'assets/images/bg.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                color: isDark ? Colors.black54 : null,
                colorBlendMode: isDark ? BlendMode.darken : null,
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Text(
                            config.listHeaderTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _isLoading
                              ? const SizedBox(height: 15)
                              : _hasNoInternet && _items.isEmpty
                                  ? Text(
                                      'Tiada sambungan internet',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.red[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      'Jumlah: ${_items.length} ${config.countLabel}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? Colors.grey[300] : Colors.black87,
                                      ),
                                    ),
                        ],
                      ),
                    ),
                    Divider(color: textColor.withOpacity(0.3)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ThemeHelper.getLoadingIndicatorColor(themeName),
                                ),
                              ),
                            )
                          : _hasNoInternet && _items.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.wifi_off,
                                        size: 64,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Tiada sambungan internet',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                        child: Text(
                                          'Sila semak sambungan internet anda dan cuba lagi.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark ? Colors.grey[400] : Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : _items.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Tiada kandungan tersedia',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isDark ? Colors.grey[400] : Colors.black54,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _items.length,
                                      itemBuilder: (context, index) {
                                        final item = _items[index];
                                        final title = item['title']?.toString() ?? 'Untitled';
                                        final subtitle = '${config.subtitleLabel} ${(item['index'] ?? index) + 1}';
                                        final args = config.getRouteArguments(item, index, _items);
                                        return Card(
                                          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                          elevation: 2,
                                          color: backgroundColor,
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: ThemeHelper.getAppBarColor(themeName),
                                              child: Text(
                                                '${(item['index'] ?? index) + 1}',
                                                style: TextStyle(
                                                  color: isDark ? Colors.white : Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: textColor,
                                              ),
                                            ),
                                            subtitle: Text(
                                              subtitle,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark ? Colors.grey[400] : Colors.black54,
                                              ),
                                            ),
                                            trailing: Icon(
                                              Icons.arrow_forward_ios,
                                              size: 16,
                                              color: textColor,
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pushNamed(config.routeName, arguments: args);
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
