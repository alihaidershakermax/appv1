import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? theme.colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color ?? theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Overlay loading widget for full screen loading
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: LoadingWidget(message: message),
          ),
      ],
    );
  }
}

class TypingIndicator extends StatefulWidget {
  final Color? dotColor;
  final double dotSize;
  final Duration animationDuration;

  const TypingIndicator({
    super.key,
    this.dotColor,
    this.dotSize = 8.0,
    this.animationDuration = const Duration(milliseconds: 1400),
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      ),
    );

    _animations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    // Start animations with delays
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _animationControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = widget.dotColor ?? theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: _animations[index].value,
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// AI Thinking Animation
class AIThinkingIndicator extends StatefulWidget {
  final String? message;
  final Color? color;

  const AIThinkingIndicator({
    super.key,
    this.message,
    this.color,
  });

  @override
  State<AIThinkingIndicator> createState() => _AIThinkingIndicatorState();
}

class _AIThinkingIndicatorState extends State<AIThinkingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.linear,
      ),
    );
    
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.psychology_outlined,
                    size: 16,
                    color: color,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.message!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

// Message Streaming Effect
class StreamingText extends StatefulWidget {
  final String text;
  final Duration duration;
  final TextStyle? style;
  final VoidCallback? onComplete;

  const StreamingText({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 50),
    this.style,
    this.onComplete,
  });

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: Duration(
        milliseconds: widget.text.length * widget.duration.inMilliseconds,
      ),
      vsync: this,
    );

    _characterCount = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    _characterCount.addListener(() {
      setState(() {
        _displayText = widget.text.substring(0, _characterCount.value);
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void didUpdateWidget(StreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.dispose();
      _setupAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _displayText,
                style: widget.style,
              ),
              // Blinking cursor effect
              if (_controller.isAnimating)
                WidgetSpan(
                  child: BlinkingCursor(
                    color: widget.style?.color ?? Colors.black,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Blinking Cursor
class BlinkingCursor extends StatefulWidget {
  final Color? color;

  const BlinkingCursor({super.key, this.color});

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 2,
            height: 16,
            color: widget.color ?? Colors.black,
          ),
        );
      },
    );
  }
}