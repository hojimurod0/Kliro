import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
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
          return InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.photoUrls[index],
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error, color: Colors.white, size: 50),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 60.h,
        color: Colors.black54,
        child: Center(
          child: Text(
            '${_currentIndex + 1} / ${widget.photoUrls.length}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

