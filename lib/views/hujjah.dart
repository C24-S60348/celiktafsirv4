import 'package:flutter/material.dart';
import '../services/gethujjah.dart' as gethujjah;
import '../widgets/article_list_page.dart';

class HujjahPage extends StatelessWidget {
  const HujjahPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArticleListPage(
      config: ArticleListConfig(
        appBarTitle: 'Hujjah',
        loadItems: () async {
          final list = await gethujjah.GetHujjah.getHujjahPosts();
          return list.map((m) => Map<String, dynamic>.from(m)).toList();
        },
        routeName: '/baca-hujjah',
        getRouteArguments: (item, index, fullList) => {
          'url': item['url'],
          'title': item['title'],
          if (fullList != null) ...{
            'index': index,
            'total': fullList.length,
            'items': fullList,
          },
        },
      ),
    );
  }
}
