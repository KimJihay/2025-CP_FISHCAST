import 'package:flutter/material.dart';
import '../../../core/services/moon_phase_service.dart';
import '../../../core/models/moon_phase_model.dart';

class MoonPhases extends StatefulWidget {
  const MoonPhases({super.key});

  @override
  State<MoonPhases> createState() => _MoonPhasesState();
}

class _MoonPhasesState extends State<MoonPhases> {
  final MoonPhaseService _moonPhaseService = MoonPhaseService();
  List<MoonPhaseData>? _phases;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPhases();
  }
  Future<void> _loadPhases() async {
    try {
      // Get next 7 major moon phases
      // Use 90 days to ensure we capture enough phase transitions
      final phases = await _moonPhaseService.getMajorMoonPhases(
        days: 90,
      );

      if (mounted) {
        setState(() {
          _phases = phases.take(7).toList(); // Only take the first 7 phases
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final titleFontSize = screenWidth < 360 ? 16.0 : 18.0;
        final padding = screenWidth < 360 ? 12.0 : 16.0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF000000), Color(0xFF41565F)],
            ),
          ),
          constraints: BoxConstraints(
            minHeight: screenHeight * 0.3,
            maxHeight: screenHeight * 0.65,
          ),
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Moon Phases",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: padding * 0.75),
                Expanded(child: _buildPhasesContent()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhasesContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      final screenWidth = MediaQuery.of(context).size.width;
      final iconSize = screenWidth < 360 ? 40.0 : 48.0;
      final fontSize = screenWidth < 360 ? 13.0 : 14.0;
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white70, size: iconSize),
            const SizedBox(height: 16),
            Text(
              'Failed to load moon phases',
              style: TextStyle(color: Colors.white, fontSize: fontSize),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loadPhases, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_phases == null || _phases!.isEmpty) {
      return const Center(
        child: Text(
          'No moon phase data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          ...List.generate(_phases!.length, (index) {
            final phase = _phases![index];
            final isToday =
                phase.date.day == DateTime.now().day &&
                phase.date.month == DateTime.now().month;

            final screenWidth = MediaQuery.of(context).size.width;
            final iconSize = screenWidth < 360 ? 36.0 : 40.0;
            final fontSize = screenWidth < 360 ? 13.0 : 14.0;
            final smallFontSize = screenWidth < 360 ? 11.0 : 12.0;
            final emojiSize = screenWidth < 360 ? 18.0 : 20.0;
            
            final widgets = <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(iconSize / 2),
                  ),
                  child: Center(
                    child: Text(
                      phase.emoji,
                      style: TextStyle(fontSize: emojiSize),
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Text(
                        phase.phaseName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                          fontSize: fontSize,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Text(
                        phase.formattedDate,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: smallFontSize,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: screenWidth * 0.12,
                  child: Text(
                    phase.illuminationPercentage,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ];

            if (index < _phases!.length - 1) {
              widgets.add(const Divider(color: Colors.white30, height: 1));
            }

            return widgets;
          }).expand((x) => x),
        ],
      ),
    );
  }
}
