import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/screen_wrapper.dart';
import '../data/models/calm_place.dart';
import 'calm_places_controller.dart';
import 'widgets/category_filter.dart';
import 'widgets/map_place_card.dart';
import 'place_detail_sheet.dart';

class CalmPlacesMapScreen extends ConsumerStatefulWidget {
  const CalmPlacesMapScreen({super.key});

  @override
  ConsumerState<CalmPlacesMapScreen> createState() => _CalmPlacesMapScreenState();
}

class _CalmPlacesMapScreenState extends ConsumerState<CalmPlacesMapScreen> {
  final MapController _mapController = MapController();
  CalmPlace? _selectedPlace;

  @override
  void initState() {
    super.initState();
    final state = ref.read(calmPlacesProvider);
    if (state.places.isEmpty) {
      Future.microtask(() => ref.read(calmPlacesProvider.notifier).loadNearbyPlaces());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calmPlacesProvider);
    final userLoc = state.userLocation ?? const LatLng(41.0082, 28.9784); // default: Istanbul

    return ScreenWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Map layer
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: userLoc,
                initialZoom: 14,
                backgroundColor: AppColors.bgDark,
                onTap: (tapPos, latLng) => setState(() => _selectedPlace = null),
              ),
              children: [
                // Dark-themed OSM tiles
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.nuu.app',
                  maxZoom: 19,
                ),
                // Place markers
                MarkerLayer(
                  markers: [
                    // User location marker
                    if (state.userLocation != null)
                      Marker(
                        point: state.userLocation!,
                        width: 28,
                        height: 28,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: AppColors.accentGlow(blur: 16, opacity: 0.5),
                          ),
                          child: const Icon(Icons.my_location, color: Colors.white, size: 14),
                        ),
                      ),
                    // Place markers
                    ...state.filteredPlaces.map((place) => Marker(
                          point: place.location,
                          width: 36,
                          height: 42,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPlace = place),
                            child: _PlaceMarker(
                              category: place.category,
                              isSelected: _selectedPlace?.id == place.id,
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),

            // Top bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button + title
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.bgDark.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Calm Map',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        // Recenter button
                        GestureDetector(
                          onTap: () {
                            if (state.userLocation != null) {
                              _mapController.move(state.userLocation!, 14);
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.bgDark.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: const Icon(LucideIcons.locate, color: AppColors.accent, size: 20),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 12),
                    // Category filter
                    CategoryFilter(
                      selected: state.selectedCategory,
                      onSelected: (cat) =>
                          ref.read(calmPlacesProvider.notifier).filterByCategory(cat),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  ],
                ),
              ),
            ),

            // Loading
            if (state.isLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.accent)),

            // Floating place card at bottom
            if (_selectedPlace != null)
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: MapPlaceCard(
                  place: _selectedPlace!,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => PlaceDetailSheet(place: _selectedPlace!),
                    );
                  },
                  onNavigate: () async {
                    final lat = _selectedPlace!.location.latitude;
                    final lng = _selectedPlace!.location.longitude;
                    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                    try {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom map marker with category-colored pin
class _PlaceMarker extends StatelessWidget {
  final PlaceCategory category;
  final bool isSelected;

  const _PlaceMarker({required this.category, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isSelected ? 34 : 28,
          height: isSelected ? 34 : 28,
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12)]
                : [],
          ),
          child: Icon(
            _categoryIcon,
            color: Colors.white,
            size: isSelected ? 16 : 14,
          ),
        ),
        // Pin tail
        Container(
          width: 2,
          height: isSelected ? 8 : 6,
          color: color,
        ),
      ],
    );
  }

  Color get _categoryColor {
    switch (category) {
      case PlaceCategory.park:
      case PlaceCategory.forest:
      case PlaceCategory.trail:
        return const Color(0xFF4ADE80);
      case PlaceCategory.beach:
        return const Color(0xFF38BDF8);
      case PlaceCategory.cafe:
        return const Color(0xFFFBBF24);
      case PlaceCategory.library:
        return const Color(0xFFA78BFA);
      case PlaceCategory.meditation:
      case PlaceCategory.wellness:
        return const Color(0xFFF472B6);
    }
  }

  IconData get _categoryIcon {
    switch (category) {
      case PlaceCategory.park:
        return LucideIcons.trees;
      case PlaceCategory.forest:
        return LucideIcons.treeDeciduous;
      case PlaceCategory.beach:
        return LucideIcons.waves;
      case PlaceCategory.cafe:
        return LucideIcons.coffee;
      case PlaceCategory.library:
        return LucideIcons.bookOpen;
      case PlaceCategory.meditation:
        return LucideIcons.sparkles;
      case PlaceCategory.wellness:
        return LucideIcons.heart;
      case PlaceCategory.trail:
        return LucideIcons.footprints;
    }
  }
}
