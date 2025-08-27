import 'package:flutter/material.dart';

// Message Fade In Animation
class MessageFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const MessageFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<MessageFadeIn> createState() => _MessageFadeInState();
}

class _MessageFadeInState extends State<MessageFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// Message Bounce Animation
class MessageBounceIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const MessageBounceIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<MessageBounceIn> createState() => _MessageBounceInState();
}

class _MessageBounceInState extends State<MessageBounceIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

// Progressive Text Reveal
class ProgressiveTextReveal extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration characterDelay;
  final VoidCallback? onComplete;
  final bool showCursor;

  const ProgressiveTextReveal({
    super.key,
    required this.text,
    this.style,
    this.characterDelay = const Duration(milliseconds: 30),
    this.onComplete,
    this.showCursor = true,
  });

  @override
  State<ProgressiveTextReveal> createState() => _ProgressiveTextRevealState();
}

class _ProgressiveTextRevealState extends State<ProgressiveTextReveal> {
  String _displayedText = '';
  int _currentIndex = 0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    if (_currentIndex < widget.text.length) {
      Future.delayed(widget.characterDelay, () {
        if (mounted) {
          setState(() {
            _currentIndex++;
            _displayedText = widget.text.substring(0, _currentIndex);
          });
          _startAnimation();
        }
      });
    } else {
      setState(() {
        _isComplete = true;
      });
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: _displayedText,
            style: widget.style,
          ),
          if (!_isComplete && widget.showCursor)
            WidgetSpan(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: 2,
                  height: (widget.style?.fontSize ?? 16) * 1.2,
                  margin: const EdgeInsets.only(left: 1),
                  decoration: BoxDecoration(
                    color: widget.style?.color ?? Colors.black,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Shimmer Loading Effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? theme.colorScheme.surfaceVariant;
    final highlightColor = widget.highlightColor ?? 
        theme.colorScheme.onSurfaceVariant.withOpacity(0.1);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// Pulse Animation for Active Elements
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

// Floating Action Button with Ripple Effect
class FloatingRippleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final double size;

  const FloatingRippleButton({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor,
    this.size = 56.0,
  });

  @override
  State<FloatingRippleButton> createState() => _FloatingRippleButtonState();
}

class _FloatingRippleButtonState extends State<FloatingRippleButton>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onPressed != null ? _handleTap : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple Effect
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Container(
                width: widget.size * (1 + _rippleAnimation.value * 0.5),
                height: widget.size * (1 + _rippleAnimation.value * 0.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (widget.backgroundColor ?? theme.colorScheme.primary)
                      .withOpacity(0.3 * (1 - _rippleAnimation.value)),
                ),
              );
            },
          ),
          // Main Button
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.backgroundColor ?? theme.colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}