import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../widgets/screen_wrapper.dart';
import '../widgets/glass_card.dart';
import '../widgets/bottom_nav.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.settings, color: AppColors.accent, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Settings',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms),

                    const SizedBox(height: 32),

                    // Profile
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Guest User', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Create account to sync progress', style: TextStyle(color: AppColors.accent, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 32),

                    // Sections
                    const Text('PREFERENCES', style: TextStyle(color: AppColors.textMuted, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold))
                        .animate().fadeIn(duration: 600.ms, delay: 300.ms),
                    const SizedBox(height: 16),
                    
                    _SettingsGroup(
                      items: [
                        _SettingItem(icon: LucideIcons.bell, title: 'Notifications', hasToggle: true, isToggled: true),
                        _SettingItem(icon: LucideIcons.volume2, title: 'Default Volume'),
                        _SettingItem(icon: LucideIcons.moon, title: 'Dark Mode', hasToggle: true, isToggled: true),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                    const SizedBox(height: 32),

                    const Text('SUPPORT', style: TextStyle(color: AppColors.textMuted, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold))
                        .animate().fadeIn(duration: 600.ms, delay: 500.ms),
                    const SizedBox(height: 16),
                    
                    _SettingsGroup(
                      items: [
                        _SettingItem(icon: LucideIcons.helpCircle, title: 'Help & FAQ'),
                        _SettingItem(icon: LucideIcons.mail, title: 'Contact Support'),
                        _SettingItem(icon: LucideIcons.shield, title: 'Privacy Policy'),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                    
                    const SizedBox(height: 32),
                    
                    Center(
                      child: Text('NUU v1.0.0', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ).animate().fadeIn(duration: 600.ms, delay: 800.ms),
                  ],
                ),
              ),
            ),
            const BottomNav(),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingItem> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(item.icon, color: Colors.white70, size: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                    if (item.hasToggle)
                      Switch(
                        value: item.isToggled,
                        onChanged: (v) {},
                        activeThumbColor: AppColors.accent,
                        activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
                      )
                    else
                      Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 18),
                  ],
                ),
              ),
              if (i < items.length - 1)
                Divider(height: 1, color: AppColors.glassBorder, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final bool hasToggle;
  final bool isToggled;
  _SettingItem({required this.icon, required this.title, this.hasToggle = false, this.isToggled = false});
}
