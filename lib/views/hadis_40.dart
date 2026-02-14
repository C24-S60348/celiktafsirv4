import 'package:flutter/material.dart';
import '../services/gethadis_40.dart' as gethadis40;
import '../widgets/article_list_page.dart';

class Hadis40Page extends StatelessWidget {
  const Hadis40Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ArticleListPage(
      config: ArticleListConfig(
        appBarTitle: 'Hadis 40 Imam Nawawi',
        loadItems: () async {
          final list = await gethadis40.GetHadis40.getHadis40Posts();
          return list.map((m) => Map<String, dynamic>.from(m)).toList();
        },
        routeName: '/baca-hadis-40',
        getRouteArguments: (item, index, fullList) => {
          'url': item['url'],
          'title': item['title'] ?? 'Hadis 40 Imam Nawawi',
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
