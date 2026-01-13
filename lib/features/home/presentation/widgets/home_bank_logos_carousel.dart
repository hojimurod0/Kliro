import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeBankLogosCarousel extends StatefulWidget {
  const HomeBankLogosCarousel({super.key});

  @override
  State<HomeBankLogosCarousel> createState() => _HomeBankLogosCarouselState();
}

class _HomeBankLogosCarouselState extends State<HomeBankLogosCarousel> {
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;

  // Payment logolar ro'yxati - assets/payment papkasidagi rasmlar
  final List<PaymentLogo> _paymentLogos = [
    PaymentLogo(name: 'Click', assetPath: 'assets/payment/click.webp'),
    PaymentLogo(name: 'Uzum Bank', assetPath: 'assets/payment/uzum.png'),
    PaymentLogo(name: 'Alif', assetPath: 'assets/payment/alif.png'),
    PaymentLogo(name: 'Multicard', assetPath: 'assets/payment/multicard.png'),
    PaymentLogo(name: 'СБП', assetPath: 'assets/payment/sbp.png'),
    PaymentLogo(name: 'Anorbank', assetPath: 'assets/payment/anorbank.png'),
    PaymentLogo(name: 'Oson', assetPath: 'assets/payment/oson.png'),
    PaymentLogo(name: 'Payme', assetPath: 'assets/payment/payme.png'),
    PaymentLogo(name: 'UzCard', assetPath: 'assets/payment/uzcard.png'),
    PaymentLogo(name: 'Humo', assetPath: 'assets/payment/humocard.png'),
    PaymentLogo(name: 'Trast Mobile', assetPath: 'assets/payment/trastMobile.png'),
    PaymentLogo(name: 'Xazna', assetPath: 'assets/payment/xazna.png'),
    PaymentLogo(name: 'Beepul', assetPath: 'assets/payment/beepul.svg'),
  ];

  @override
  void initState() {
    super.initState();
    // Widget render bo'lgandan keyin scrollni boshlash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    // 60 FPS uchun 16ms interval - silliq scroll
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) return;
      
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;
        final singleListWidth = maxScroll / 2; // Har bir ro'yxatning kengligi
        
        // Agar birinchi ro'yxatning oxiriga yetgan bo'lsa, seamless qaytish
        if (currentScroll >= singleListWidth - 1) {
          // Seamless infinite scroll - birinchi ro'yxatning boshiga qaytish
          _scrollController.jumpTo(currentScroll - singleListWidth);
        } else {
          // Silliq scroll - kichik qadam bilan harakat
          _scrollController.position.moveTo(
            currentScroll + 0.8, // Silliq harakat uchun kichik qadam
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        SizedBox(
          height: 80.h,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(), // Foydalanuvchi scroll qilolmaydi
            itemCount: _paymentLogos.length * 2, // Infinite scroll uchun 2 marta takrorlash
            itemBuilder: (context, index) {
              final logoIndex = index % _paymentLogos.length;
              final paymentLogo = _paymentLogos[logoIndex];
              final isSvg = paymentLogo.assetPath.endsWith('.svg');

              final isDark = Theme.of(context).brightness == Brightness.dark;
              
              return Container(
                width: 80.w,
                height: 80.h,
                margin: EdgeInsets.only(right: 16.w),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[300] : null, // Dark mode da kulrang fon, light mode da yo'q
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(12.w),
                alignment: Alignment.center,
                child: isSvg
                    ? _buildSvgImage(paymentLogo.assetPath, paymentLogo.name)
                    : _buildImage(paymentLogo.assetPath, paymentLogo.name),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String assetPath, String name) {
    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder(name);
      },
    );
  }

  Widget _buildSvgImage(String assetPath, String name) {
    return Builder(
      builder: (context) {
        try {
          return SvgPicture.asset(
            assetPath,
            fit: BoxFit.contain,
            placeholderBuilder: (context) => _buildPlaceholder(name),
          );
        } catch (e) {
          return _buildPlaceholder(name);
        }
      },
    );
  }

  Widget _buildPlaceholder(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'P',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class PaymentLogo {
  final String name;
  final String assetPath;

  PaymentLogo({
    required this.name,
    required this.assetPath,
  });
}

