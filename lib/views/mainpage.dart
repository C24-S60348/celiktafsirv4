import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/baca.dart' as model;
import '../services/getlistsurah.dart' as getlist;
import '../models/tadabbur.dart' as surahlist;
import '../services/version_checker.dart';
import '../widgets/update_dialog.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Map<String, dynamic>? lastRead;
  bool isLoadingLastRead = true;
  final PageController _gridPageController = PageController();
  static const int _gridPageCount = 3;
  int _currentGridPage = 0;

  // Layout ratios (relative to rendered background image) – change these to resize grid/arrows
  static const double _buttonWidthRatio = 0.33;    // grid button width = image width * this
  static const double _buttonHeightRatio = 0.29;  // grid button height = image height * this
  static const double _arrowSlotSizeRatio = 0.06;  // left/right arrow slot size = image height * this
  static const double _arrowIconSizeRatio = 0.035; // arrow icon size = image height * this

  @override
  void initState() {
    super.initState();
    _loadLastRead();
    _checkForUpdates();
    _gridPageController.addListener(_onGridPageChanged);
  }

  @override
  void dispose() {
    _gridPageController.removeListener(_onGridPageChanged);
    _gridPageController.dispose();
    super.dispose();
  }

  void _onGridPageChanged() {
    if (!_gridPageController.hasClients) return;
    final page = (_gridPageController.page ?? 0).round();
    if (page != _currentGridPage && mounted) {
      setState(() => _currentGridPage = page);
    }
  }
  
  void _checkForUpdates() async {
    // Wait a bit for the page to load
    await Future.delayed(Duration(seconds: 2));
    
    try {
      print('🔄 Auto-checking for updates on app start...');
      final notifications = await VersionChecker.checkForUpdate();
      
      print('📬 Found ${notifications.length} notification(s)');
      
      // Show all notifications (update first, then news) one by one
      if (notifications.isNotEmpty && mounted) {
        // Sort so updates come before news
        notifications.sort((a, b) {
          if (a.isNews == b.isNews) return 0;
          return a.isNews ? 1 : -1; // Updates (isNews=false) first
        });
        
        for (var i = 0; i < notifications.length; i++) {
          final notification = notifications[i];
          print('📢 Showing notification ${i + 1}/${notifications.length}: ${notification.title ?? (notification.isNews ? "News" : "Update")}');
          if (mounted) {
            await UpdateDialog.show(context, notification);
          }
        }
      } else {
        print('✅ No updates or news to show (or already dismissed)');
      }
    } catch (e) {
      print('❌ Error checking for updates: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload last read when returning to this page (only if not already loading)
    if (!isLoadingLastRead) {
      _loadLastRead();
    }
  }

  void _loadLastRead() async {
    try {
      final savedLastRead = await model.getLastRead();
      if (mounted) {
        setState(() {
          lastRead = savedLastRead;
          isLoadingLastRead = false;
        });
      }
    } catch (e) {
      print('Error loading last read: $e');
      if (mounted) {
        setState(() {
          isLoadingLastRead = false;
        });
      }
    }
  }

  void _navigateToLastRead() async {
    if (lastRead == null) return;
    
    try {
      final surahIndex = lastRead!['surahIndex'] as int;
      final pageIndex = lastRead!['pageIndex'] as int;
      final categoryUrl = lastRead!['categoryUrl'] as String?;
      
      // Get surah data from the service
      final surah = await getlist.GetListSurah.getSurahByIndex(surahIndex, categoryUrl: categoryUrl);
      if (surah != null && mounted) {
        // Get surah name and arabic name from surahlist
        final surahNumber = surahIndex + 1;
        String surahName = lastRead!['surahName'] as String? ?? '';
        String surahNameArab = '';
        
        // Try to get from surahlist
        if (surahNumber > 0 && surahNumber <= surahlist.surahList.length) {
          final surahData = surahlist.surahList[surahNumber - 1];
          surahName = surahData['name'] ?? surahName;
          surahNameArab = surahData['name_arab'] ?? '';
        }
        
        await Navigator.of(context).pushNamed('/baca', arguments: {
          'number': surahNumber.toString().padLeft(3, '0'),
          'name': surahName,
          'name_arab': surahNameArab,
          'surahIndex': surahIndex,
          'pageIndex': pageIndex,
          'pageTitle': lastRead!['pageTitle'] as String?,
          'category_url': categoryUrl,
        });
        
        // Reload last read after navigation
        _loadLastRead();
      }
    } catch (e) {
      print('Error navigating to last read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions (screenHeight used for Container; width from LayoutBuilder)
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate button size to match the background image buttons
    // Based on the Kandungan.png image analysis:
    // - Buttons take up approximately 36% of width and 27% of height each
    // - With rounded corners matching the image
    
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   title: Text('Celik Tafsir', style: TextStyle(color: Colors.white),),
      //   centerTitle: true,
      //   automaticallyImplyLeading: false, // Disables back button
      //   backgroundColor: Colors.black,
      // ),
      body: Container(
        color: Colors.black,
        height: screenHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main image that dictates the layout for buttons
            LayoutBuilder(
              builder: (context, constraints) {
                // Determine the actual rendered size and position of the image
                final double availableWidth = constraints.maxWidth;
                final double availableHeight = constraints.maxHeight;
                
                // Assuming Kandungan.png has an aspect ratio (width / height) of roughly 0.5625 (1080 / 1920)
                // We'll calculate the actual rendered image dimensions given BoxFit.contain
                double imageAspectRatio = 0.5625; 
                double renderedImageWidth;
                double renderedImageHeight;
                double imageOffsetX = 0;
                double imageOffsetY = 0;
                double buttonWidth = 0;
                double buttonHeight = 0;

                if (availableWidth / availableHeight > imageAspectRatio) {
                  // Screen is wider than image, image height is limited
                  renderedImageHeight = availableHeight;
                  renderedImageWidth = availableHeight * imageAspectRatio;
                  imageOffsetX = (availableWidth - renderedImageWidth) / 2; // Center horizontally
                } else {
                  // Screen is taller than image, image width is limited
                  renderedImageWidth = availableWidth;
                  renderedImageHeight = availableWidth / imageAspectRatio;
                  imageOffsetY = (availableHeight - renderedImageHeight) / 2; // Center vertically
                }

                buttonWidth = renderedImageWidth * _buttonWidthRatio;
                buttonHeight = renderedImageHeight * _buttonHeightRatio;
                final arrowSlotSize = renderedImageHeight * _arrowSlotSizeRatio;

                return Stack(
                  children: [
                    // The background image itself
                    Image.asset(
                      'assets/images/Kandungan empty.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      width: availableWidth,
                      height: availableHeight,
                    ),

                    // --- Scrollable 2x2 grids (3 pages) + left/right page buttons ---
                    Positioned(
                      left: imageOffsetX + renderedImageWidth * 0.04,
                      right: imageOffsetX + renderedImageWidth * 0.04,
                      top: imageOffsetY + renderedImageHeight * 0.25,
                      height: renderedImageHeight * 0.60,
                      child: Row(
                        children: [
                          // Left slot: same size always; show button only when not on first page
                          SizedBox(
                            width: arrowSlotSize,
                            height: arrowSlotSize,
                            child: _currentGridPage > 0
                                ? IconButton(
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: Colors.black,
                                      size: renderedImageHeight * _arrowIconSizeRatio,
                                    ),
                                    onPressed: () {
                                      if (_gridPageController.hasClients && _currentGridPage > 0) {
                                        setState(() => _currentGridPage = _currentGridPage - 1);
                                        _gridPageController.animateToPage(
                                          _currentGridPage,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: const CircleBorder(),
                                      shadowColor: Colors.black,
                                      elevation: 5,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          SizedBox(width: renderedImageWidth * 0.01),
                          // PageView: 3 pages of 2x2 grids; swipe or use arrows to change page
                          Expanded(
                            child: PageView(
                              controller: _gridPageController,
                              children: [
                                _buildGridPage(context, buttonWidth, buttonHeight, pageIndex: 0),
                                _buildGridPage(context, buttonWidth, buttonHeight, pageIndex: 1),
                                _buildGridPage(context, buttonWidth, buttonHeight, pageIndex: 2),
                              ],
                            ),
                          ),
                          SizedBox(width: renderedImageWidth * 0.01),
                          // Right slot: same size always; show button only when not on last page
                          SizedBox(
                            width: arrowSlotSize,
                            height: arrowSlotSize,
                            child: _currentGridPage < _gridPageCount - 1
                                ? IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward,
                                      color: Colors.black,
                                      size: renderedImageHeight * _arrowIconSizeRatio,
                                    ),
                                    onPressed: () {
                                      if (_gridPageController.hasClients && _currentGridPage < _gridPageCount - 1) {
                                        setState(() => _currentGridPage = _currentGridPage + 1);
                                        _gridPageController.animateToPage(
                                          _currentGridPage,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: const CircleBorder(),
                                      shadowColor: Colors.black,
                                      elevation: 5,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                    // Last Read Section – position and size follow the rendered image (same as grid/arrows)
                    if (!isLoadingLastRead && lastRead != null)
                      Positioned(
                        left: imageOffsetX,
                        right: imageOffsetX,
                        bottom: imageOffsetY + renderedImageHeight * 0.05, // 5% from image bottom
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // constraints.maxWidth = image width; all sizes use renderedImageHeight/Width
                            final currentRenderedWidth = constraints.maxWidth;
                          final horizontalMargin = currentRenderedWidth * 0.08; // 8% margin
                          final ornamentSize = renderedImageHeight * 0.07; 
                          final containerHeight = renderedImageHeight * 0.11;
                          final titleFontSize = renderedImageHeight * 0.015; 
                          final nameFontSize = renderedImageHeight * 0.018; 
                          final subtitleFontSize = renderedImageHeight * 0.015; 
                          
                          return SizedBox( // Wrap in SizedBox to limit height
                            height: containerHeight,
                            child: GestureDetector(
                              onTap: _navigateToLastRead,
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: horizontalMargin,
                                  vertical: renderedImageHeight * 0.01,
                                ),
                                constraints: BoxConstraints(
                                  minHeight: containerHeight * 0.85,
                                  maxHeight: containerHeight,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: currentRenderedWidth * 0.03,
                                  vertical: renderedImageHeight * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF2C2C2C), // Dark grey matching the bottom bar in Kandungan.png
                                  borderRadius: BorderRadius.circular(20), // Fully rounded
                                  border: Border.all(
                                    color: Color(0xFF4A4A4A).withOpacity(0.3), // Subtle warm grey border
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.6),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                      offset: Offset(0, -3),
                                    ),
                                    BoxShadow(
                                      color: Color(0xFF3A3A3A).withOpacity(0.2),
                                      blurRadius: 6,
                                      spreadRadius: -1,
                                      offset: Offset(0, -1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Silver floral ornament on the left
                                    Container(
                                      width: ornamentSize,
                                      height: ornamentSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Color(0xFFD4D4D4), // Silver-grey center matching Kandungan.png
                                            Color(0xFFB8B8B8), // Medium silver-grey
                                            Color(0xFF9C9C9C), // Darker silver-grey edge
                                          ],
                                          stops: [0.0, 0.6, 1.0],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFFB8B8B8).withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                            offset: Offset(0, 2),
                                          ),
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 6,
                                            spreadRadius: -1,
                                            offset: Offset(0, -2),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Outer decorative rings
                                          Container(
                                            width: ornamentSize * 0.8,
                                            height: ornamentSize * 0.8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Color(0xFFE0E0E0).withOpacity(0.5),
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: ornamentSize * 0.7,
                                            height: ornamentSize * 0.7,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Color(0xFFE0E0E0).withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          // Center floral pattern
                                          CustomPaint(
                                            size: Size(ornamentSize * 0.4, ornamentSize * 0.4),
                                            painter: FloralOrnamentPainter(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: currentRenderedWidth * 0.03),
                                    // Text content with proper constraints
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Bacaan Terakhir',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: titleFontSize,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 1.0,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          // SizedBox(height: renderedImageHeight * 0.003),
                                          // Text(
                                          //   lastRead!['surahName'] as String? ?? '',
                                          //   style: TextStyle(
                                          //     color: Colors.white,
                                          //     fontSize: nameFontSize,
                                          //     fontWeight: FontWeight.bold,
                                          //     letterSpacing: 0.3,
                                          //     height: 1.2,
                                          //   ),
                                          //   maxLines: 1,
                                          //   overflow: TextOverflow.ellipsis,
                                          // ),
                                          SizedBox(height: renderedImageHeight * 0.003),
                                          Builder(
                                            builder: (context) {
                                              if (lastRead!['pageTitle'] != null && 
                                                  (lastRead!['pageTitle'] as String).isNotEmpty) {
                                                return Text(
                                                  lastRead!['pageTitle'] as String,
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.9),
                                                    fontSize: subtitleFontSize,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.3,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                );
                                              } else {
                                                return Text(
                                                  'Halaman ${(lastRead!['pageIndex'] as int) + 1}',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.9),
                                                    fontSize: subtitleFontSize,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.3,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: currentRenderedWidth * 0.02),
                                    // Arrow icon to indicate it's tappable
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white.withOpacity(0.5),
                                      size: renderedImageHeight * 0.02,
                                    ),
                                    SizedBox(width: currentRenderedWidth * 0.01),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// One page of the grid: 2x2 buttons.
  /// Page 0: Tadabbur, Bookmarks, Pengaturan, Informasi
  /// Page 1: Glosari, Hujjah, Asmaul Husna, Ilmu Usul Tafsir
  /// Page 2: Hadis 40 Imam Nawawi, La Tahzan (+ 2 empty cells)
  Widget _buildGridPage(BuildContext context, double buttonWidth, double buttonHeight, {required int pageIndex}) {
    if (pageIndex == 0) {
      // Page 1: Tadabbur, Bookmarks, Pengaturan, Informasi
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGridButton(context, width: buttonWidth, height: buttonHeight,
                imagePath: 'assets/images/buttonTadabbur.png',
                onTap: () => Navigator.of(context).pushNamed('/tadabbur'),
              ),
              _buildGridButton(context, width: buttonWidth, height: buttonHeight,
                imagePath: 'assets/images/buttonbookmarks.png',
                onTap: () => Navigator.of(context).pushNamed('/bookmarks'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGridButton(context, width: buttonWidth, height: buttonHeight,
                imagePath: 'assets/images/buttontetetapan.png',
                onTap: () => Navigator.of(context).pushNamed('/settings'),
              ),
              _buildGridButton(context, width: buttonWidth, height: buttonHeight,
                imagePath: 'assets/images/buttoninformasi.png',
                onTap: () => Navigator.of(context).pushNamed('/info'),
              ),
            ],
          ),
        ],
      );
    }
    if (pageIndex == 1) {
      // Page 2: Glosari, Hujjah, Asmaul Husna, Ilmu Usul Tafsir
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGridButton(context, width: buttonWidth, height: buttonHeight,
                imagePath: 'assets/images/buttonglosari.png',
                onTap: () => Navigator.of(context).pushNamed('/glosari'),
              ),
              _buildGridButton(context, width: buttonWidth, height: buttonHeight,
                imagePath: 'assets/images/buttonhujjah.png',
                onTap: () => Navigator.of(context).pushNamed('/hujjah'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGridButton(context, width: buttonWidth, height: buttonHeight,
                imagePath: 'assets/images/buttonasmaulhusna.png',
                onTap: () => Navigator.of(context).pushNamed('/asmaul-husna'),
              ),
              _buildGridButton(context, width: buttonWidth, height: buttonHeight,
                imagePath: 'assets/images/buttonilmuusultafsir.png',
                onTap: () => Navigator.of(context).pushNamed('/asal-usul-tafsir'),
              ),
            ],
          ),
        ],
      );
    }
    // Page 3: Hadis 40 Imam Nawawi, La Tahzan (+ 2 empty cells)
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGridButton(context, width: buttonWidth, height: buttonHeight,
              imagePath: 'assets/images/buttonhadis40.png',
              onTap: () => Navigator.of(context).pushNamed('/hadis-40'),
            ),
            _buildGridButton(context, width: buttonWidth, height: buttonHeight,
              imagePath: 'assets/images/buttonlatahzan.png',
              onTap: () => Navigator.of(context).pushNamed('/laa-tahzan'),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: buttonWidth, height: buttonHeight), // hidden – not available
            SizedBox(width: buttonWidth, height: buttonHeight), // hidden – not available
          ],
        ),
      ],
    );
  }

  Widget _buildGridButton(
    BuildContext context, {
    required double width,
    required double height,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    const radius = 20.0;
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          minimumSize: Size(width, height),
          maximumSize: Size(width, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

// Custom painter for silver floral ornament with high detail
class FloralOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Outer decorative ring - silver-grey tone
    final outerRingPaint = Paint()
      ..color = Color(0xFFD4D4D4).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.9, outerRingPaint);

    // Main petal paint - silver-grey matching Kandungan.png
    final petalPaint = Paint()
      ..color = Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw 8-petaled floral pattern
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi) / 8;
      final petalStart = Offset(
        center.dx + radius * 0.25 * math.cos(angle),
        center.dy + radius * 0.25 * math.sin(angle),
      );
      final petalEnd = Offset(
        center.dx + radius * 0.85 * math.cos(angle),
        center.dy + radius * 0.85 * math.sin(angle),
      );

      // Draw petal line
      canvas.drawLine(petalStart, petalEnd, petalPaint);

      // Draw decorative dots at petal tips
      final dotPaint = Paint()
        ..color = Color(0xFFE0E0E0)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(petalEnd, 2.0, dotPaint);
    }

    // Inner decorative ring
    final innerRingPaint = Paint()
      ..color = Color(0xFFD4D4D4).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.2, innerRingPaint);

    // Center circle with gradient effect
    final centerPaint = Paint()
      ..color = Color(0xFFE0E0E0).withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.15, centerPaint);

    // Inner detail dots
    final detailDotPaint = Paint()
      ..color = Color(0xFFD4D4D4).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi) / 8;
      final dotPos = Offset(
        center.dx + radius * 0.35 * math.cos(angle),
        center.dy + radius * 0.35 * math.sin(angle),
      );
      canvas.drawCircle(dotPos, 1.5, detailDotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
