import 'package:flutter/material.dart';
import '../services/getasalusultafsir.dart' as getasalusultafsir;
import '../widgets/article_list_page.dart';

class AsalUsulTafsirPage extends StatelessWidget {
  const AsalUsulTafsirPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArticleListPage(
      config: ArticleListConfig(
        appBarTitle: 'Ilmu Usul Tafsir',
        loadItems: () async {
          final list = await getasalusultafsir.GetAsalUsulTafsir.getAsalUsulTafsirPosts();
          return list.map((m) => Map<String, dynamic>.from(m)).toList();
        },
        routeName: '/baca-asal-usul-tafsir',
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
