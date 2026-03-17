import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../premium/presentation/premium_controller.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumControllerProvider);
    final isPremium = premiumState.isPremium;
    
    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(gradient: AppColors.bgGradient),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary),
                          onPressed: () => context.pop(),
                        ),
                        const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: AppColors.textPrimary, 
                            fontSize: 12, 
                            fontWeight: FontWeight.w600, 
                            letterSpacing: 4.0
                          ),
                        ),
                        const SizedBox(width: 48), // Balance
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          
                          // Hero Graphic - Minimalist Crown
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.glassHover,
                              border: Border.all(color: AppColors.sageGreen.withValues(alpha: 0.3), width: 0.5),
                              boxShadow: [
                                BoxShadow(color: AppColors.sageGreen.withValues(alpha: 0.15), blurRadius: 40)
                              ],
                            ),
                            child: Icon(LucideIcons.crown, color: AppColors.sageGreen, size: 40),
                          ).animate().scale(duration: 800.ms, curve: Curves.easeOutCubic).fadeIn(),

                          const SizedBox(height: 48),
                          const Text(
                            'UNLIMITED REACH',
                            style: TextStyle(
                              color: AppColors.textPrimary, 
                              fontSize: 32, 
                              fontWeight: FontWeight.w200, 
                              letterSpacing: -1,
                              height: 1.1
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                          const SizedBox(height: 16),
                          Text(
                            'Access the full library of atmospheric environments and deep sleep states.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.6, letterSpacing: 0.5),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                          const SizedBox(height: 64),

                          // Features List
                          _FeatureRow(icon: LucideIcons.layers, title: 'All Premium Environments', delay: 400),
                          const SizedBox(height: 24),
                          _FeatureRow(icon: LucideIcons.moon, title: 'Deep Sleep Collection', delay: 500),
                          const SizedBox(height: 24),
                          _FeatureRow(icon: LucideIcons.waves, title: 'Atmospheric Tactile Modes', delay: 600),
                          const SizedBox(height: 24),
                          _FeatureRow(icon: LucideIcons.sparkles, title: 'High-Fidelity Spatial Audio', delay: 700),

                          const SizedBox(height: 64),

                          // Purchase / Status Area
                          if (premiumState.isLoading)
                            const CircularProgressIndicator(color: AppColors.sageGreen, strokeWidth: 2)
                          else if (isPremium)
                            GlassCard(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(LucideIcons.checkCircle2, color: AppColors.sageGreen, size: 40),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "You have full access.",
                                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w400),
                                  ),
                                  const SizedBox(height: 24),
                                  _ActionBtn(
                                    label: 'RETURN TO ALTAR',
                                    onTap: () => context.pop(),
                                    isPrimary: true,
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 800.ms)
                          else if (premiumState.availablePackages != null && premiumState.availablePackages!.isNotEmpty)
                            Column(
                              children: premiumState.availablePackages!.map((pkg) => _buildPricingOption(
                                ref: ref,
                                context: context,
                                pkg: pkg,
                              )).toList(),
                            )
                          else
                            const Text('No access keys available.', style: TextStyle(color: AppColors.textMuted)),

                          const SizedBox(height: 48),
                          GestureDetector(
                            onTap: () async {
                              final success = await ref.read(premiumControllerProvider.notifier).restorePurchases();
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Access Restored")),
                                );
                              }
                            },
                            child: const Text(
                              'RESTORE ACCESS',
                              style: TextStyle(
                                color: AppColors.textMuted, 
                                fontSize: 10, 
                                fontWeight: FontWeight.w600, 
                                letterSpacing: 2.0,
                                decoration: TextDecoration.underline
                              ),
                            ),
                          ).animate().fadeIn(delay: 1000.ms),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingOption({
    required WidgetRef ref,
    required BuildContext context,
    required Package pkg,
  }) {
    final isAnnual = pkg.packageType == PackageType.annual;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              pkg.packageType.name.toUpperCase(), 
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 2.0)
            ),
            const SizedBox(height: 8),
            Text(
              '${pkg.storeProduct.priceString} / ${pkg.packageType.name}', 
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12, letterSpacing: 1.0)
            ),
            const SizedBox(height: 24),
            _ActionBtn(
              label: isAnnual ? 'BEST VALUE' : 'START JOURNEY',
              onTap: () async {
                final success = await ref.read(premiumControllerProvider.notifier).purchasePackage(pkg);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Welcome to Premium")),
                  );
                }
              },
              isPrimary: isAnnual,
            ),
          ],
        ),
      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1, end: 0),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final int delay;

  const _FeatureRow({required this.icon, required this.title, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.sageGreen, size: 20),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            title, 
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.5)
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.05, end: 0);
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionBtn({required this.label, required this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.sageGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isPrimary ? Colors.transparent : AppColors.glassBorder, width: 0.5),
          boxShadow: isPrimary ? [BoxShadow(color: AppColors.sageGreen.withValues(alpha: 0.3), blurRadius: 20)] : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isPrimary ? AppColors.bgDark : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}
