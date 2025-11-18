import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IntroTwoPage extends StatefulWidget {
  const IntroTwoPage({super.key});

  @override
  State<IntroTwoPage> createState() => _IntroTwoPageState();
}

class _IntroTwoPageState extends State<IntroTwoPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        SvgPicture.asset(
          'assets/images/bino.svg',
          fit: BoxFit.cover,
        ),
        Container(
          alignment: Alignment.center,
          child: SlideTransition(
            position: _slide,
            child: ScaleTransition(
              scale: _scale,
              child: _KLogo(),
            ),
          ),
        ),
      ],
    );
  }
}

class _KLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simple stylized K using two triangles
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.785398, // -45 degrees
            child: Container(
              width: 18,
              height: 60,
              color: Colors.black87,
            ),
          ),
          Positioned(
            right: 20,
            child: Transform.rotate(
              angle: 0.785398, // 45 degrees
              child: Container(
                width: 18,
                height: 60,
                color: Colors.black87,
              ),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(2),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
