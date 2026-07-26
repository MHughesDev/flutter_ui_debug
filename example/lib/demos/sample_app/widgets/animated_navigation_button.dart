import 'package:flutter/material.dart';
import '../navigation/app_destination.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_radius.dart';

/// Animated navigation menu button that shows the current section indicator
/// and animates when the menu opens/closes
class AnimatedNavigationButton extends StatefulWidget {
  final AppDestination selectedDestination;
  final List<AppDestination> destinations;
  final String subscription;
  final bool isMenuOpen;
  final VoidCallback onPressed;
  final GlobalKey buttonKey;
  final ValueNotifier<double>? menuAnimationNotifier;
  final GlobalKey? indicatorKey;

  const AnimatedNavigationButton({
    super.key,
    required this.selectedDestination,
    required this.destinations,
    required this.subscription,
    required this.isMenuOpen,
    required this.onPressed,
    required this.buttonKey,
    this.menuAnimationNotifier,
    this.indicatorKey,
  });

  @override
  State<AnimatedNavigationButton> createState() => _AnimatedNavigationButtonState();
}

class _AnimatedNavigationButtonState extends State<AnimatedNavigationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;
  bool _isAnimating = false;

  // Size constants
  static const double _menuIndicatorSize = 32.0;
  static const double _buttonSize = 48.0;
  static const double _iconSize = 24.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: _menuIndicatorSize / _buttonSize,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
    ));

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.5),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    widget.menuAnimationNotifier?.addListener(_onMenuAnimationChanged);
    _animationController.addListener(_onAnimationChanged);

    if (widget.isMenuOpen) {
      _animationController.value = 1.0;
    }
  }

  void _onAnimationChanged() {
    final isAnimating = _animationController.value > 0.0 && _animationController.value < 1.0;
    if (isAnimating != _isAnimating) {
      setState(() {
        _isAnimating = isAnimating;
      });
    }
  }

  void _onMenuAnimationChanged() {
    if (widget.menuAnimationNotifier == null) return;
    final menuProgress = widget.menuAnimationNotifier!.value;
    
    if (widget.isMenuOpen) {
      if (menuProgress <= 0.3) {
        final buttonProgress = (menuProgress / 0.3).clamp(0.0, 1.0);
        _animationController.value = buttonProgress;
      } else {
        _animationController.value = 1.0;
      }
    } else {
      if (menuProgress > 0.2) {
        _animationController.value = 1.0;
      } else {
        final buttonProgress = (menuProgress / 0.2).clamp(0.0, 1.0);
        _animationController.value = buttonProgress;
      }
    }
  }

  @override
  void didUpdateWidget(AnimatedNavigationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.menuAnimationNotifier != oldWidget.menuAnimationNotifier) {
      oldWidget.menuAnimationNotifier?.removeListener(_onMenuAnimationChanged);
      widget.menuAnimationNotifier?.addListener(_onMenuAnimationChanged);
    }
    
    if (widget.menuAnimationNotifier != null) {
      _onMenuAnimationChanged();
    }
  }

  @override
  void dispose() {
    widget.menuAnimationNotifier?.removeListener(_onMenuAnimationChanged);
    _animationController.removeListener(_onAnimationChanged);
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedButton(BuildContext context, bool forOverlay) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLocked = widget.selectedDestination.requiresPremium &&
        widget.subscription != 'premium';

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final opacity = _opacityAnimation.value;
        final position = _positionAnimation.value;
        final progress = _animationController.value;
        final isClosing = !widget.isMenuOpen;
        
        final isInPhase3 = progress >= 0.6;
        final isInPhase2 = progress >= 0.4 && progress < 0.6;
        
        double scale;
        if (isClosing) {
          if (progress > 0.3) {
            scale = _menuIndicatorSize / _buttonSize;
          } else {
            final growProgress = (0.3 - progress) / 0.3;
            final curvedProgress = Curves.easeOut.transform(growProgress);
            final smallScale = _menuIndicatorSize / _buttonSize;
            scale = smallScale + (1.0 - smallScale) * curvedProgress;
          }
        } else {
          scale = _scaleAnimation.value;
        }
        
        scale = scale.clamp(0.1, 2.0);

        Offset wobble = Offset.zero;
        if (isInPhase2) {
          final wobbleProgress = (progress - 0.4) / 0.2;
          final bounceAmount = (1.0 - wobbleProgress) * 0.08 * (1.0 + 0.5 * (1.0 - wobbleProgress));
          wobble = Offset(0, bounceAmount);
        }

        final totalOffset = forOverlay
            ? (isInPhase2 ? wobble * _buttonSize : Offset.zero)
            : (isInPhase3
                ? position * _buttonSize
                : (isInPhase2 ? wobble * _buttonSize : Offset.zero));

        return Transform.translate(
          offset: totalOffset,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: Opacity(
              opacity: opacity,
              child: SizedBox(
                key: forOverlay ? null : widget.buttonKey,
                width: _buttonSize,
                height: _buttonSize,
                child: Container(
                  width: _buttonSize,
                  height: _buttonSize,
                  constraints: BoxConstraints.tightFor(
                    width: _buttonSize,
                    height: _buttonSize,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary(context),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.light.primary.withValues(alpha: 0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: forOverlay ? null : widget.onPressed,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Center(
                        child: Icon(
                          isLocked
                              ? Icons.lock
                              : widget.selectedDestination.selectedIcon,
                          size: _iconSize,
                          color: isDark
                              ? AppColors.dark.onPrimary
                              : AppColors.light.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isAnimating ? 0.0 : 1.0,
      child: _buildAnimatedButton(context, false),
    );
  }
}
