import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:barwah_app/core/theme/app_colors.dart';
import 'package:barwah_app/core/widgets/app_brand_mark.dart';

/// الشعار وهو يطفو بهدوء: يصعد وينزل مع ميل خفيف، وتحته ظل يصغر ويكبر عكس
/// حركته. متحكم واحد بطيء، معزول بـ RepaintBoundary، ويتوقف وحده عندما تُغطّى
/// الشاشة أو عند إيقاف الحركات من إعدادات الجهاز.
class FloatingBrandMark extends StatefulWidget {
  const FloatingBrandMark({super.key, this.size = 96, this.iconSize = 58});

  final double size;
  final double iconSize;

  @override
  State<FloatingBrandMark> createState() => _FloatingBrandMarkState();
}

class _FloatingBrandMarkState extends State<FloatingBrandMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_reduce) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final amplitude = size * 0.09;
    final height = size + amplitude * 2 + size * 0.2;
    final shadowColor = AppColors.isDark
        ? Colors.black.withValues(alpha: 0.35)
        : AppColors.ink.withValues(alpha: 0.16);
    return RepaintBoundary(
      child: SizedBox(
        width: size * 1.4,
        height: height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _reduce ? 0.0 : _controller.value * 2 * math.pi;
            final bob = math.sin(t); // -1 (أعلى) .. 1 (أسفل)
            final tilt = math.sin(t * 0.5);
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                // الظل: يصغر عندما يرتفع الشعار ويكبر عندما ينزل.
                Positioned(
                  bottom: 0,
                  child: Transform.scale(
                    scaleX: 1 + 0.14 * bob,
                    child: Container(
                      width: size * 0.7,
                      height: size * 0.09,
                      decoration: BoxDecoration(
                        color: shadowColor,
                        borderRadius: BorderRadius.circular(size),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: amplitude + bob * amplitude,
                  child: Transform.rotate(
                    angle: tilt * 0.05,
                    child: AppBrandMark(
                      size: size,
                      iconSize: widget.iconSize,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
