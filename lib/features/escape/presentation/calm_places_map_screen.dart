import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/bottom_nav.dart';

class CalmPlacesMapScreen extends StatefulWidget {
  const CalmPlacesMapScreen({super.key});

  @override
  State<CalmPlacesMapScreen> createState() => _CalmPlacesMapScreenState();
}

class _CalmPlacesMapScreenState extends State<CalmPlacesMapScreen> {
  String selectedCategory = 'All';
  final categories = ['All', 'Parks', 'Beaches', 'Cafes'];

  final allPlaces = [
    _Place(
      name: 'City Botanical Garden',
      distance: '0.5 miles',
      tags: 'Nature, Quiet',
      category: 'Parks',
      rating: 4.8,
      image: 'https://images.unsplash.com/photo-1588392382834-a891154bca4d?w=800&q=80',
    ),
    _Place(
      name: 'Zen Coffee House',
      distance: '1.2 miles',
      tags: 'Cafe, Ambient',
      category: 'Cafes',
      rating: 4.6,
      image: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800&q=80',
    ),
    _Place(
      name: 'Riverside Walk',
      distance: '2.0 miles',
      tags: 'Nature, Open Space',
      category: 'Parks',
      rating: 4.9,
      image: 'https://images.unsplash.com/photo-1510659616238-0fb531777b72?w=800&q=80',
    ),
    _Place(
      name: 'Sunset Beach',
      distance: '3.5 miles',
      tags: 'Ocean, Relaxing',
      category: 'Beaches',
      rating: 4.7,
      image: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredPlaces = selectedCategory == 'All' 
        ? allPlaces 
        : allPlaces.where((p) => p.category == selectedCategory).toList();

    final mapPins = [
      {'pos': const Offset(60, 40), 'place': allPlaces[0]},
      {'pos': const Offset(220, 80), 'place': allPlaces[1]},
      {'pos': const Offset(100, 180), 'place': allPlaces[2]},
      {'pos': const Offset(250, 120), 'place': allPlaces[3]},
    ];

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
                        const Icon(LucideIcons.mapPin, color: AppColors.accent, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Calm Places',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Discover quiet spaces near you',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

                    const SizedBox(height: 32),

                    // Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => setState(() => selectedCategory = cat),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.accent : Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? AppColors.accent : Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.bgDark : Colors.white,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

                    const SizedBox(height: 24),

                    // Map placeholder
                    GlassCard(
                      padding: const EdgeInsets.all(0),
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(LucideIcons.map, color: Colors.white.withValues(alpha: 0.05), size: 100),
                            // User Location
                            Positioned(
                              top: 100,
                              left: 150,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                  boxShadow: AppColors.accentGlow(blur: 20),
                                ),
                                child: const Icon(Icons.my_location, color: Colors.white, size: 14),
                              )
                                  .animate(onPlay: (c) => c.repeat(reverse: true))
                                  .scaleXY(begin: 1, end: 1.2, duration: 1500.ms),
                            ),
                            // Map Pins
                            ...mapPins.map((pin) {
                              final pos = pin['pos'] as Offset;
                              final place = pin['place'] as _Place;
                              // Only show pins that match the current category filter
                              if (selectedCategory != 'All' && place.category != selectedCategory) {
                                return const SizedBox.shrink();
                              }
                              return Positioned(
                                top: pos.dy,
                                left: pos.dx,
                                child: GestureDetector(
                                  onTap: () => _showPlaceDetail(context, place),
                                  child: const Icon(LucideIcons.mapPin, color: AppColors.accent, size: 28)
                                      .animate(onPlay: (c) => c.repeat(reverse: true))
                                      .slideY(begin: 0, end: -0.2, duration: 2000.ms, delay: Duration(milliseconds: (pos.dx * 10).toInt())),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 32),

                    const Text(
                      'Nearby Discoveries',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                    const SizedBox(height: 16),

                    // Places list
                    ...filteredPlaces.asMap().entries.map((entry) {
                      final i = entry.key;
                      final place = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          onTap: () => _showPlaceDetail(context, place),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  place.image,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(place.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 14),
                                        const SizedBox(width: 4),
                                        Text('${place.rating}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 8),
                                        Text('• ${place.distance}', style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(place.tags, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  ],
                                ),
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.arrowRight, color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: Duration(milliseconds: 500 + i * 100))
                            .slideY(begin: 0.1, end: 0),
                      );
                    }),
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

  void _showPlaceDetail(BuildContext context, _Place place) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: AppColors.bgDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: SizedBox(
                   height: 280,
                   child: Stack(
                     fit: StackFit.expand,
                     children: [
                       Image.network(place.image, fit: BoxFit.cover),
                       Container(
                         decoration: BoxDecoration(
                           gradient: LinearGradient(
                             begin: Alignment.topCenter,
                             end: Alignment.bottomCenter,
                             colors: [Colors.transparent, AppColors.bgDark.withValues(alpha: 0.8), AppColors.bgDark],
                             stops: const [0.4, 0.8, 1.0],
                           ),
                         ),
                       ),
                       Positioned(
                         top: 16,
                         right: 16,
                         child: IconButton(
                           icon: Container(
                             padding: const EdgeInsets.all(8),
                             decoration: BoxDecoration(
                               color: Colors.black.withValues(alpha: 0.4),
                               shape: BoxShape.circle,
                             ),
                             child: const Icon(LucideIcons.x, color: Colors.white, size: 20),
                           ),
                           onPressed: () => Navigator.pop(context),
                         ),
                       ),
                     ],
                   ),
                ),
              ),
              // Details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.accent, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  place.rating.toString(),
                                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin, color: AppColors.textSecondary, size: 16),
                          const SizedBox(width: 8),
                          Text(place.distance, style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Ambiance', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: place.tags.split(', ').map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 13)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'This quiet sanctuary offers a perfect escape from the noisy city. Natural sounds, comfortable seating, and an atmosphere designed for deep thinking or relaxation.',
                        style: TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
                      ),
                      const SizedBox(height: 32),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: AppColors.accentGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: AppColors.accentGlow(blur: 20, opacity: 0.3),
                              ),
                              alignment: Alignment.center,
                              child: const Text('Directions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Place {
  final String name;
  final String distance;
  final String tags;
  final String category;
  final double rating;
  final String image;

  _Place({
    required this.name,
    required this.distance,
    required this.tags,
    required this.category,
    required this.rating,
    required this.image,
  });
}
