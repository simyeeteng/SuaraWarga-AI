import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/app_state.dart';
import '../../../../core/services/transit_service.dart';
import '../../../../shared/widgets/custom_header.dart';

class PublicTransportPage extends StatefulWidget {
  /// Optional live itinerary passed in from TropicalRoutePage.
  /// Falls back to the built-in BJ2 demo itinerary when null.
  final BusItinerary? itinerary;

  const PublicTransportPage({super.key, this.itinerary});

  @override
  State<PublicTransportPage> createState() => _PublicTransportPageState();
}

class _PublicTransportPageState extends State<PublicTransportPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Simulated "current stop index" — 0 = at boarding stop, increments as bus moves.
  int _currentStopIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  BusItinerary get _itinerary =>
      widget.itinerary ?? TransitService.defaultJBItinerary;

  /// Builds a synthetic stop list from the itinerary steps + stopsLeft.
  List<_BusStop> _buildStopList() {
    final it = _itinerary;
    final List<_BusStop> stops = [];

    // Boarding stop (walk-to stop)
    stops.add(_BusStop(
      name: it.stopName,
      code: it.stopCode,
      isBoardingStop: true,
      isAlightingStop: false,
      minutesFromStart: 0,
      note: 'START  ·  Board here — Bus arrives in ${it.arrivalMinutes} min',
    ));

    // Intermediate stops inferred from stopsLeft
    final int midStops = it.stopsLeft - 1;
    final busStep =
        it.steps.where((s) => !s.isWalk).firstOrNull;
    final rideMinutes = busStep?.duration.inMinutes ?? 15;
    final minutePerStop =
        midStops > 0 ? rideMinutes ~/ (midStops + 1) : rideMinutes;

    for (int i = 0; i < midStops; i++) {
      stops.add(_BusStop(
        name: 'Stop ${i + 1}',
        code: '—',
        isBoardingStop: false,
        isAlightingStop: false,
        minutesFromStart: minutePerStop * (i + 1),
        note: null,
      ));
    }

    // Extract destination from routeName (after the →)
    final parts = it.routeName.split('→');
    final destName = parts.length > 1 ? parts.last.trim() : 'Destination';

    // Alighting stop
    stops.add(_BusStop(
      name: destName,
      code: 'DEST',
      isBoardingStop: false,
      isAlightingStop: true,
      minutesFromStart: rideMinutes,
      note: 'Alight here',
    ));

    return stops;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final it = _itinerary;
    final stops = _buildStopList();
    final stopsRemaining = stops.length - 1 - _currentStopIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          CustomHeader(
            title: appState.translate('publicTransportTitle'),
            subtitle: appState.translate('voiceGuidedNav'),
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // ── Hero bus card ──────────────────────────────────────────
                _buildHeroBusCard(it, stopsRemaining, appState),
                const SizedBox(height: 20),

                // ── Fare + stop info row ───────────────────────────────────
                _buildInfoRow(it, stopsRemaining, appState),
                const SizedBox(height: 20),

                // ── Stop-by-stop timeline ──────────────────────────────────
                _buildStopTimeline(stops, appState),
                const SizedBox(height: 20),

                // ── Schedule strip ─────────────────────────────────────────
                _buildScheduleStrip(it, appState),
                const SizedBox(height: 20),

                // ── Steps list ─────────────────────────────────────────────
                _buildStepsList(it, appState),
                const SizedBox(height: 24),

                // ── Simulation controls ────────────────────────────────────
                if (_currentStopIndex < stops.length - 1)
                  _buildNextStopButton(stops),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBusCard(
      BusItinerary it, int stopsRemaining, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  it.busLine,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bus ${it.busLine}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      it.routeName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Arriving badge
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${it.arrivalMinutes} min',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const Text(
                        'arriving',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          // ── Start bus stop banner ─────────────────────────────────────
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'START',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${it.stopName}  ·  ${it.stopCode}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.location_on_rounded,
                  color: Colors.white, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeroStat(
                  Icons.tour_rounded, '$stopsRemaining stops left'),
              _buildHeroStat(Icons.toll_rounded, it.fare),
              _buildHeroStat(Icons.schedule_rounded,
                  '${it.totalDuration.inMinutes} min total'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      BusItinerary it, int stopsRemaining, AppState appState) {
    return Row(
      children: [
        _buildInfoTile(
          Icons.location_on_rounded,
          'Bus Stop',
          it.stopName,
          const Color(0xFF2563EB),
        ),
        const SizedBox(width: 10),
        _buildInfoTile(
          Icons.timeline_rounded,
          'Stops Left',
          '$stopsRemaining stops',
          const Color(0xFF7C3AED),
        ),
        const SizedBox(width: 10),
        _buildInfoTile(
          Icons.toll_rounded,
          'Fare',
          it.fare,
          const Color(0xFF059669),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
      IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: color.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopTimeline(List<_BusStop> stops, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.alt_route_rounded,
                    color: Color(0xFF2563EB), size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Stop-by-Stop Guide',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...stops.asMap().entries.map((entry) {
            final idx = entry.key;
            final stop = entry.value;
            final isActive = idx == _currentStopIndex;
            final isPast = idx < _currentStopIndex;
            final isLast = idx == stops.length - 1;

            return _buildStopRow(
                stop, isActive, isPast, isLast, idx, stops.length);
          }),
        ],
      ),
    );
  }

  Widget _buildStopRow(
    _BusStop stop,
    bool isActive,
    bool isPast,
    bool isLast,
    int idx,
    int total,
  ) {
    final Color dotColor = stop.isAlightingStop
        ? const Color(0xFF10B981)
        : stop.isBoardingStop
            ? const Color(0xFF2563EB)
            : isPast
                ? const Color(0xFF94A3B8)
                : isActive
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFCBD5E1);

    final Color lineColor =
        isPast ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: dot + line
        SizedBox(
          width: 24,
          child: Column(
            children: [
              // Dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 22 : 16,
                height: isActive ? 22 : 16,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                          width: 4,
                        )
                      : null,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: dotColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: stop.isAlightingStop
                    ? const Icon(Icons.flag_rounded,
                        color: Colors.white, size: 10)
                    : stop.isBoardingStop
                        ? const Icon(Icons.directions_bus_rounded,
                            color: Colors.white, size: 10)
                        : isPast
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 10)
                            : null,
              ),
              // Vertical line
              if (!isLast)
                Container(
                  width: 2,
                  height: 48,
                  margin: const EdgeInsets.only(top: 4, bottom: 0),
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        // Right side: stop info
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 32, top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stop.name,
                        style: TextStyle(
                          fontSize: isActive ? 15 : 13,
                          fontWeight: isActive || stop.isBoardingStop || stop.isAlightingStop
                              ? FontWeight.w900
                              : FontWeight.w600,
                          color: isPast
                              ? const Color(0xFF94A3B8)
                              : isActive
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    if (stop.minutesFromStart > 0)
                      Text(
                        '+${stop.minutesFromStart} min',
                        style: TextStyle(
                          fontSize: 11,
                          color: isPast
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                if (stop.code != '—')
                  Text(
                    stop.code,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (stop.note != null) ...[
                  const SizedBox(height: 3),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: stop.isBoardingStop
                          ? const Color(0xFFEFF6FF)
                          : stop.isAlightingStop
                              ? const Color(0xFFF0FDF4)
                              : const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      stop.note!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: stop.isBoardingStop
                            ? const Color(0xFF1D4ED8)
                            : stop.isAlightingStop
                                ? const Color(0xFF065F46)
                                : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleStrip(BusItinerary it, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  color: Color(0xFF7C3AED), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Today\'s Schedule',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: it.schedule.map((time) {
              final now = DateTime.now();
              final parts = time.split(':');
              final schedTime = DateTime(
                now.year,
                now.month,
                now.day,
                int.parse(parts[0]),
                int.parse(parts[1]),
              );
              final isPast = schedTime.isBefore(now);
              final isNext = !isPast && it.schedule
                      .map((t) {
                        final tp = t.split(':');
                        return DateTime(now.year, now.month, now.day,
                            int.parse(tp[0]), int.parse(tp[1]));
                      })
                      .where((d) => d.isAfter(now))
                      .toList()
                      .firstOrNull ==
                  schedTime;

              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isNext
                      ? const Color(0xFF2563EB)
                      : isPast
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: isNext
                      ? null
                      : Border.all(
                          color: isPast
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFFBFDBFE),
                        ),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isNext
                        ? Colors.white
                        : isPast
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF1D4ED8),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList(BusItinerary it, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_rounded,
                  color: Color(0xFF059669), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Journey Steps',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...it.steps.asMap().entries.map((e) {
            final step = e.value;
            final isWalk = step.isWalk;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isWalk
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isWalk
                          ? Icons.directions_walk_rounded
                          : Icons.directions_bus_rounded,
                      size: 18,
                      color: isWalk
                          ? const Color(0xFF059669)
                          : const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.instruction,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${step.duration.inMinutes} min · ${step.distance.round()}m',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNextStopButton(List<_BusStop> stops) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            if (_currentStopIndex < stops.length - 1) {
              _currentStopIndex++;
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
        label: Text(
          'Next Stop: ${stops[_currentStopIndex + 1].name}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
      ),
    );
  }
}

class _BusStop {
  final String name;
  final String code;
  final bool isBoardingStop;
  final bool isAlightingStop;
  final int minutesFromStart;
  final String? note;

  const _BusStop({
    required this.name,
    required this.code,
    required this.isBoardingStop,
    required this.isAlightingStop,
    required this.minutesFromStart,
    this.note,
  });
}
