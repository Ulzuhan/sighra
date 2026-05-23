import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final double blur;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.borderWidth = 0.8,
    this.blur = 12.0,
    this.backgroundColor = const Color(0x0DFFFFFF),
    this.borderColor = const Color(0x1F64DFDF),
    this.padding = const EdgeInsets.all(20.0),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Adapt opacity for ambient contrast
    final fillCol = isDark
        ? backgroundColor
        : Colors.white.withValues(alpha: 0.7);
        
    final borderCol = isDark
        ? borderColor
        : Colors.teal.withValues(alpha: 0.15);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: fillCol,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderCol,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
