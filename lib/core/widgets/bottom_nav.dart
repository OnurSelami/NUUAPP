import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();

    final navItems = <_NavItem>[
      _NavItem(icon: LucideIcons.home, path: '/home', label: 'Home'),
      _NavItem(icon: LucideIcons.wind, path: '/breathe', label: 'Breathe'),
      _NavItem(icon: LucideIcons.headphones, path: '/escape', label: 'Sounds'),
      _NavItem(icon: LucideIcons.barChart2, path: '/analytics', label: 'Insights'),
      _NavItem(icon: LucideIcons.user, path: '/profile', label: 'Profile'),
    ];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: true,
        top: false,
        child: Container(
          padding: const EdgeInsets.only(bottom: 16),
          alignment: Alignment.center,
          child: Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x4D000000),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.glassBorder, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: navItems.map((item) {
                      final isActive = currentPath == item.path || 
                         (currentPath.startsWith(item.path) && item.path != '/home');
                      return GestureDetector(
                        onTap: () => context.go(item.path),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.glassWhite : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            item.icon,
                            size: 24,
                            color: isActive ? AppColors.accent : AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ).animate().slideY(begin: 2, end: 0, duration: 600.ms, delay: 500.ms, curve: Curves.easeOut),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String path;
  final String label;

  _NavItem({required this.icon, required this.path, required this.label});
}
