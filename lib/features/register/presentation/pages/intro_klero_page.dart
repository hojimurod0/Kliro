import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IntroKleroPage extends StatefulWidget {
  const IntroKleroPage({super.key, required this.onFinished});
  final VoidCallback onFinished;

  @override
  State<IntroKleroPage> createState() => _IntroKleroPageState();
}

class _IntroKleroPageState extends State<IntroKleroPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _kScale;
  late final Animation<Offset> _kSlide;

  static const _letters = [
    _LetterConfig(
      asset: 'assets/images/letter_l.svg',
      width: 40,
      height: 54,
      start: 0.35,
      end: 0.55,
    ),
    _LetterConfig(
      asset: 'assets/images/letter_i.svg',
      width: 10,
      height: 54,
      start: 0.45,
      end: 0.65,
    ),
    _LetterConfig(
      asset: 'assets/images/letter_r.svg',
      width: 43,
      height: 55,
      start: 0.55,
      end: 0.75,
    ),
    _LetterConfig(
      asset: 'assets/images/letter_o.svg',
      width: 55,
      height: 55,
      start: 0.65,
      end: 0.85,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 4200),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.onFinished();
            }
          })
          ..forward();

    _kScale =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0.2,
              end: 0.65,
            ).chain(CurveTween(curve: Curves.easeOutQuad)),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 0.65,
              end: 1,
            ).chain(CurveTween(curve: Curves.easeOutBack)),
            weight: 30,
          ),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6)),
        );

    _kSlide = Tween<Offset>(begin: Offset.zero, end: const Offset(-0.25, 0))
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.6, 0.85, curve: Curves.easeOut),
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final fadeOut = t < 0.9 ? 1.0 : ((1 - t) / 0.1).clamp(0.0, 1.0);

          final firstLetterProgress = _progressFor(_letters.first);
          final leadingSpacing = 16 * firstLetterProgress;

          final children = <Widget>[
            SlideTransition(
              position: _kSlide,
              child: ScaleTransition(
                scale: _kScale,
                child: SvgPicture.asset(
                  'assets/images/k_logo.svg',
                  width: 70,
                  height: 80,
                ),
              ),
            ),
            SizedBox(width: leadingSpacing),
          ];

          for (var i = 0; i < _letters.length; i++) {
            final config = _letters[i];
            final progress = _progressFor(config);
            final opacity = (progress * fadeOut).clamp(0.0, 1.0);
            final spacing = i == 0 ? 0.0 : 10 * progress;

            children
              ..add(SizedBox(width: spacing))
              ..add(
                _AnimatedLetter(
                  asset: config.asset,
                  width: config.width,
                  height: config.height,
                  progress: progress,
                  opacity: opacity,
                ),
              );
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: children,
          );
        },
      ),
    );
  }

  double _progressFor(_LetterConfig config) {
    final t = _controller.value;
    final normalized = ((t - config.start) / (config.end - config.start)).clamp(
      0.0,
      1.0,
    );
    return normalized;
  }
}

class _AnimatedLetter extends StatelessWidget {
  const _AnimatedLetter({
    required this.asset,
    required this.width,
    required this.height,
    required this.progress,
    required this.opacity,
  });

  final String asset;
  final double width;
  final double height;
  final double progress;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset((1 - progress) * 12, 0),
            child: SvgPicture.asset(asset, width: width, height: height),
          ),
        ),
      ),
    );
  }
}

class _LetterConfig {
  final String asset;
  final double width;
  final double height;
  final double start;
  final double end;

  const _LetterConfig({
    required this.asset,
    required this.width,
    required this.height,
    required this.start,
    required this.end,
  });
}
