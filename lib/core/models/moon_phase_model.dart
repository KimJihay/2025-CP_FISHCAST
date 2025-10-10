import 'package:intl/intl.dart';

enum MoonPhaseType {
  newMoon,        // 0%
  waxingCrescent, // 1-49%
  firstQuarter,   // 50%
  waxingGibbous,  // 51-99%
  fullMoon,       // 100%
  waningGibbous,  // 99-51%
  lastQuarter,    // 50%
  waningCrescent, // 49-1%
}

class MoonPhaseData {
  final DateTime date;
  final double illumination; // 0.0 to 1.0 (0% to 100%)
  final MoonPhaseType phaseType;
  final double age; // Days since new moon (0-29.53)

  MoonPhaseData({
    required this.date,
    required this.illumination,
    required this.phaseType,
    required this.age,
  });

  /// Get illumination as percentage string
  String get illuminationPercentage => '${(illumination * 100).round()}%';

  /// Get phase name
  String get phaseName {
    switch (phaseType) {
      case MoonPhaseType.newMoon:
        return 'New Moon';
      case MoonPhaseType.waxingCrescent:
        return 'Waxing Crescent';
      case MoonPhaseType.firstQuarter:
        return 'First Quarter';
      case MoonPhaseType.waxingGibbous:
        return 'Waxing Gibbous';
      case MoonPhaseType.fullMoon:
        return 'Full Moon';
      case MoonPhaseType.waningGibbous:
        return 'Waning Gibbous';
      case MoonPhaseType.lastQuarter:
        return 'Last Quarter';
      case MoonPhaseType.waningCrescent:
        return 'Waning Crescent';
    }
  }

  /// Get moon emoji based on phase
  String get emoji {
    switch (phaseType) {
      case MoonPhaseType.newMoon:
        return '🌑';
      case MoonPhaseType.waxingCrescent:
        return '🌒';
      case MoonPhaseType.firstQuarter:
        return '🌓';
      case MoonPhaseType.waxingGibbous:
        return '🌔';
      case MoonPhaseType.fullMoon:
        return '🌕';
      case MoonPhaseType.waningGibbous:
        return '🌖';
      case MoonPhaseType.lastQuarter:
        return '🌗';
      case MoonPhaseType.waningCrescent:
        return '🌘';
    }
  }

  /// Get formatted date string
  String get formattedDate => DateFormat('MMM dd').format(date);

  /// Get day of week
  String get dayOfWeek => DateFormat('EEEE').format(date);
}

class MoonCalendarData {
  final List<MoonPhaseData> phases;
  final DateTime startDate;
  final DateTime endDate;

  MoonCalendarData({
    required this.phases,
    required this.startDate,
    required this.endDate,
  });

  /// Get next major phase (new, first quarter, full, last quarter)
  MoonPhaseData? get nextMajorPhase {
    final now = DateTime.now();
    return phases.firstWhere(
      (phase) =>
          phase.date.isAfter(now) &&
          (phase.phaseType == MoonPhaseType.newMoon ||
              phase.phaseType == MoonPhaseType.firstQuarter ||
              phase.phaseType == MoonPhaseType.fullMoon ||
              phase.phaseType == MoonPhaseType.lastQuarter),
      orElse: () => phases.first,
    );
  }
}
