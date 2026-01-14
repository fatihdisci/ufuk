import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ufuk/app/atmosphere/segment.dart';
import 'package:ufuk/data/repository/content_repository.dart';
import 'package:ufuk/data/services/location_preferences.dart';
import 'package:ufuk/features/home/home_controller.dart';
import 'package:ufuk/features/settings/location_picker_sheet.dart';
import 'widgets/atmosphere_bg.dart';
import 'widgets/hero_countdown.dart';
import 'widgets/glass_carousel.dart';
import 'widgets/prayer_timeline_card.dart';
import 'widgets/glass_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 0: Ambient Background
          ValueListenableBuilder<TimeSegment>(
            valueListenable: _controller.segmentNotifier,
            builder: (_, segment, __) {
              return AtmosphereBackground(segment: segment);
            },
          ),
          
          // Layer 0.5: Audio Control (Top Right)
          Positioned(
            top: 0, 
            right: 0, 
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Standard padding
                child: const GlassPlayer(),
              ),
            ),
          ),

          // Layer 1: Content
          SafeArea(
            child: Column(
              children: [
                // Header (Compact)
                _buildHeader(),
                
                const SizedBox(height: 16),

                // Hero Section (Primary Focus)
                Expanded(
                  flex: 3,
                  child: Center(
                    child: _buildHeroSection(),
                  ),
                ),
                
                // Prayer Timeline Card
                ValueListenableBuilder<List<PrayerTimeDisplay>>(
                  valueListenable: _controller.timesNotifier,
                  builder: (_, times, __) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: _controller.currentPrayerNotifier,
                      builder: (_, currentPrayer, __) {
                        return PrayerTimelineCard(
                          times: times,
                          currentPrayerName: currentPrayer,
                        );
                      },
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Content Carousel
                SizedBox(
                  height: 180,
                  child: _buildCarousel(),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ValueListenableBuilder<HomeStatus>(
            valueListenable: _controller.statusNotifier,
            builder: (_, status, __) {
              if (status == HomeStatus.offline) {
                return const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.cloud_off, color: Colors.white54, size: 14),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Tappable Location
          ValueListenableBuilder<SelectedLocation?>(
            valueListenable: _controller.locationNotifier,
            builder: (_, location, __) {
              return GestureDetector(
                onTap: () => _openLocationPicker(location),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.white60, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      location?.displayName ?? 'Konum Seç',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 16),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openLocationPicker(SelectedLocation? currentLocation) {
    if (currentLocation == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationPickerSheet(
        preferences: _controller.locationPrefs,
        currentLocation: currentLocation,
        onLocationSelected: (newLocation) {
          _controller.onLocationChanged(newLocation);
        },
      ),
    );
  }

  Widget _buildHeroSection() {
    return ValueListenableBuilder<HeroViewModel>(
      valueListenable: _controller.heroNotifier,
      builder: (_, viewModel, __) {
        return ValueListenableBuilder<String?>(
          valueListenable: _controller.themeNotifier,
          builder: (_, theme, __) {
            return ValueListenableBuilder<bool>(
              valueListenable: _controller.isRamadanNotifier,
              builder: (_, isRamadan, __) {
                return ValueListenableBuilder<String?>(
                  valueListenable: _controller.contextSentenceNotifier,
                  builder: (_, contextSentence, __) {
                    return HeroCountdown(
                      viewModel: viewModel,
                      theme: theme,
                      isRamadan: isRamadan,
                      contextSentence: contextSentence,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCarousel() {
    return ValueListenableBuilder<Map<String, DailyContent>>(
      valueListenable: _controller.contentNotifier,
      builder: (_, content, __) {
        return ValueListenableBuilder<NativeAd?>(
          valueListenable: _controller.nativeAdNotifier,
          builder: (_, nativeAd, __) {
            return ValueListenableBuilder<String?>(
              valueListenable: _controller.aiSummaryNotifier,
              builder: (_, aiSummary, __) {
                return GlassCarousel(
                  times: const [], // No longer showing times in carousel
                  content: content,
                  onShare: (item) => _controller.share(context, item),
                  onAiShare: (text) => _controller.shareAiContent(context, text),
                  nativeAd: nativeAd,
                  aiSummary: aiSummary,
                );
              },
            );
          },
        );
      },
    );
  }
}
