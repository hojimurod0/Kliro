import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/onboarding/onboarding_prefs.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _navigated = false;
  String? _error;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/videos/kliro_intro.mp4')
        ..setLooping(false)
        ..addListener(_handleTick);

      await _controller!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Video initialization timeout');
        },
      );
      
      if (!mounted) {
        _controller?.dispose();
        return;
      }
      
      if (!_controller!.value.isInitialized) {
        throw Exception('Video controller not initialized');
      }
      
      setState(() {
        _initialized = true;
      });
      
      await _controller!.play();
      
      _fallbackTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && !_navigated) {
          _controller?.pause();
          _goNext();
        }
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Platform error: ${e.message}\nCode: ${e.code}';
        _initialized = false;
      });
      _fallbackTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && !_navigated) {
          _goNext();
        }
      });
    } on TimeoutException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Timeout: ${e.message}';
        _initialized = false;
      });
      _fallbackTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && !_navigated) {
          _goNext();
        }
      });
    } catch (error, stackTrace) {
      if (!mounted) return;
      setState(() {
        _error = 'Error: $error\n${stackTrace.toString().split('\n').take(3).join('\n')}';
        _initialized = false;
      });
      _fallbackTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && !_navigated) {
          _goNext();
        }
      });
    }
  }

  void _handleTick() {
    if (!mounted || _navigated || _controller == null) return;
    final value = _controller!.value;
    // Video 3 soniyadan oshib ketmasligi uchun tekshirish
    if (value.isInitialized && value.position >= const Duration(seconds: 3)) {
      _controller?.pause();
      _goNext();
    }
  }

  Future<void> _goNext() async {
    if (_navigated || !mounted) return;
    _navigated = true;
    
    // Onboarding o'tilgan bo'lsa, to'g'ridan-to'g'ri home page ga o't
    final isCompleted = await OnboardingPrefs.isCompleted();
    if (isCompleted) {
      if (mounted) {
        context.router.replace(HomeRoute());
      }
    } else {
      // Onboarding o'tilmagan bo'lsa, onboarding page ga o't
      if (mounted) {
        context.router.replace(const OnboardingRoute());
      }
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    if (_controller != null) {
      _controller!
        ..removeListener(_handleTick)
        ..dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MouseRegion(
        cursor: SystemMouseCursors.none,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Error holat
            if (_error != null)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: AppColors.white,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        tr('splash.video_error'),
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyPrimary(context).copyWith(
                          fontSize: 16.sp,
                          color: AppColors.white,
                        ),
                      ),
                      if (_error != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption(context).copyWith(
                            color: AppColors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            // Video ko'rsatish - barcha telefonlar uchun to'g'ri format
            else if (_initialized && _controller != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: FittedBox(
                    // BoxFit.contain video'ni kesib qo'ymaydi va to'liq ko'rsatadi
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
