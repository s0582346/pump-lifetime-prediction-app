import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/primary_button.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/prediction.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/chart_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/custom_line_chart.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/info_block.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/legend_widget.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
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
    double limit = 0.900;
    double? yIntercept = prediction.estimatedOperatingHours; // set to the estimated operating hours as default, if no solution is found

    // Extract the count from the adjustmentId => NM045-0
    RegExp regex = RegExp(r'\d$');
    Match? match = regex.firstMatch(adjustment.id);
    final count = match?[0] ?? '0';

    final residualWear = pump.permissibleTotalWear - ((int.tryParse(count) ?? 0) * 10);

    final hasMeasurements = measurements.isNotEmpty;
    final firstMeasurement = hasMeasurements ? measurements.first : null;
    final lastMeasurement = hasMeasurements ? measurements.last : null;
    
    final solutions = Utils().findXForY(prediction.a, prediction.b, prediction.c, limit); // normally two solutions

    for (var solution in solutions) {
      if (solution > 0 && solution > yIntercept!) {
        yIntercept = solution;
        break;
      }
    }

    final xOffset = firstMeasurement?.currentOperatingHours.toDouble() ?? 0.0;
    List<FlSpot> blueSpots = measurements.map((m) {
      return FlSpot(m.currentOperatingHours - xOffset, 
        (pump.measurableParameter == 'volume flow') ? m.Qn : m.pn);
    }).toList();

      final legendItems = [
              LegendItem(label: 'Blue Line', color: Colors.blue, isLine: true),
              LegendItem(label: 'Gray Line', color: Colors.grey, isLine: true),
              LegendItem(
                label: 'Threshold', color: Colors.red, isLine: true, isDashed: true),
              LegendItem(
                label: 'Y-Intercept', color: Colors.black, isLine: true, isDashed: true),
            ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Shrink-wrap contents
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
                  isLast: isLast
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
                  xAxisEnd:  prediction.estimatedOperatingHours ?? lastMeasurement?.currentOperatingHours.toDouble() ?? 0.0,
                  yIntercept: yIntercept ?? 0.0,
                ),
              ),
            ),

            LegendWidget(legendItems: legendItems),
          ],
        ),
        ),
      ),
    );
  }
}