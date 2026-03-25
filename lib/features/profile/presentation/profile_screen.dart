import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../energy_map/presentation/energy_map_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energy = ref.watch(energyMapProvider);
    final userEmail = ref.watch(authControllerProvider).email ?? 'Guest User';

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
                        const Icon(LucideIcons.user, color: AppColors.accent, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Profile',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms),

                    const SizedBox(height: 32),

                    // User Profile
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userEmail, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(userEmail == 'Guest User' ? 'Create account to sync progress' : 'Premium Member', style: TextStyle(color: AppColors.accent, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 32),

                    // Energy Insight
                    if (energy.insights.isNotEmpty)
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.sageGreen.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(LucideIcons.zap, color: AppColors.sageGreen, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(energy.insights.first.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(energy.insights.first.description, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.3)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 250.ms).slideY(begin: 0.1, end: 0),
                      
                    if (energy.insights.isNotEmpty)
                      const SizedBox(height: 32),

                    // Premium Card
                    GestureDetector(
                      onTap: () => context.push('/premium'),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.accent.withValues(alpha: 0.1), Colors.transparent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                        ),
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          backgroundColor: Colors.transparent,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(LucideIcons.crown, color: AppColors.accent, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Nuu Premium', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('Unlock all environments & sounds', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  ],
                                ),
                              ),
                              const Icon(LucideIcons.chevronRight, color: AppColors.accent, size: 20),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.1, end: 0),
                    ),

                    const SizedBox(height: 32),

                    // APPEARANCE section
                    const Text('PREFERENCES', style: TextStyle(color: AppColors.textMuted, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold))
                        .animate().fadeIn(duration: 600.ms, delay: 600.ms),
                    const SizedBox(height: 16),
                    
                    _SettingsGroup(
                      items: [
                        _SettingItem(
                          icon: LucideIcons.moon, 
                          title: 'Dark Mode', 
                          hasToggle: true, 
                          isToggled: true,
                          onTap: () => _showComingSoon(context),
                        ),
                        _SettingItem(
                          icon: LucideIcons.bell, 
                          title: 'Notifications', 
                          hasToggle: true, 
                          isToggled: true,
                          onTap: () => _showComingSoon(context),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 700.ms),

                    const SizedBox(height: 32),

                    // SUPPORT section
                    const Text('SUPPORT', style: TextStyle(color: AppColors.textMuted, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold))
                        .animate().fadeIn(duration: 600.ms, delay: 800.ms),
                    const SizedBox(height: 16),
                    
                    _SettingsGroup(
                      items: [
                        _SettingItem(
                          icon: LucideIcons.helpCircle, 
                          title: 'Help & FAQ',
                          onTap: () => _launchURL('https://support.nuuapp.com/faq'),
                        ),
                        _SettingItem(
                          icon: LucideIcons.mail, 
                          title: 'Contact Support',
                          onTap: () => _launchURL('mailto:support@nuuapp.com'),
                        ),
                        _SettingItem(
                          icon: LucideIcons.shield, 
                          title: 'Privacy Policy',
                          onTap: () => _launchURL('https://nuuapp.com/privacy'),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms, delay: 900.ms),
                    
                    const SizedBox(height: 48),

                    // LOG OUT
                    GestureDetector(
                      onTap: () {
                        ref.read(authControllerProvider.notifier).signOut();
                        context.go('/auth');
                      },
                      child: const Center(
                        child: Text(
                          'Log Out',
                          style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),

                    const SizedBox(height: 32),
                    
                    Center(
                      child: Text('NUU v1.0.0', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ).animate().fadeIn(duration: 600.ms, delay: 1100.ms),
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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is coming in a future update!'),
        backgroundColor: AppColors.bgDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
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
              InkWell(
                onTap: item.onTap,
                child: Padding(
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
                          onChanged: (v) {
                            if (item.onTap != null) item.onTap!();
                          },
                          activeThumbColor: AppColors.accent,
                          activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
                        )
                      else
                        Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 18),
                    ],
                  ),
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
  final VoidCallback? onTap;

  _SettingItem({
    required this.icon, 
    required this.title, 
    this.hasToggle = false, 
    this.isToggled = false, 
    this.onTap,
  });
}
