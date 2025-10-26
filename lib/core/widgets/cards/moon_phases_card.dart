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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final cardHeight = screenWidth * 0.45; // Responsive height
        final iconSize = screenWidth * 0.35; // Responsive icon area
        final moonSize = screenWidth * 0.25; // Responsive moon size
        final fontSize = screenWidth < 360 ? 10.0 : 12.0;
        final phaseNameSize = screenWidth < 360 ? 20.0 : 24.0;
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF000000), Color(0xFF41565F)],
            ),
          ),
          height: cardHeight.clamp(140.0, 200.0),
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: 8,
            ),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : Row(
                    children: [
                      // Moon phase info section
                      Flexible(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                widget.location.displayName,
                                style: TextStyle(
                                  color: kBackgroundColor,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Urbanist',
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _getFormattedDate(),
                                style: TextStyle(
                                  color: kBackgroundColor,
                                  fontSize: fontSize - 2,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Urbanist',
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(height: screenWidth * 0.05),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _currentPhase?.phaseName ?? "Loading...",
                                  style: TextStyle(
                                    color: kBackgroundColor,
                                    fontSize: phaseNameSize,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Urbanist',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Moon icon section
                      Flexible(
                        flex: 2,
                        child: SizedBox(
                          width: iconSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow effect
                              Container(
                                width: moonSize * 1.3,
                                height: moonSize * 1.2,
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
                              // Moon emoji or SVG
                              if (_currentPhase != null)
                                Text(
                                  _currentPhase!.emoji,
                                  style: TextStyle(fontSize: moonSize * 0.9),
                                )
                              else
                                SvgPicture.asset(
                                  "assets/moon_phases_card/moon.svg",
                                  width: moonSize,
                                  height: moonSize,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
