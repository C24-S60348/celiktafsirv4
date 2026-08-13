import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/uihelper.dart';
import '../utils/theme_helper.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  String _version = 'Loading...';
  String _buildNumber = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      setState(() {
        _version = 'Unknown';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: ThemeHelper.getThemeName(),
        builder: (context, snapshot) {
          final themeName = snapshot.data ?? 'Terang';
          final backgroundColor = ThemeHelper.getContentBackgroundColor(themeName);
          final textColor = ThemeHelper.getTextColor(themeName);
          final isDark = themeName == 'Gelap';
          // Reading container: white in light (no border), theme background in dark
          final readingContainerColor = isDark ? backgroundColor : Colors.white;

          return Stack(
            children: [
              // Background image with dark overlay in dark mode
              Image.asset(
                'assets/images/bg.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                color: isDark ? Colors.black54 : null,
                colorBlendMode: isDark ? BlendMode.darken : null,
              ),
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    backgroundColor: ThemeHelper.getAppBarColor(themeName),
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    title: Text(
                      'Informasi',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    leading: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back),
                    ),
                  ),
                  // Reading content: full width, no border, white (light) or theme (dark)
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      color: readingContainerColor,
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mengenai Aplikasi',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 10),
                          Divider(color: textColor.withOpacity(0.3)),
                          Text(
                            'Qur\'an adalah bicara Allah ‎ﷻ buat hamba-hambaNya. Kita sebagai hamba amat dahagakan panduan daripadaNya dan tercari-cari cara yang paling praktikal untuk mendalami serta mendekatiNya.\n\n'
                            'Celiktafsir Apps ini dibangunkan dengan harapan dapat membantu pengguna di luar sana yang mencari tafsir Qur\'an dengan gaya bahasa santai serta lebih dekat dengan permasalahan seharian kita. Dengan penggunaan teknologi terkini, apps sebegini dapat memastikan kita boleh membaca dan menghayati tafsir Qur\'an di mana dan bila-bila masa sahaja.\n\n'
                            'Isi kandungan asal apps ini semuanya berasal daripada halaman web: http://celiktafsir.net\n\n'
                            'Antara features lain Celiktafsir:\n'
                            '▪Boleh dibaca secara Online atau Offline\n'
                            '▪Pelbagai pilihan warna mengikut selera pengguna\n'
                            '▪Bookmark halaman terakhir dibaca\n'
                            '▪Tutorial cara penggunaan apps disediakan\n'
                            '▪Bahasa tafsir yang santai dan bersahaja\n'
                            '▪Loncat dari surah ke surah dengan cepat\n'
                            '▪Boleh copy & paste ayat tafsir.\n\n'
                            'Moga dengan adanya apps, jiwa kita makin terpandu dengan panduan daripada Qur\'an.\n\n'
                            'Kandungan ini disediakan bagi tujuan pendidikan, berdasarkan tafsir muktabar Ahlus Sunnah wal Jamaah, dan tidak bertujuan menggantikan rujukan kitab asal atau fatwa pihak berautoriti.',
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 10),
                          Divider(color: textColor.withOpacity(0.3)),
                          SizedBox(height: 10),
                          Text(
                            'Versi: $_version${_buildNumber.isNotEmpty ? " ($_buildNumber)" : ""}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 10),
                          Divider(color: textColor.withOpacity(0.3)),
                          SizedBox(height: 10),
                          Text(
                            'Sebarang pertanyaan, saran, sila hubungi: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              launchUrl(Uri.parse('mailto:celiktafsirpro@gmail.com'));
                            },
                            child: Center(
                              child: Text(
                                'celiktafsirpro@gmail.com',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 51, 135, 54),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Divider(color: textColor.withOpacity(0.3)),
                          GestureDetector(
                            onTap: () {
                              launchUrl(Uri.parse('https://celiktafsir.net'));
                            },
                            child: Center(
                              child: Text(
                                'celiktafsir.net',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 51, 135, 54),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: myButtonBlack(context, 'Tutorial', () {
                              Navigator.of(context).pushNamed('/tutorial');
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
