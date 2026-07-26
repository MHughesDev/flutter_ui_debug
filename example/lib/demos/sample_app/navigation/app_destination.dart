import 'package:flutter/material.dart';

/// Primary top-level destinations rendered inside the global shell.
enum AppDestination {
  home(
    label: 'Today',
    icon: Icons.wb_sunny_outlined,
    selectedIcon: Icons.wb_sunny,
  ),
  notes(
    label: 'Notes',
    icon: Icons.note_outlined,
    selectedIcon: Icons.note,
  ),
  tasks(
    label: 'Tasks',
    icon: Icons.check_circle_outline,
    selectedIcon: Icons.check_circle,
  ),
  mindMap(
    label: 'Mind Map',
    icon: Icons.account_tree_outlined,
    selectedIcon: Icons.account_tree,
  ),
  calendar(
    label: 'Schedule',
    icon: Icons.calendar_today_outlined,
    selectedIcon: Icons.calendar_today,
  ),
  settings(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
  chat(
    label: 'AI Copilot',
    icon: Icons.smart_toy_outlined,
    selectedIcon: Icons.smart_toy,
    requiresPremium: true,
  );

  const AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.requiresPremium = false,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool requiresPremium;
}
