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
        final itemHeight = 60.0;
        final headerHeight = 70.0;
        final paddingHeight = 32.0;
        // Calculate height for 7 moon phase items
        final calculatedHeight =
            (itemHeight * 7) + headerHeight + paddingHeight;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF000000), Color(0xFF41565F)],
            ),
          ),
          constraints: BoxConstraints(
            minHeight: calculatedHeight.clamp(300, 500),
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Moon Phases",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Failed to load moon phases',
              style: TextStyle(color: Colors.white),
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

            final widgets = <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      phase.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      phase.phaseName,
                      style: TextStyle(
                        color: isToday ? Colors.white : Colors.white,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    Text(
                      phase.formattedDate,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  phase.illuminationPercentage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
