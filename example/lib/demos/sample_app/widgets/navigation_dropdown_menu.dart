import 'dart:ui';
import 'package:flutter/material.dart';
import '../navigation/app_destination.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';

/// Glassmorphic dropdown navigation menu with sequenced drawing animation
class NavigationDropdownMenu extends StatefulWidget {
  static void closeAll() {
    NavigationDropdownMenuState.closeAll();
  }

  final Widget child;
  final List<AppDestination> destinations;
  final AppDestination selectedDestination;
  final Function(AppDestination) onDestinationSelected;
  final String subscription;
  final GlobalKey buttonKey;
  final ValueNotifier<double>? animationNotifier;
  final GlobalKey? indicatorKey;

  const NavigationDropdownMenu({
    super.key,
    required this.child,
    required this.destinations,
    required this.selectedDestination,
    required this.onDestinationSelected,
    required this.subscription,
    required this.buttonKey,
    this.animationNotifier,
    this.indicatorKey,
  });

  @override
  State<NavigationDropdownMenu> createState() => NavigationDropdownMenuState();
}

class NavigationDropdownMenuState extends State<NavigationDropdownMenu>
    with SingleTickerProviderStateMixin {
  static final Set<NavigationDropdownMenuState> _instances =
      <NavigationDropdownMenuState>{};
  
  static const double _menuWidth = 56.0;

  static void closeAll() {
    for (final instance in _instances.toList()) {
      if (instance.mounted) {
        instance._close();
      }
    }
  }

  late final AnimationController _animationController;
  late final Animation<double> _animation;
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _instances.add(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.addListener(() {
      widget.animationNotifier?.value = _animationController.value;
      if (_overlayEntry != null) {
        _overlayEntry?.markNeedsBuild();
      }
    });
  }

  @override
  void dispose() {
    _instances.remove(this);
    _close();
    _animationController.dispose();
    super.dispose();
  }

  void _open() {
    if (_isOpen) {
      _close();
      return;
    }

    setState(() {
      _isOpen = true;
    });

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
    widget.animationNotifier?.value = 1.0;
  }

  void _close() {
    if (!_isOpen) return;

    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      widget.animationNotifier?.value = 0.0;
      if (mounted) {
        setState(() {
          _isOpen = false;
        });
      }
    });
  }

  Future<void> closeAndWait() async {
    if (!_isOpen) return;

    _isOpen = false;
    await _animationController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    widget.animationNotifier?.value = 0.0;
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox? buttonBox =
        widget.buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    final buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final buttonSize = buttonBox.size;
    final buttonCenterX = buttonPosition.dx + buttonSize.width / 2;
    final menuLeft = buttonCenterX - _menuWidth / 2;
    final menuTop = buttonPosition.dy + buttonSize.height + 8;
    final int itemCount = widget.destinations.length;
    final double menuHeight = itemCount * 48.0 + 16;
    final menuRect = Rect.fromLTWH(menuLeft, menuTop, _menuWidth, menuHeight);
    final buttonRect = Rect.fromLTWH(buttonPosition.dx, buttonPosition.dy, buttonSize.width, buttonSize.height);

    return OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapDown: (details) {
                        final tapPosition = details.globalPosition;
                        if (!menuRect.contains(tapPosition) && !buttonRect.contains(tapPosition)) {
                          _close();
                        }
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  Positioned(
                    left: buttonPosition.dx,
                    top: buttonPosition.dy,
                    width: buttonSize.width,
                    height: buttonSize.height,
                    child: IgnorePointer(
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final RenderBox? currentButtonBox =
                          widget.buttonKey.currentContext?.findRenderObject() as RenderBox?;
                      if (currentButtonBox == null) {
                        return const SizedBox.shrink();
                      }
                      
                      final currentButtonPosition = currentButtonBox.localToGlobal(Offset.zero);
                      final currentButtonSize = currentButtonBox.size;
                      final currentButtonCenterX = currentButtonPosition.dx + currentButtonSize.width / 2;
                      final currentMenuLeft = currentButtonCenterX - _menuWidth / 2;
                      final currentMenuTop = currentButtonPosition.dy + currentButtonSize.height + 8;
                      
                      return Positioned(
                        left: currentMenuLeft,
                        top: currentMenuTop,
                        child: GestureDetector(
                          onTap: () {},
                          child: _buildDropdown(context, currentMenuLeft, currentMenuTop),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown(BuildContext context, double menuLeft, double menuTop) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const double iconSize = 24.0;
    const double itemHeight = 48.0;
    final int itemCount = widget.destinations.length;
    final double menuHeight = itemCount * itemHeight + 16;
    const double menuWidth = _menuWidth;
    const double borderRadius = 32.0;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;

        final outlineProgress = (value / 0.5).clamp(0.0, 1.0);
        final glassOpacity = value > 0.5 ? ((value - 0.5) / 0.3).clamp(0.0, 1.0) : 0.0;
        final contentOpacity = value > 0.8 ? ((value - 0.8) / 0.2).clamp(0.0, 1.0) : 0.0;

        final height = menuHeight * value;

        final effectiveBorderRadius = height < (borderRadius * 2)
            ? (height / 2).clamp(0.0, borderRadius)
            : borderRadius;

        final glassColor = isDark
            ? Colors.black.withValues(alpha: 0.2 * glassOpacity)
            : Colors.white;
        final outlineColor = isDark ? Colors.white : Colors.black;
        final iconColor = isDark ? Colors.white : Colors.black;

        final container = Container(
          width: menuWidth,
          height: height,
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            border: isDark
                ? Border.all(
                    color: outlineColor.withValues(alpha: 0.3 * outlineProgress),
                    width: 1.0,
                  )
                : null,
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15 * glassOpacity),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              fit: StackFit.expand,
              children: [
                if (value > 0 && isDark)
                  Positioned.fill(
                    child: ClipRect(
                      child: CustomPaint(
                        size: Size(menuWidth, height),
                        painter: _OutlineDrawPainter(
                          progress: outlineProgress,
                          color: outlineColor.withValues(alpha: 0.3),
                          strokeWidth: 1.0,
                          radius: effectiveBorderRadius,
                        ),
                      ),
                    ),
                  ),
                if (value > 0.8)
                  Positioned.fill(
                    child: Opacity(
                      opacity: contentOpacity,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: menuWidth,
                            maxHeight: height,
                            minHeight: 0,
                          ),
                          child: SizedBox(
                            width: menuWidth,
                            height: height,
                            child: ClipRect(
                              clipBehavior: Clip.hardEdge,
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 8),
                                    for (int i = 0; i < itemCount; i++)
                                      _buildMenuItem(
                                        context,
                                        widget.destinations[i],
                                        i,
                                        iconSize,
                                        itemHeight,
                                        iconColor,
                                        isDark,
                                      ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );

        if (!isDark) return container;

        return SizedBox(
          width: menuWidth,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            clipBehavior: Clip.hardEdge,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10.0 * glassOpacity,
                sigmaY: 10.0 * glassOpacity,
              ),
              child: SizedBox(
                width: menuWidth,
                height: height,
                child: ClipRect(
                  child: container,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    AppDestination destination,
    int index,
    double iconSize,
    double itemHeight,
    Color iconColor,
    bool isDark,
  ) {
    final isLocked = destination.requiresPremium &&
        widget.subscription != 'premium';
    final isSelected = widget.selectedDestination == destination;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await closeAndWait();
          if (mounted) {
            widget.onDestinationSelected(destination);
          }
        },
        child: SizedBox(
          height: itemHeight,
          width: _menuWidth,
          child: Center(
            child: isSelected
                ? Container(
                    key: widget.indicatorKey,
                    padding: const EdgeInsets.all(AppSpacing.xs),
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
                    child: Icon(
                      isLocked ? Icons.lock : destination.selectedIcon,
                      size: iconSize,
                      color: isDark ? AppColors.dark.onPrimary : AppColors.light.onPrimary,
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.light.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_outline : destination.icon,
                      size: iconSize,
                      color: isSelected
                          ? AppColors.light.primary
                          : iconColor.withValues(alpha: 0.7),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  bool get isOpen => _isOpen;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _OutlineDrawPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double radius;

  _OutlineDrawPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final path = Path()..addRRect(rrect);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final length = metric.length;

    final extractPath = metric.extractPath(0.0, length * progress);
    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant _OutlineDrawPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
