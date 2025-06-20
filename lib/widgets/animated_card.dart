import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double elevation;
  final double hoverElevation;
  final Duration duration;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.elevation = 2,
    this.hoverElevation = 10,
    this.duration = const Duration(milliseconds: 180),
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _elevationAnimation;
  Animation<double>? _scaleAnimation;
  Animation<Offset>? _offsetAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controller?.dispose();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.hoverElevation,
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.025,
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ));
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant AnimatedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.elevation != widget.elevation ||
        oldWidget.hoverElevation != widget.hoverElevation ||
        oldWidget.duration != widget.duration) {
      _initAnimations();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
      if (isHovered) {
        _controller?.forward();
      } else {
        _controller?.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = widget.backgroundColor ?? theme.colorScheme.surface;
    final hoverColor = isDark
        ? baseColor.withOpacity(0.96).withBlue((baseColor.blue + 10).clamp(0, 255))
        : baseColor.withOpacity(0.98).withBlue((baseColor.blue + 20).clamp(0, 255));

    if (_controller == null || _elevationAnimation == null || _scaleAnimation == null || _offsetAnimation == null) {
      // Sécurité : si hot reload ou init raté, on affiche la carte sans animation
      return Material(
        elevation: widget.elevation,
        color: baseColor,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(18),
            child: widget.child,
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: _controller!,
        builder: (context, child) {
          return Transform.translate(
            offset: _offsetAnimation!.value * 16,
            child: Transform.scale(
              scale: _scaleAnimation!.value,
              child: Material(
                elevation: _elevationAnimation!.value,
                color: _isHovered ? hoverColor : baseColor,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: widget.padding ?? const EdgeInsets.all(18),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
} 