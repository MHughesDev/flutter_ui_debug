import 'package:flutter/material.dart';
import '../navigation/app_destination.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'animated_navigation_button.dart';
import 'navigation_dropdown_menu.dart';

class CustomScaffold extends StatefulWidget {
  final Widget body;
  final String? title;
  final AppDestination destination;
  final List<AppDestination> destinations;
  final Function(AppDestination) onDestinationSelected;
  final String subscription;

  const CustomScaffold({
    super.key,
    required this.body,
    required this.destination,
    required this.destinations,
    required this.onDestinationSelected,
    this.title,
    this.subscription = 'free',
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  final GlobalKey _menuButtonKey = GlobalKey();
  final GlobalKey<NavigationDropdownMenuState> _dropdownMenuKey = GlobalKey<NavigationDropdownMenuState>();
  final GlobalKey _indicatorKey = GlobalKey();
  final ValueNotifier<double> _menuAnimationNotifier = ValueNotifier<double>(0.0);

  @override
  void dispose() {
    _menuAnimationNotifier.dispose();
    super.dispose();
  }

  void _handleDestinationTap(AppDestination destination) {
    NavigationDropdownMenu.closeAll();

    if (destination == widget.destination) {
      return;
    }

    widget.onDestinationSelected(destination);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = widget.destination;
    final isMenuOpen = _dropdownMenuKey.currentState?.isOpen ?? false;

    return AppBar(
      leadingWidth: AppSpacing.navigationButtonLeftOffset + 48.0,
      leading: Builder(
        builder: (context) {
          return Transform.translate(
            offset: Offset(AppSpacing.navigationButtonLeftOffset - 16.0, 0),
            child: NavigationDropdownMenu(
              key: _dropdownMenuKey,
              destinations: widget.destinations,
              selectedDestination: selected,
              onDestinationSelected: (destination) {
                _handleDestinationTap(destination);
              },
              subscription: widget.subscription,
              buttonKey: _menuButtonKey,
              animationNotifier: _menuAnimationNotifier,
              indicatorKey: _indicatorKey,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                alignment: Alignment.center,
                constraints: const BoxConstraints.tightFor(
                  width: 48.0,
                  height: 48.0,
                ),
                child: AnimatedNavigationButton(
                  buttonKey: _menuButtonKey,
                  selectedDestination: selected,
                  destinations: widget.destinations,
                  subscription: widget.subscription,
                  isMenuOpen: isMenuOpen,
                  menuAnimationNotifier: _menuAnimationNotifier,
                  indicatorKey: _indicatorKey,
                  onPressed: () {
                    _dropdownMenuKey.currentState?.toggle();
                  },
                ),
              ),
            ),
          );
        },
      ),
      automaticallyImplyLeading: false,
      title: widget.title != null
          ? Text(widget.title!)
          : null,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: isDark ? AppColors.dark.onBackground : AppColors.light.onBackground,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: widget.body,
    );
  }
}
