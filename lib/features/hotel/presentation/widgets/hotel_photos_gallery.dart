import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HotelPhotosGallery extends StatefulWidget {
  final List<String> photoUrls;
  final int initialIndex;

  const HotelPhotosGallery({
    Key? key,
    required this.photoUrls,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<HotelPhotosGallery> createState() => _HotelPhotosGalleryState();
}

class _HotelPhotosGalleryState extends State<HotelPhotosGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Colors.black; // Photo gallery should always be dark
    final textColor = Colors.white; // Photo gallery text should always be white
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        systemOverlayStyle: isDark 
            ? SystemUiOverlayStyle.light 
            : SystemUiOverlayStyle.dark,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photoUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: CachedNetworkImage(
                      imageUrl: widget.photoUrls[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: textColor,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.error_outline,
                          color: textColor,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 60.h,
        color: isDark ? Colors.black87 : Colors.black54,
        child: Center(
          child: Text(
            '${_currentIndex + 1} / ${widget.photoUrls.length}',
            style: TextStyle(
              color: textColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

