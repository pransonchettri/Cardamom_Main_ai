import 'package:flutter/material.dart';
import 'package:plant_ai/theme/app_theme.dart';

/// Bottom bar with a circular notch reserved for the raised, floating
/// Scan button ([ScanFabButton]) docked by [RootShell]. Hosts Home,
/// Library, History and Settings, plus the required developer credit.
class CardamomBottomNavBar extends StatelessWidget {
  /// 0 = Home, 1 = Library, 2 = History, 3 = Settings
  final int selected;
  final ValueChanged<int> onTap;

  const CardamomBottomNavBar({
    super.key,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = context.cardColor;
    final borderColor = context.borderColor;

    return BottomAppBar(
      color: cardColor,
      elevation: 0,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      padding: EdgeInsets.zero,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: borderColor)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(context.isDark ? 0.25 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 64,
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home_rounded,
                      label: 'Home',
                      active: selected == 0,
                      onTap: () => onTap(0),
                    ),
                    _NavItem(
                      icon: Icons.menu_book_outlined,
                      selectedIcon: Icons.menu_book_rounded,
                      label: 'Library',
                      active: selected == 1,
                      onTap: () => onTap(1),
                    ),
                    const SizedBox(width: 64), // reserved gap for the docked Scan button
                    _NavItem(
                      icon: Icons.history_outlined,
                      selectedIcon: Icons.history_rounded,
                      label: 'History',
                      active: selected == 2,
                      onTap: () => onTap(2),
                    ),
                    _NavItem(
                      icon: Icons.settings_outlined,
                      selectedIcon: Icons.settings_rounded,
                      label: 'Settings',
                      active: selected == 3,
                      onTap: () => onTap(3),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 6),
                  child: Text(
                    'By Pranson Chhetri',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: context.secondaryText.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.emeraldLight;
    final inactiveColor = context.secondaryText;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 52,
              height: 30,
              decoration: BoxDecoration(
                color: active ? activeColor.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                active ? selectedIcon : icon,
                color: active ? activeColor : inactiveColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
