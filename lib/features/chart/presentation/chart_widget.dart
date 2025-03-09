import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/primary_button.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/prediction.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/chart_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/custom_line_chart.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/info_block.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartWidget extends ConsumerWidget {
  final Prediction prediction;
  final List<Measurement> measurements;
  final List<FlSpot>? regression;
  final Adjustment adjustment;
  final Pump pump;

  const ChartWidget({
    super.key,
    required this.measurements,
    required this.adjustment,
    this.regression,
    required this.prediction,
    required this.pump,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double limit = 0.9;
    double? yIntercept = 0.0;

    // Extract the count from the adjustmentId => NM045-0
    RegExp regex = RegExp(r'\d$');
    Match? match = regex.firstMatch(adjustment.id);
    final count = match?[0] ?? '0';

    final hasMeasurements = measurements.isNotEmpty;
    final firstMeasurement = hasMeasurements ? measurements.first : null;
    final lastMeasurement = hasMeasurements ? measurements.last : null;
    
    debugPrint('prediction: $prediction');
    yIntercept = Utils().calculateXIntercept(prediction.a, prediction.b, (prediction.c - 0.9));
    debugPrint('intercept: $yIntercept');
   

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
                ),
              ),
            ),

            SizedBox(
              height: 275,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(2, 20, 10, 20),
                child: CustomLineChart(
                  blueLineSpots: hasMeasurements
                      ? measurements
                          .map((m) => FlSpot(
                                m.currentOperatingHours,
                                (pump.measurableParameter == 'volume flow') ? m.Qn : m.pn,
                              ))
                          .toList()
                      : [const FlSpot(0, 0)],
                  grayLineSpots: regression ?? [],
                  xAxisStart: firstMeasurement?.currentOperatingHours ?? 0,
                  xAxisEnd: lastMeasurement?.currentOperatingHours ?? 1,
                  yIntercept: yIntercept ?? 0.0,
                ),
              ),
            ),

             (adjustment.status == 'open') ?
              Align(
                alignment: Alignment.center,
                child: PrimaryButton(
                  label: 'Close ${adjustment.id}',
                  buttonColor: AppColors.greyColor,
                  onPressed: () {
                    ref.read(chartControllerProvider.notifier).closeAdjustment(adjustment.id);
                  },
                ),
              ) : Container(),
           
          ],
        ),
        ),
      ),
    );
  }
}