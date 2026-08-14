import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';
import '../../../../shared/widgets/custom_header.dart';
import '../../../../shared/widgets/ai_tag.dart';
import '../widgets/image_upload.dart';
import '../widgets/detection_result.dart';

class WalkabilityPage extends StatefulWidget {
  const WalkabilityPage({super.key});

  @override
  State<WalkabilityPage> createState() => _WalkabilityPageState();
}

class _WalkabilityPageState extends State<WalkabilityPage> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final bool uploaded = appState.walkwayPhotoUploaded;

    final detections = [
      {
        'icon': Icons.park_rounded,
        'labelKey': 'detTrees',
        'count': 8,
        'color': const Color(0xFF10B981),
        'percent': 0.72
      },
      {
        'icon': Icons.umbrella_rounded,
        'labelKey': 'detCoveredWalkway',
        'count': 1,
        'color': const Color(0xFF2563EB),
        'percent': 0.45
      },
      {
        'icon': Icons.directions_bus_rounded,
        'labelKey': 'detBusShelter',
        'count': 1,
        'color': const Color(0xFFD97706),
        'percent': 1.00
      },
      {
        'icon': Icons.directions_walk_rounded,
        'labelKey': 'detSidewalk',
        'count': 1,
        'color': const Color(0xFF8B5CF6),
        'percent': 0.88
      },
    ];

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: appState.translate('qlWalkability'),
            subtitle: appState.translate('aiCvMapping'),
            onBack: () {
              appState.setWalkwayPhotoUploaded(false);
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32),
              children: [
                // Tech Tags
                const Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    AITag(label: 'Computer Vision'),
                    AITag(label: 'AI Detection'),
                    AITag(label: 'Community AI'),
                  ],
                ),
                const SizedBox(height: 16),
                // Upload or Scanned Image area
                if (!uploaded)
                  ImageUpload(onTap: () => appState.setWalkwayPhotoUploaded(true))
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: appState.highContrast ? Border.all(color: Colors.black, width: 2.0) : null,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Walkway image preview background
                        Image.network(
                          'https://images.unsplash.com/photo-1519003722824-194d4455a60c?w=600&h=300&fit=crop&auto=format',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                        ),
                        // Overlay Badges
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _buildOverlayBadge(Icons.park_rounded, appState.translate('det8Trees'), const Color(0xFF10B981)),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _buildOverlayBadge(Icons.umbrella_rounded, appState.translate('detCoveredOverlay'), const Color(0xFF2563EB)),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: _buildOverlayBadge(Icons.directions_bus_rounded, appState.translate('detBusShelterOverlay'), const Color(0xFFD97706)),
                        ),
                        // Laser scan overlay lines
                        const _LaserScanOverlay(),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                // AI detection results
                if (uploaded) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFEFF6FF), width: 1.5),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.translate('aiDetections'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 12),
                        ...detections.map((d) {
                          return DetectionResult(
                            icon: d['icon'] as IconData,
                            labelKey: d['labelKey'] as String,
                            count: d['count'] as int,
                            color: d['color'] as Color,
                            confidencePercent: d['percent'] as double,
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Community contributions
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF047857)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.translate('communityContributions'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildContributionStat('1,247', appState.translate('photosLabel')),
                          _buildContributionStat('89', appState.translate('routesMappedLabel')),
                          _buildContributionStat('342', appState.translate('contributorsLabel')),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Bottom Submit trigger
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload_rounded, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          uploaded ? appState.translate('submitToCommunity') : appState.translate('takeWalkwayPhoto'),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOverlayBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _LaserScanOverlay extends StatefulWidget {
  const _LaserScanOverlay();

  @override
  State<_LaserScanOverlay> createState() => _LaserScanOverlayState();
}

class _LaserScanOverlayState extends State<_LaserScanOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double topPosition = 200 * _controller.value;
        return Positioned(
          top: topPosition,
          left: 0,
          right: 0,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFF34D399), // emerald-400
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF34D399).withOpacity(0.8),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
