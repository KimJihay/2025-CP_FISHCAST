import 'package:fishcast/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../services/moon_phase_service.dart';
import '../../models/moon_phase_model.dart';
import '../../models/location_model.dart';

class MoonPhasesCard extends StatefulWidget {
  final LocationData location;
  
  const MoonPhasesCard({super.key, required this.location});

  @override
  State<MoonPhasesCard> createState() => _MoonPhasesCardState();
}

class _MoonPhasesCardState extends State<MoonPhasesCard> {
  final MoonPhaseService _moonPhaseService = MoonPhaseService();
  MoonPhaseData? _currentPhase;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoonPhase();
  }

  Future<void> _loadMoonPhase() async {
    try {
      // Get current moon phase with timeout
      final phase = await _moonPhaseService.getCurrentMoonPhase()
          .timeout(const Duration(seconds: 5));
      
      if (mounted) {
        setState(() {
          _currentPhase = phase;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('MMM dd, EEEE').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF000000), Color(0xFF41565F)],
        ),
      ),
      height: 169.34405517578125, // Exact height as requested
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : Row(
                  children: [
                    const SizedBox(width: 19),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.location.displayName,
                          style: const TextStyle(
                            color: kBackgroundColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Urbanist',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getFormattedDate(),
                          style: const TextStyle(
                            color: kBackgroundColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                        const SizedBox(height: 35),
                        Text(
                          _currentPhase?.phaseName ?? "Loading...",
                          style: const TextStyle(
                            color: kBackgroundColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Urbanist',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 156,
                      height: 135.34405517578125,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow effect
                                Container(
                                  width: 112.66881561279297,
                                  height: 106.09648895263672,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFDCDCDC)
                                            .withValues(alpha: 0.43),
                                        spreadRadius: 0.8,
                                        blurRadius: 20,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                                // Moon emoji (fallback if SVG not available)
                                if (_currentPhase != null)
                                  Text(
                                    _currentPhase!.emoji,
                                    style: const TextStyle(fontSize: 100),
                                  )
                                else
                                  SvgPicture.asset(
                                    "assets/moon_phases_card/moon.svg",
                                    width: 152,
                                    height: 154.42,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
