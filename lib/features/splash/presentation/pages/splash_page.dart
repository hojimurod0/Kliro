import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../register/presentation/pages/register_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  bool _navigated = false;
  String? _error;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset('assets/videos/kliro_intro.mp4')
          ..setLooping(false)
          ..addListener(_handleTick);

    _controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() => _initialized = true);
          _controller.play();
          _fallbackTimer = Timer(
            _controller.value.duration + const Duration(milliseconds: 500),
            _goNext,
          );
        })
        .catchError((Object error) {
          if (!mounted) return;
          setState(() => _error = error.toString());
          _fallbackTimer = Timer(const Duration(seconds: 2), _goNext);
        });
  }

  void _handleTick() {
    if (!mounted || _navigated) return;
    final value = _controller.value;
    if (value.isInitialized &&
        !value.isPlaying &&
        value.position >= value.duration) {
      _goNext();
    }
  }

  void _goNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const RegisterPage()));
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller
      ..removeListener(_handleTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_error != null)
            Center(
              child: Text(
                'Video yuklanmadi:\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            )
          else if (_initialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}
