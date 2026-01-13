import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Custom tooltip widget that shows on tap
class TapBubbleTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final Duration autoDismiss;
  final double maxWidth;

  /// Dismiss currently visible tooltip (if any).
  static void dismissCurrent() {
    _TapBubbleTooltipState._dismissActive();
  }

  const TapBubbleTooltip({
    super.key,
    required this.child,
    required this.message,
    this.autoDismiss = const Duration(seconds: 3),
    this.maxWidth = 260,
  });

  @override
  State<TapBubbleTooltip> createState() => _TapBubbleTooltipState();
}

class _TapBubbleTooltipState extends State<TapBubbleTooltip> {
  static _TapBubbleTooltipState? _active;
  static void _dismissActive() {
    _active?._hide();
    _active = null;
  }

  final GlobalKey _targetKey = GlobalKey();
  OverlayEntry? _entry;
  Timer? _timer;
  bool _globalRouteAttached = false;
  Offset? _downPosition;

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  Rect? _targetRect() {
    final targetContext = _targetKey.currentContext;
    if (targetContext == null) return null;
    final renderBox = targetContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    final offset = renderBox.localToGlobal(Offset.zero);
    return offset & renderBox.size;
  }

  void _attachGlobalDismissRoute() {
    if (_globalRouteAttached) return;
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onGlobalPointerEvent);
    _globalRouteAttached = true;
  }

  void _detachGlobalDismissRoute() {
    if (!_globalRouteAttached) return;
    GestureBinding.instance.pointerRouter
        .removeGlobalRoute(_onGlobalPointerEvent);
    _globalRouteAttached = false;
  }

  void _onGlobalPointerEvent(PointerEvent event) {
    if (_entry == null) return;

    if (event is PointerScrollEvent) {
      _hide();
      return;
    }

    if (event is PointerDownEvent) {
      _downPosition = event.position;
      final rect = _targetRect();
      if (rect != null && rect.contains(event.position)) {
        return;
      }
      _hide();
      return;
    }

    if (event is PointerMoveEvent) {
      final start = _downPosition;
      if (start != null && (event.position - start).distance > 10) {
        _hide();
      }
    }
  }

  void _hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
    _detachGlobalDismissRoute();
    if (identical(_active, this)) _active = null;
  }

  void _toggle() {
    if (_entry != null) {
      _hide();
      return;
    }
    _show();
  }

  void _show() {
    if (!identical(_active, this)) {
      _dismissActive();
      _active = this;
    }

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final targetContext = _targetKey.currentContext;
    if (overlay == null || targetContext == null) return;

    final renderBox = targetContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final targetOffset = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;

    final media = MediaQuery.of(context);
    final screenW = media.size.width;
    final screenH = media.size.height;
    final topSafe = media.padding.top + 8;
    const margin = 8.0;

    const bubblePaddingH = 14.0;
    const bubblePaddingV = 10.0;
    const arrowH = 8.0;
    const arrowW = 14.0;

    final bg = AppColors.primaryBlue;
    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.25,
    );

    final bubbleMaxW = (widget.maxWidth).clamp(120.0, screenW - margin * 2);
    final painter = TextPainter(
      text: TextSpan(text: widget.message, style: textStyle),
      textDirection: Directionality.of(context),
      maxLines: 3,
      ellipsis: '…',
    )..layout(maxWidth: bubbleMaxW - bubblePaddingH * 2);

    final bubbleW =
        (painter.width + bubblePaddingH * 2).clamp(120.0, bubbleMaxW);
    final bubbleH = painter.height + bubblePaddingV * 2;

    final targetCenterX = targetOffset.dx + targetSize.width / 2;
    var left = targetCenterX - bubbleW / 2;
    left = left.clamp(margin, screenW - bubbleW - margin);

    final aboveTop = targetOffset.dy - bubbleH - arrowH - 10;
    final showAbove = aboveTop >= topSafe;

    final top = showAbove
        ? (targetOffset.dy - bubbleH - arrowH - 10)
        : (targetOffset.dy + targetSize.height + 10);

    final arrowLeftRaw = targetCenterX - left - arrowW / 2;
    final arrowLeft = arrowLeftRaw.clamp(12.0, bubbleW - arrowW - 12.0);

    _entry = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top.clamp(margin, screenH - bubbleH - arrowH - margin),
              child: Material(
                color: Colors.transparent,
                child: IgnorePointer(
                  ignoring: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: showAbove
                        ? [
                            _BubbleBody(
                              width: bubbleW,
                              paddingH: bubblePaddingH,
                              paddingV: bubblePaddingV,
                              background: bg,
                              text: widget.message,
                              textStyle: textStyle,
                            ),
                            _BubbleArrow(
                              left: arrowLeft,
                              width: bubbleW,
                              arrowW: arrowW,
                              arrowH: arrowH,
                              background: bg,
                              directionDown: true,
                            ),
                          ]
                        : [
                            _BubbleArrow(
                              left: arrowLeft,
                              width: bubbleW,
                              arrowW: arrowW,
                              arrowH: arrowH,
                              background: bg,
                              directionDown: false,
                            ),
                            _BubbleBody(
                              width: bubbleW,
                              paddingH: bubblePaddingH,
                              paddingV: bubblePaddingV,
                              background: bg,
                              text: widget.message,
                              textStyle: textStyle,
                            ),
                          ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
    _attachGlobalDismissRoute();
    _timer = Timer(widget.autoDismiss, _hide);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: KeyedSubtree(
        key: _targetKey,
        child: widget.child,
      ),
    );
  }
}

class _BubbleBody extends StatelessWidget {
  final double width;
  final double paddingH;
  final double paddingV;
  final Color background;
  final String text;
  final TextStyle textStyle;

  const _BubbleBody({
    required this.width,
    required this.paddingH,
    required this.paddingV,
    required this.background,
    required this.text,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}

class _BubbleArrow extends StatelessWidget {
  final double left;
  final double width;
  final double arrowW;
  final double arrowH;
  final Color background;
  final bool directionDown;

  const _BubbleArrow({
    required this.left,
    required this.width,
    required this.arrowW,
    required this.arrowH,
    required this.background,
    required this.directionDown,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: arrowH,
      child: CustomPaint(
        painter: _TrianglePainter(
          color: background,
          left: left,
          width: arrowW,
          height: arrowH,
          directionDown: directionDown,
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final double left;
  final double width;
  final double height;
  final bool directionDown;

  _TrianglePainter({
    required this.color,
    required this.left,
    required this.width,
    required this.height,
    required this.directionDown,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    if (directionDown) {
      path.moveTo(left, 0);
      path.lineTo(left + width / 2, height);
      path.lineTo(left + width, 0);
    } else {
      path.moveTo(left, height);
      path.lineTo(left + width / 2, 0);
      path.lineTo(left + width, height);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.left != left ||
        oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.directionDown != directionDown;
  }
}

