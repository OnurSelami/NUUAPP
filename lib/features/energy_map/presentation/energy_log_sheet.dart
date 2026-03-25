import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/energy_log.dart';
import 'energy_map_controller.dart';

/// Bottom sheet for quick energy logging — designed for <3 second interaction
class EnergyLogSheet extends ConsumerStatefulWidget {
  const EnergyLogSheet({super.key});

  @override
  ConsumerState<EnergyLogSheet> createState() => _EnergyLogSheetState();
}

class _EnergyLogSheetState extends ConsumerState<EnergyLogSheet> {
  double _energyLevel = 50;
  final Set<String> _selectedTags = {};
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(energyMapProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: _submitted
          ? _buildSuccess(state.miniInsight)
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    final segment = DaySegment.fromHour(DateTime.now().hour);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Row(
            children: [
              Text(segment.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How\'s your energy?',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${segment.label} check-in',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 32),

          // Energy level display
          Text(
            '${_energyLevel.round()}',
            style: TextStyle(
              color: _energyColor,
              fontSize: 56,
              fontWeight: FontWeight.w200,
              letterSpacing: -2,
              shadows: [
                Shadow(color: _energyColor.withValues(alpha: 0.4), blurRadius: 30),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 4),
          Text(
            _energyLabel,
            style: TextStyle(color: _energyColor, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5),
          ),

          const SizedBox(height: 20),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _energyColor,
              inactiveTrackColor: _energyColor.withValues(alpha: 0.15),
              thumbColor: _energyColor,
              overlayColor: _energyColor.withValues(alpha: 0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _energyLevel,
              min: 0,
              max: 100,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _energyLevel = v);
              },
            ),
          ),

          // Labels under slider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('LOW', style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1)),
                Text('HIGH', style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tags (optional)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'WHAT\'S HAPPENING?',
              style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EnergyTag.all.map((tag) {
              final isSelected = _selectedTags.contains(tag.id);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    isSelected ? _selectedTags.remove(tag.id) : _selectedTags.add(tag.id);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _energyColor.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? _energyColor : AppColors.glassBorder,
                    ),
                  ),
                  child: Text(
                    '${tag.emoji} ${tag.label}',
                    style: TextStyle(
                      color: isSelected ? _energyColor : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 28),

          // Submit button
          GestureDetector(
            onTap: _submit,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: _energyColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _energyColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'LOG ENERGY',
                style: TextStyle(
                  color: AppColors.bgDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSuccess(String? miniInsight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.checkCircle, color: _energyColor, size: 48)
              .animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          Text(
            'Energy: ${_energyLevel.round()}',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w300),
          ).animate().fadeIn(delay: 200.ms),
          if (miniInsight != null) ...[
            const SizedBox(height: 16),
            Text(
              miniInsight,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ).animate().fadeIn(delay: 400.ms),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _submit() {
    HapticFeedback.mediumImpact();
    ref.read(energyMapProvider.notifier).logEnergy(
      level: _energyLevel.round(),
      tags: _selectedTags.toList(),
    );
    setState(() => _submitted = true);

    // Auto-close after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Color get _energyColor {
    if (_energyLevel >= 70) return const Color(0xFF4ADE80); // green
    if (_energyLevel >= 40) return AppColors.sageGreen; // sage
    return const Color(0xFFFBBF24); // amber
  }

  String get _energyLabel {
    if (_energyLevel >= 80) return 'FULLY CHARGED';
    if (_energyLevel >= 60) return 'GOOD ENERGY';
    if (_energyLevel >= 40) return 'MODERATE';
    if (_energyLevel >= 20) return 'LOW';
    return 'DRAINED';
  }
}
