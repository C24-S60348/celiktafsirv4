import 'package:flutter/material.dart';
import '../services/getlaa_tahzan.dart' as getlaatahz;
import '../widgets/article_list_page.dart';

class LaaTahzanPage extends StatelessWidget {
  const LaaTahzanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArticleListPage(
      config: ArticleListConfig(
        appBarTitle: 'La Tahzan',
        loadItems: () async {
          final list = await getlaatahz.GetLaaTahzan.getLaaTahzanPosts();
          return list.map((m) => Map<String, dynamic>.from(m)).toList();
        },
        routeName: '/baca-laa-tahzan',
        itemLimit: 7,
        getRouteArguments: (item, index, fullList) => {
          'url': item['url'],
          'title': item['title'],
          'index': index,
          if (fullList != null) ...{
            'total': fullList.length,
            'items': fullList,
          },
        },
      ),
    );
  }
}
