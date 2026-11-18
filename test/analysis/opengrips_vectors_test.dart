import 'dart:convert';
import 'dart:io';

import 'package:crimpdeq/analysis/opengrips_curve.dart';
import 'package:flutter_test/flutter_test.dart';

/// The shared OpenGrips formula spec, so this app and opengrips.xyz train on
/// the same curve: test vectors of OpenGripsWebFormulas v1.0.1 (MIT,
/// https://github.com/Jared-Is-Coding/OpenGripsWebFormulas). Two parts do not
/// apply here:
/// - Without a benchmark the spec classifies forces by their position on the
///   chart axis. This app shows no curve without a benchmark and classifies
///   any force as Power.
/// - `forceCurveDataset` parses opengrips.xyz database rows.
final _vectors = jsonDecode(
  File('test/fixtures/opengrips_web_formulas/test-vectors.json')
      .readAsStringSync(),
) as Map<String, dynamic>;

final _tolerances = _vectors['metadata']['tolerances'] as Map<String, dynamic>;
final _floatTolerance = _tolerances['floatTolerance'] as double;

List<Map<String, dynamic>> _cases(Object? suite) =>
    (suite as List).cast<Map<String, dynamic>>();

double _kg(Object? value) => (value as num).toDouble();

CurveSection _section(Object? label) =>
    CurveSection.values.firstWhere((section) => section.label == label);

void main() {
  test('constants', () {
    final constants = _vectors['constants'] as Map<String, dynamic>;
    expect(balancedRatio, constants['BALANCED_RATIO']);
    expect(defaultRestSeconds, constants['DEFAULT_REST']);
  });

  test('idealForceCurve', () {
    for (final curve in _cases(_vectors['idealForceCurve'])) {
      final benchmarkKg = _kg(curve['benchmarkWeightKg']);
      expect(
        curveFloorKg(benchmarkKg),
        closeTo(_kg(curve['minWeightKg']), _floatTolerance),
      );
      for (final sample in _cases(curve['weightAtTimeSamples'])) {
        expect(
          idealForceKg(_kg(sample['tSeconds']), benchmarkKg),
          closeTo(_kg(sample['weightKg']), _floatTolerance),
          reason: 'benchmark $benchmarkKg, $sample',
        );
      }
      for (final sample in _cases(curve['idealTimeSamples'])) {
        expect(
          idealFirstHangSeconds(_kg(sample['weightKg']), benchmarkKg),
          sample['idealTimeSeconds'],
          reason: 'benchmark $benchmarkKg, $sample',
        );
      }
    }
  });

  test('deriveBenchmarkWeight', () {
    for (final hold in _cases(_vectors['deriveBenchmarkWeight'])) {
      expect(
        deriveBenchmarkKg(_kg(hold['weightKg']), _kg(hold['timeHeldSeconds'])),
        closeTo(
          _kg(hold['expectedBenchmarkWeightKg']),
          _tolerances['benchmarkDerivationTolerance'] as double,
        ),
        reason: hold['label'] as String,
      );
    }
  });

  group('sectionClassification', () {
    final suite = _vectors['sectionClassification'] as Map<String, dynamic>;

    test('byBenchmarkWeight', () {
      for (final force in _cases(suite['byBenchmarkWeight'])) {
        expect(
          CurveSection.of(
            _kg(force['usedWeightKg']),
            _kg(force['maxPowerBenchmarkKg']),
          ),
          _section(force['expectedSection']),
          reason: '$force',
        );
      }
    });

    test('getCurveSection with a benchmark', () {
      for (final force in _cases(suite['getCurveSection'])) {
        final benchmarkKg = force['benchmarkWeightKg'] as num?;
        if (benchmarkKg == null || benchmarkKg <= 0) continue;
        expect(
          CurveSection.of(_kg(force['usedWeightKg']), _kg(benchmarkKg)),
          _section(force['expectedSection']),
          reason: '$force',
        );
      }
    });

    test('sectionBoundsAndSuggestions', () {
      for (final curve in _cases(suite['sectionBoundsAndSuggestions'])) {
        final benchmarkKg = _kg(curve['benchmarkWeightKg']);
        for (final bounds in _cases(curve['sections'])) {
          final section = _section(bounds['section']);
          final reason = 'benchmark $benchmarkKg, ${section.label}';
          expect(
            section.targetForceKg(benchmarkKg),
            closeTo(_kg(bounds['suggestedWeightKg']), _floatTolerance),
            reason: reason,
          );
          final rangeKg = section.rangeKg(benchmarkKg);
          expect(
            rangeKg.min,
            closeTo(_kg(bounds['lowerBoundaryWeightKg']), _floatTolerance),
            reason: reason,
          );
          expect(
            rangeKg.max,
            closeTo(_kg(bounds['upperBoundaryWeightKg']), _floatTolerance),
            reason: reason,
          );
        }
      }
    });
  });

  test('repTargetsPerSection', () {
    final suite = _vectors['repTargetsPerSection'] as Map<String, dynamic>;
    for (final model in _cases(suite['sectionModels'])) {
      for (final workout in _cases(model['cases'])) {
        final reps = _cases(workout['reps']);
        expect(
          repTargetSeconds(
            _section(model['section']),
            reps: reps.length,
            firstHangSeconds: workout['firstHangTarget'] as int,
          ),
          [for (final rep in reps) rep['targetTimeSeconds']],
          reason: '${model['section']}, ${workout['firstHangTarget']} s',
        );
      }
    }
  });

  group('manualEnergyCurve', () {
    final suite = _vectors['manualEnergyCurve'] as Map<String, dynamic>;

    test('sliderBounds', () {
      final bounds = suite['sliderBounds'] as Map<String, dynamic>;
      for (final bound in _cases(bounds['powerEnduranceMin'])) {
        expect(
          powerEnduranceRange(_kg(bound['endurance'])).min,
          closeTo(_kg(bound['expectedMin']), _floatTolerance),
          reason: '$bound',
        );
      }
      for (final bound in _cases(bounds['powerMin'])) {
        expect(
          powerRange(_kg(bound['powerEndurance'])).min,
          closeTo(_kg(bound['expectedMin']), _floatTolerance),
          reason: '$bound',
        );
      }
      for (final bound in _cases(bounds['powerMax'])) {
        expect(
          powerRange(_kg(bound['powerEndurance'])).max,
          closeTo(_kg(bound['expectedMax']), _floatTolerance),
          reason: '$bound',
        );
      }
    });

    test('repTargetCases', () {
      for (final workout in _cases(suite['repTargetCases'])) {
        final reps = _cases(workout['reps']);
        expect(
          repTargetSeconds(
            // With energy systems the targets do not depend on the section.
            CurveSection.power,
            reps: reps.length,
            firstHangSeconds: workout['firstHangTarget'] as int,
            energySystems: (
              power: _kg(workout['power']),
              powerEndurance: _kg(workout['powerEndurance']),
              endurance: _kg(workout['endurance']),
            ),
          ),
          [for (final rep in reps) rep['targetTimeSeconds']],
          reason: workout['label'] as String,
        );
      }
    });
  });

  test('chartAxisAndCoverage with a benchmark', () {
    for (final chart in _cases(_vectors['chartAxisAndCoverage'])) {
      final benchmarkKg = chart['benchmarkWeightKg'] as num?;
      if (benchmarkKg == null) continue;
      final expected = chart['expected'] as Map<String, dynamic>;
      final label = chart['label'] as String;
      final points = _cases(expected['points']);
      final axisKg = forceAxisKg(_kg(benchmarkKg), [
        for (final point in points) _kg(point['weightKg']),
      ]);
      expect(
        axisKg.min,
        closeTo(_kg(expected['weightMin']), _floatTolerance),
        reason: label,
      );
      expect(
        axisKg.max,
        closeTo(_kg(expected['weightMax']), _floatTolerance),
        reason: label,
      );
      final sections = [
        for (final point in points)
          CurveSection.of(
            _kg(point['weightKg']),
            _kg(point['benchmarkWeightKg'] ?? benchmarkKg),
          ),
      ];
      expect(sections, [
        for (final point in points) _section(point['section']),
      ], reason: label);
      expect(
        {
          for (final section in CurveSection.values)
            section.label: sections.where((s) => s == section).length,
        },
        {
          for (final coverage in _cases(expected['coverage']))
            coverage['section']: coverage['count'],
        },
        reason: label,
      );
    }
  });
}
