import 'dart:math';
import '../models/moon_phase_model.dart';
import 'cache_service.dart';

class MoonPhaseService {
  static final MoonPhaseService _instance = MoonPhaseService._internal();
  factory MoonPhaseService() => _instance;
  MoonPhaseService._internal();

  // Lunar cycle constants
  static const double _lunarCycle = 29.53058867; // days
  static final DateTime _knownNewMoon = DateTime(2000, 1, 6, 18, 14); // Known new moon
  final _cacheService = CacheService();

  /// Get current moon phase (with caching)
  Future<MoonPhaseData> getCurrentMoonPhase({bool forceRefresh = false}) async {
    // Check cache first unless force refresh
    if (!forceRefresh) {
      final cached = await _cacheService.getCache(
        CacheService.moonPhaseKey,
        CacheService.moonPhaseCacheDuration,
      );

      if (cached != null) {
        return MoonPhaseData(
          date: DateTime.parse(cached['date']),
          illumination: cached['illumination'].toDouble(),
          phaseType: MoonPhaseType.values[cached['phaseType']],
          age: cached['age'].toDouble(),
        );
      }
    }

    final now = DateTime.now();
    final phase = getMoonPhaseForDate(now);

    // Cache the phase
    await _cacheService.saveCache(CacheService.moonPhaseKey, {
      'date': phase.date.toIso8601String(),
      'illumination': phase.illumination,
      'phaseType': phase.phaseType.index,
      'age': phase.age,
    });

    return phase;
  }

  /// Get moon phase for specific date using astronomical calculations
  MoonPhaseData getMoonPhaseForDate(DateTime date) {
    final age = _calculateMoonAge(date);
    final illumination = _calculateIllumination(age);
    final phaseType = _getMoonPhaseType(illumination, age);
    
    return MoonPhaseData(
      date: date,
      illumination: illumination,
      phaseType: phaseType,
      age: age,
    );
  }

  /// Calculate moon age (days since last new moon)
  double _calculateMoonAge(DateTime date) {
    final daysSinceKnownNewMoon = date.difference(_knownNewMoon).inMilliseconds / (1000 * 60 * 60 * 24);
    final age = daysSinceKnownNewMoon % _lunarCycle;
    return age;
  }

  /// Calculate moon illumination (0.0 to 1.0)
  double _calculateIllumination(double age) {
    // Using cosine formula for illumination
    final phase = (age / _lunarCycle) * 2 * pi;
    final illumination = (1 - cos(phase)) / 2;
    return illumination.clamp(0.0, 1.0);
  }

  /// Get moon phases for next 30 days (approximately one lunar cycle)
  List<MoonPhaseData> getMonthlyMoonPhases({int days = 30}) {
    final List<MoonPhaseData> phases = [];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.add(Duration(days: i));
      phases.add(getMoonPhaseForDate(date));
    }

    return phases;
  }

  /// Get major moon phases (New, First Quarter, Full, Last Quarter) for next period (with caching)
  Future<List<MoonPhaseData>> getMajorMoonPhases({
    int days = 60,
    bool forceRefresh = false,
  }) async {
    // Check cache first unless force refresh
    if (!forceRefresh) {
      final cached = await _cacheService.getCache(
        CacheService.moonCalendarKey,
        CacheService.moonPhaseCacheDuration,
      );

      if (cached != null) {
        final phasesList = cached['phases'] as List;
        return phasesList.map((p) {
          return MoonPhaseData(
            date: DateTime.parse(p['date']),
            illumination: p['illumination'].toDouble(),
            phaseType: MoonPhaseType.values[p['phaseType']],
            age: p['age'].toDouble(),
          );
        }).toList();
      }
    }

    final List<MoonPhaseData> majorPhases = [];
    final now = DateTime.now();
    MoonPhaseType? lastMajorPhase;

    for (int i = 0; i < days; i++) {
      final date = now.add(Duration(days: i));
      final phase = getMoonPhaseForDate(date);

      // Check if this is a major phase and different from the last one
      if (_isMajorPhase(phase.phaseType) && phase.phaseType != lastMajorPhase) {
        majorPhases.add(phase);
        lastMajorPhase = phase.phaseType;
      }
    }

    final result = majorPhases.take(7).toList();

    // Cache the major phases
    await _cacheService.saveCache(CacheService.moonCalendarKey, {
      'phases': result.map((p) => {
        'date': p.date.toIso8601String(),
        'illumination': p.illumination,
        'phaseType': p.phaseType.index,
        'age': p.age,
      }).toList(),
    });

    return result;
  }

  /// Get moon calendar data
  MoonCalendarData getMoonCalendar({int days = 30}) {
    final phases = getMonthlyMoonPhases(days: days);
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));

    return MoonCalendarData(
      phases: phases,
      startDate: now,
      endDate: endDate,
    );
  }

  /// Determine moon phase type from illumination and age
  MoonPhaseType _getMoonPhaseType(double illumination, double age) {
    // New Moon: 0% illumination or age near 0
    if (illumination < 0.01 || age < 1.0) {
      return MoonPhaseType.newMoon;
    }
    
    // Full Moon: 100% illumination or age near 14.76
    if (illumination > 0.99 || (age > 13.5 && age < 15.5)) {
      return MoonPhaseType.fullMoon;
    }
    
    // First Quarter: ~50% and waxing (age 6-8 days)
    if (illumination >= 0.48 && illumination <= 0.52 && age >= 6.0 && age < 9.0) {
      return MoonPhaseType.firstQuarter;
    }
    
    // Last Quarter: ~50% and waning (age 20-23 days)
    if (illumination >= 0.48 && illumination <= 0.52 && age >= 20.0 && age < 23.0) {
      return MoonPhaseType.lastQuarter;
    }
    
    // Waxing phases (age 0-14.76 days)
    if (age < 14.76) {
      if (illumination < 0.5) {
        return MoonPhaseType.waxingCrescent;
      } else {
        return MoonPhaseType.waxingGibbous;
      }
    }
    
    // Waning phases (age 14.76-29.53 days)
    if (illumination > 0.5) {
      return MoonPhaseType.waningGibbous;
    } else {
      return MoonPhaseType.waningCrescent;
    }
  }

  /// Check if phase is a major phase
  bool _isMajorPhase(MoonPhaseType phase) {
    return phase == MoonPhaseType.newMoon ||
        phase == MoonPhaseType.firstQuarter ||
        phase == MoonPhaseType.fullMoon ||
        phase == MoonPhaseType.lastQuarter;
  }

  /// Get days until next full moon
  int getDaysUntilFullMoon() {
    final phases = getMonthlyMoonPhases(days: 30);
    final fullMoon = phases.firstWhere(
      (phase) => phase.phaseType == MoonPhaseType.fullMoon,
      orElse: () => phases.first,
    );
    
    return fullMoon.date.difference(DateTime.now()).inDays;
  }

  /// Get days until next new moon
  int getDaysUntilNewMoon() {
    final phases = getMonthlyMoonPhases(days: 30);
    final newMoon = phases.firstWhere(
      (phase) => phase.phaseType == MoonPhaseType.newMoon,
      orElse: () => phases.first,
    );
    
    return newMoon.date.difference(DateTime.now()).inDays;
  }
}
