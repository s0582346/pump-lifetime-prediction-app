import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/prediction/prediction.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/custom_line_chart.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/info_block.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/legend_widget.dart';
import 'package:flutter_predictive_maintenance_app/features/history/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/measurable_parameter.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
import 'package:flutter_predictive_maintenance_app/shared/math_utils.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartWidget extends ConsumerWidget {
  final Prediction prediction;
  final List<Measurement> measurements;
  final List<FlSpot>? regression;
  final Adjustment adjustment;
  final Pump pump;
  final bool isLast;

  const ChartWidget({
    super.key,
    required this.measurements,
    required this.adjustment,
    this.regression,
    required this.prediction,
    required this.pump,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double thresholdLimit = 0.900;
    double? yIntercept = prediction.estimatedOperatingHours;
    final isVolumeFlow = pump.measurableParameter == MeasurableParameter.volumeFlow;

    // Extract count from the adjustment id (e.g., NM045-0).
    final count = _extractCountFromAdjustment(adjustment.id);
    final residualWear = pump.permissibleTotalWear - ((int.tryParse(count) ?? 0) * 10);

    final hasMeasurements = measurements.isNotEmpty;
    final firstMeasurement = hasMeasurements ? measurements.first : null;
    final lastMeasurement = hasMeasurements ? measurements.last : null;

    // Determine the yIntercept based on the threshold.
    final solutions = MathUtils().findIntersectionAtY(prediction.a, prediction.b, prediction.c, thresholdLimit);
    for (var solution in solutions) {
      if (solution > 0 && solution > (yIntercept ?? 0)) {
        yIntercept = solution;
        break;
      }
    }

    final xOffset = firstMeasurement?.currentOperatingHours.toDouble() ?? 0.0;
    final blueSpots = measurements.map((m) {
      return FlSpot(
        m.currentOperatingHours - xOffset,
        isVolumeFlow ? m.Qn : m.pn,
      );
    }).toList();

    final legendItems = [
      LegendItem(
        label: isVolumeFlow ? 'Q/n' : 'p/n',
        color: Colors.blue,
        isLine: true,
      ),
      LegendItem(
        label: 'Regression',
        color: Colors.grey,
        isLine: true,
      ),
      LegendItem(
        label: 'Threshold',
        color: Colors.amber,
        isLine: true,
        isDashed: true,
      ),
      LegendItem(
        label: 'Operating Hours',
        color: Colors.black,
        isLine: true,
        isDashed: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.topLeft,
            child: InfoBlock(
              currentOperatingHours: lastMeasurement?.currentOperatingHours ?? 0.0,
              estimatedOperatingHours: prediction.estimatedOperatingHours ?? 0.0,
              count: count,
              maintenanceDate: prediction.estimatedMaintenanceDate != null
                  ? Utils().formatDate(prediction.estimatedMaintenanceDate)
                  : '-',
              residualWear: residualWear,
              adjustment: adjustment,
              pump: pump,
              isLast: isLast,
            ),
          ),
        ),
        SizedBox(
          height: 275,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 20, 20, 20),
            child: CustomLineChart(
              blueLineSpots: blueSpots,
              grayLineSpots: regression ?? [],
              xAxisStart: firstMeasurement?.currentOperatingHours.toDouble() ?? 0.0,
              xAxisEnd: prediction.estimatedOperatingHours ??
                  lastMeasurement?.currentOperatingHours.toDouble() ??
                  0.0,
              yIntercept: yIntercept ?? 0.0,
            ),
          ),
        ),
        LegendWidget(legendItems: legendItems),
        const SizedBox(height: 10),
      ],
    );
  }

  String _extractCountFromAdjustment(String adjustmentId) {
    final regex = RegExp(r'\d$');
    final match = regex.firstMatch(adjustmentId);
    return match?[0] ?? '0';
  }
}
