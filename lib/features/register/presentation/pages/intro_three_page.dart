import 'package:flutter/material.dart';

class IntroThreePage extends StatefulWidget {
  const IntroThreePage({super.key});

  @override
  State<IntroThreePage> createState() => _IntroThreePageState();
}

class _IntroThreePageState extends State<IntroThreePage>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _letterOp;
  late final List<Animation<Offset>> _letterSlide;
  final _text = ['K', 'L', 'I', 'R', 'O'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _letterOp = List.generate(
      _text.length,
      (i) => CurvedAnimation(
        parent: _controller,
        curve: Interval(0.1 * i, 0.4 + 0.1 * i, curve: Curves.easeOut),
      ),
    );
    _letterSlide = List.generate(
      _text.length,
      (i) => Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.1 * i, 0.5 + 0.1 * i, curve: Curves.easeOut),
        ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_text.length, (i) {
          final isK = i == 0;
          final isI = i == 2;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FadeTransition(
              opacity: _letterOp[i],
              child: SlideTransition(
                position: _letterSlide[i],
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      _text[i],
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (isK)
                      Positioned(
                        left: 2,
                        bottom: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    if (isI)
                      Positioned(
                        top: 2,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
