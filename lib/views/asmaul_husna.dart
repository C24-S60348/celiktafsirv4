import 'package:flutter/material.dart';
import '../services/getasmaulhusna.dart' as getasmaulhusna;
import '../utils/proxy_helper.dart';
import '../widgets/article_list_page.dart';

class AsmaulHusnaPage extends StatelessWidget {
  const AsmaulHusnaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArticleListPage(
      config: ArticleListConfig(
        appBarTitle: 'Asmaul Husna',
        listHeaderTitle: 'Pilih Halaman',
        countLabel: 'halaman',
        subtitleLabel: 'Halaman',
        loadItems: () async {
          final urlTitles = await getasmaulhusna.GetAsmaulHusna.getAsmaulHusnaPosts();
          return [
            for (var i = 0; i < urlTitles.length; i++)
              {
                'index': i,
                'title': urlTitles[i]['title'] ?? extractTitleFromUrl(urlTitles[i]['url'] ?? '', fallback: ''),
                'url': urlTitles[i]['url'] ?? '',
              }
          ];
        },
        routeName: '/baca-asmaul-husna',
        getRouteArguments: (item, index, fullList) => {
          'url': item['url'],
          'title': item['title'],
          'pageIndex': item['index'] ?? index,
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
