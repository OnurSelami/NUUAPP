import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';

class LetItBurnWidget extends StatefulWidget {
  const LetItBurnWidget({super.key});

  @override
  State<LetItBurnWidget> createState() => _LetItBurnWidgetState();
}

class _LetItBurnWidgetState extends State<LetItBurnWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isBurning = false;
  bool _isBurned = false;

  void _burnThought() {
    if (_controller.text.trim().isEmpty) return;
    
    // Dismiss keyboard
    _focusNode.unfocus();
    HapticFeedback.mediumImpact();

    setState(() {
      _isBurning = true;
    });

    // The animation takes ~1.8 seconds, after that we show success state
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isBurned = true;
          _isBurning = false;
          _controller.clear();
        });
        HapticFeedback.lightImpact();
      }
    });
  }

  void _reset() {
    setState(() {
      _isBurned = false;
      _isBurning = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isBurned) {
      return GestureDetector(
        onTap: _reset,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.flame, color: AppColors.accentOrange, size: 20),
              const SizedBox(width: 12),
              const Text(
                'Let go successfully',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ).animate()
         .fadeIn(duration: 600.ms)
         .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 600.ms, curve: Curves.easeOutBack),
      );
    }

    Widget inputArea = Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'What are you holding onto? Let it go...',
              hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            onSubmitted: (_) => _burnThought(),
            textInputAction: TextInputAction.send,
            enabled: !_isBurning,
          ),
        ),
        if (!_isBurning)
          IconButton(
            icon: const Icon(LucideIcons.flame, color: AppColors.accentOrange, size: 20),
            onPressed: _burnThought,
          )
        else
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(color: AppColors.accentOrange, strokeWidth: 2),
            ),
          ),
      ],
    );

    // If burning is active, apply destructive animation effects
    if (_isBurning) {
      inputArea = inputArea
          .animate()
          .shake(hz: 8, offset: const Offset(4, 0), duration: 1800.ms)
          .blur(begin: const Offset(0, 0), end: const Offset(10, 10), duration: 1800.ms)
          .fadeOut(duration: 1800.ms, curve: Curves.easeInQuad);
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: inputArea,
      ),
    );
  }
}
