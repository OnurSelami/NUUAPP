import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../data/models/calm_place.dart';
import 'widgets/calm_score_badge.dart';
import 'calm_places_controller.dart';

/// Full place detail as a bottom sheet
class PlaceDetailSheet extends ConsumerStatefulWidget {
  final CalmPlace place;

  const PlaceDetailSheet({super.key, required this.place});

  @override
  ConsumerState<PlaceDetailSheet> createState() => _PlaceDetailSheetState();
}

class _PlaceDetailSheetState extends ConsumerState<PlaceDetailSheet> {
  bool _showStoryForm = false;
  final _storyController = TextEditingController();
  String _selectedTag = 'reset';

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score + Name header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CalmScoreBadge(score: place.calmScore, size: 64),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(place.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Row(children: [
                              _tag(place.category.label, AppColors.accent),
                              const SizedBox(width: 8),
                              _tag(place.isOpenNow ? 'Open now' : 'Closed', place.isOpenNow ? const Color(0xFF4ADE80) : const Color(0xFFF87171)),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Distance
                  _infoRow(LucideIcons.mapPin, '${place.distanceDisplay} — ${place.walkingTime}'),
                  if (place.address != null)
                    _infoRow(LucideIcons.navigation, place.address!),
                  const SizedBox(height: 20),

                  // Calm reasons
                  if (place.calmReasons.isNotEmpty) ...[
                    const Text('Why it\'s calming', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: place.calmReasons.map((r) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.sageGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.sageGreen.withValues(alpha: 0.2)),
                        ),
                        child: Text(r.text, style: const TextStyle(color: AppColors.sageGreen, fontSize: 13, fontWeight: FontWeight.w500)),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── CALM TIMELINE ──────────────────────────
                  if (place.timeline != null) ...[
                    Row(
                      children: [
                        const Icon(LucideIcons.clock, color: AppColors.sageGreen, size: 16),
                        const SizedBox(width: 8),
                        const Text('Calm Timeline', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '✨ Best time: ${CalmTimeline.hourLabel(place.timeline!.bestHour)} — ${place.timeline!.bestReason}',
                      style: TextStyle(color: AppColors.sageGreen.withValues(alpha: 0.9), fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 14),
                    _buildTimeline(place.timeline!),
                    const SizedBox(height: 24),
                  ],

                  // ── MICRO STORIES ──────────────────────────
                  Row(
                    children: [
                      const Icon(LucideIcons.messageCircle, color: AppColors.sageGreen, size: 16),
                      const SizedBox(width: 8),
                      const Text('Stories', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _showStoryForm = !_showStoryForm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.sageGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.sageGreen.withValues(alpha: 0.2)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(_showStoryForm ? LucideIcons.x : LucideIcons.plus, color: AppColors.sageGreen, size: 12),
                            const SizedBox(width: 4),
                            Text(_showStoryForm ? 'Cancel' : 'Add yours', style: const TextStyle(color: AppColors.sageGreen, fontSize: 11, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_showStoryForm) _buildStoryForm(place),

                  if (place.stories.isNotEmpty)
                    ...place.stories.take(3).map((story) => _buildStoryCard(story))
                  else if (!_showStoryForm)
                    Text(
                      'No stories yet. Be the first to share how this place made you feel.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontStyle: FontStyle.italic),
                    ),

                  const SizedBox(height: 24),

                  // Score breakdown
                  _buildScoreBreakdown(),
                  const SizedBox(height: 28),

                  // Action buttons
                  _buildActions(context, ref),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TIMELINE ──────────────────────────────────────────

  Widget _buildTimeline(CalmTimeline timeline) {
    final keyHours = timeline.keyHours;
    final currentHour = DateTime.now().hour;

    return Row(
      children: keyHours.map((entry) {
        final hour = entry.key;
        final score = entry.value;
        final isNow = (currentHour - hour).abs() <= 1;
        final barHeight = (score / 100 * 80).clamp(16.0, 80.0);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    color: isNow ? AppColors.sageGreen : AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: isNow ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isNow
                        ? AppColors.sageGreen.withValues(alpha: 0.6)
                        : AppColors.sageGreen.withValues(alpha: 0.15),
                    border: isNow ? Border.all(color: AppColors.sageGreen, width: 1) : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(CalmTimeline.hourEmoji(hour), style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  CalmTimeline.hourLabel(hour),
                  style: TextStyle(
                    color: isNow ? AppColors.textPrimary : AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: isNow ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 200 + keyHours.indexOf(entry) * 100)),
        );
      }).toList(),
    );
  }

  // ─── STORY FORM ────────────────────────────────────────

  Widget _buildStoryForm(CalmPlace place) {
    const tags = ['reset', 'flow', 'reflect', 'connect', 'silence'];
    const tagEmojis = {'reset': '🍃', 'flow': '🌊', 'reflect': '💭', 'connect': '🤝', 'silence': '🎧'};

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _storyController,
            maxLength: 140,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'What did you feel here?',
              hintStyle: TextStyle(color: AppColors.textMuted),
              border: InputBorder.none,
              counterStyle: TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ),
          const SizedBox(height: 8),
          // Tag picker
          Wrap(
            spacing: 8,
            children: tags.map((tag) {
              final isSelected = _selectedTag == tag;
              return GestureDetector(
                onTap: () => setState(() => _selectedTag = tag),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.sageGreen.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.sageGreen : AppColors.glassBorder,
                    ),
                  ),
                  child: Text(
                    '${tagEmojis[tag]} #$tag',
                    style: TextStyle(
                      color: isSelected ? AppColors.sageGreen : AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Submit
          GestureDetector(
            onTap: () {
              if (_storyController.text.trim().isEmpty) return;
              ref.read(calmPlacesProvider.notifier).addStory(
                placeId: place.id,
                text: _storyController.text.trim(),
                tag: _selectedTag,
              );
              _storyController.clear();
              setState(() => _showStoryForm = false);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.sageGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text('SHARE STORY', style: TextStyle(color: AppColors.bgDark, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  // ─── STORY CARD ────────────────────────────────────────

  Widget _buildStoryCard(CalmStory story) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('"${story.text}"', style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontStyle: FontStyle.italic, height: 1.5)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(story.tagDisplay, style: const TextStyle(fontSize: 11)),
              const Spacer(),
              Text(
                '${story.author} • ${CalmTimeline.hourLabel(story.timestamp.hour)}',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              if (story.calmScoreAtTime > 0) ...[
                const SizedBox(width: 8),
                Text('Score: ${story.calmScoreAtTime}', style: TextStyle(color: AppColors.sageGreen.withValues(alpha: 0.7), fontSize: 11)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── EXISTING WIDGETS ──────────────────────────────────

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: AppColors.textSecondary, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown() {
    final place = widget.place;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Calm Score Breakdown', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _scoreBar('Category', _categoryPct(place), const Color(0xFF4ADE80)),
              _scoreBar('Distance', _distancePct(place), AppColors.accent),
              _scoreBar('Weather', 0.7, const Color(0xFFFBBF24)),
              _scoreBar('Time of Day', _timePct, const Color(0xFFA78BFA)),
            ],
          ),
        ),
      ),
    );
  }

  double _categoryPct(CalmPlace place) {
    if (place.category == PlaceCategory.forest || place.category == PlaceCategory.beach) return 0.95;
    if (place.category == PlaceCategory.park || place.category == PlaceCategory.trail) return 0.9;
    if (place.category == PlaceCategory.meditation) return 0.95;
    if (place.category == PlaceCategory.library) return 0.88;
    return 0.7;
  }

  double _distancePct(CalmPlace place) {
    if (place.distanceMeters < 500) return 1.0;
    if (place.distanceMeters < 1000) return 0.85;
    if (place.distanceMeters < 2000) return 0.7;
    if (place.distanceMeters < 3000) return 0.5;
    return 0.3;
  }

  double get _timePct {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour <= 9) return 1.0;
    if (hour >= 17 && hour <= 19) return 0.95;
    if (hour >= 10 && hour <= 16) return 0.7;
    return 0.3;
  }

  Widget _scoreBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const Spacer(),
            Text('${(value * 100).round()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value, minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(calmPlacesProvider).savedPlaceIds.contains(widget.place.id);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (isSaved) {
                ref.read(calmPlacesProvider.notifier).removeSavedPlace(widget.place.id);
              } else {
                ref.read(calmPlacesProvider.notifier).savePlace(widget.place.id);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSaved ? AppColors.sageGreen.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSaved ? AppColors.sageGreen : Colors.white.withValues(alpha: 0.1)),
              ),
              alignment: Alignment.center,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(LucideIcons.bookmark, color: isSaved ? AppColors.sageGreen : Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(isSaved ? 'Saved' : 'Save', style: TextStyle(color: isSaved ? AppColors.sageGreen : Colors.white, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => _openNavigation(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.sageGreen,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.sageGreen.withValues(alpha: 0.3), blurRadius: 20)],
              ),
              alignment: Alignment.center,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(LucideIcons.navigation, color: AppColors.bgDark, size: 18),
                SizedBox(width: 8),
                Text('Navigate', style: TextStyle(color: AppColors.bgDark, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openNavigation() async {
    final lat = widget.place.location.latitude;
    final lng = widget.place.location.longitude;
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      debugPrint('Could not launch navigation');
    }
  }
}
