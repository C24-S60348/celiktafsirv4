import 'dart:async';

import 'package:flutter/material.dart';

import '../services/search_service.dart';
import '../utils/theme_helper.dart';

/// "Carian Lanjutan" -- searches the whole site (every section, full post
/// content, not just surah names) by delegating to celiktafsir.net's own
/// WordPress search. See [SearchService] for why that beats a local index.
///
/// Results open through the generic single-article reader
/// (`/baca-hujjah`, `index: 0, total: 1`) -- the same route shared links use
/// -- since a search hit can be a surah tafsir, Hujjah, Hadis 40, Glosari or
/// Asal Usul Tafsir post, and that route only ever needed a URL.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  String _query = '';
  int _page = 1;
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _hasMore = false;
  String? _error;
  final List<SearchResult> _results = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    // Rebuild immediately so the clear (x) button appears/disappears as soon
    // as the field empties, rather than waiting on the search debounce below.
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _runSearch(value));
  }

  Future<void> _runSearch(String query) async {
    final trimmed = query.trim();
    setState(() {
      _query = trimmed;
      _page = 1;
      _results.clear();
      _hasMore = false;
      _error = null;
      _hasSearched = trimmed.isNotEmpty;
    });

    if (trimmed.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final page = await SearchService.search(trimmed, page: 1);
      if (!mounted || trimmed != _query) return;
      setState(() {
        _results.addAll(page.results);
        _hasMore = page.hasMore;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || trimmed != _query) return;
      setState(() {
        _error = 'Carian gagal. Sila cuba lagi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore || _query.isEmpty) return;
    final nextPage = _page + 1;
    setState(() => _isLoading = true);
    try {
      final page = await SearchService.search(_query, page: nextPage);
      if (!mounted || _query.isEmpty) return;
      setState(() {
        _page = nextPage;
        _results.addAll(page.results);
        _hasMore = page.hasMore;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _openResult(SearchResult result) {
    Navigator.of(context).pushNamed(
      '/baca-hujjah',
      arguments: <String, dynamic>{
        'url': result.url,
        'title': result.title,
        'index': 0,
        'total': 1,
        'items': const <Map<String, dynamic>>[],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: ThemeHelper.getThemeName(),
      builder: (context, snapshot) {
        final themeName = snapshot.data ?? 'Terang';
        final isDark = themeName == 'Gelap';
        final textColor = ThemeHelper.getTextColor(themeName);
        final backgroundColor = ThemeHelper.getContentBackgroundColor(themeName);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: ThemeHelper.getAppBarColor(themeName),
            title: const Text('Carian Lanjutan'),
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
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _controller,
                        autofocus: true,
                        onChanged: _onChanged,
                        onSubmitted: _runSearch,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Cari ayat, tafsir, hujjah, artikel...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          prefixIcon: Icon(Icons.search, color: textColor),
                          suffixIcon: _controller.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: Icon(Icons.clear, color: textColor),
                                  onPressed: () {
                                    _controller.clear();
                                    _runSearch('');
                                  },
                                ),
                          filled: true,
                          fillColor: backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(child: _buildBody(themeName, isDark, textColor, backgroundColor)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    String themeName,
    bool isDark,
    Color textColor,
    Color backgroundColor,
  ) {
    if (!_hasSearched) {
      return Center(
        child: Text(
          'Taip untuk mula mencari di seluruh laman Celik Tafsir.',
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black54),
        ),
      );
    }

    if (_error != null && _results.isEmpty) {
      return Center(
        child: Text(_error!, style: TextStyle(color: Colors.red[700])),
      );
    }

    if (_isLoading && _results.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            ThemeHelper.getLoadingIndicatorColor(themeName),
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Text(
          'Tiada hasil untuk "$_query"',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black54),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
          _loadMore();
        }
        return false;
      },
      child: ListView.builder(
        // The trailing spinner only appears while a next page is actually
        // being fetched -- showing it just because more exist would suggest
        // work in progress that has not started yet.
        itemCount: _results.length + (_hasMore && _isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _results.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ThemeHelper.getLoadingIndicatorColor(themeName),
                  ),
                ),
              ),
            );
          }

          final result = _results[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            elevation: 2,
            color: backgroundColor,
            child: ListTile(
              title: Text(
                result.title,
                style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
              ),
              subtitle: result.excerpt.isEmpty
                  ? null
                  : Text(
                      result.excerpt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.black54,
                      ),
                    ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
              onTap: () => _openResult(result),
            ),
          );
        },
      ),
    );
  }
}
