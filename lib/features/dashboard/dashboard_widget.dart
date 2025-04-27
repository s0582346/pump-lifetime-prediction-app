import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/dashboard/adjustments_table.dart';
import 'package:flutter_predictive_maintenance_app/features/dashboard/property_widget.dart';
import 'package:flutter_predictive_maintenance_app/features/prediction/prediction.dart';
import 'package:flutter_predictive_maintenance_app/features/dashboard/sum_line_chart.dart';
import 'package:flutter_predictive_maintenance_app/features/history/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/measurable_parameter.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class DashboardWidget extends ConsumerWidget {
  final List<Prediction>? predictions;
  final List<Measurement>? measurements;
  final List<FlSpot>? regression;
  final List<Adjustment> adjustments;
  final Pump pump;

  const DashboardWidget({
    super.key,
    required this.measurements,
    required this.adjustments,
    this.regression,
    required this.predictions,
    required this.pump,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    List<FlSpot> blueSpots = [];
    bool hasMeasurements = measurements != null && measurements!.isNotEmpty;
    
    final firstMeasurement = hasMeasurements ? measurements!.first : null;
    final lastMeasurement = hasMeasurements ? measurements!.last : null;

    // Create blue spots for the chart based on the measurements
    final xOffset = firstMeasurement?.currentOperatingHours.toDouble() ?? 0.0;
    if (hasMeasurements) {
      blueSpots = measurements!.map((m) {
        return FlSpot(m.currentOperatingHours - xOffset, (pump.measurableParameter == MeasurableParameter.volumeFlow) ? m.QnTotal : m.pnTotal); }).toList();
    }

    double xAxisEnd;
    if (predictions != null && predictions!.isNotEmpty && lastMeasurement != null) {
      final predictedOperatingHours = predictions!.last.estimatedOperatingHours ?? 0.0;
      final lastMeasuredHours = lastMeasurement.currentOperatingHours.toDouble() ?? 0.0;
      xAxisEnd = (predictedOperatingHours > lastMeasuredHours) ? predictedOperatingHours : lastMeasuredHours;
    } else {
      xAxisEnd = lastMeasurement?.currentOperatingHours.toDouble() ?? 0.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.0),
          child: 
              Text(
                pump.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
                overflow: TextOverflow.clip,
              ),
          ),
        const Divider(height: 10, thickness: 1.5, indent: 10, endIndent: 10, color: Colors.grey),
        const SizedBox(height: 10),
        PropertyWidget(
          label: 'Pump Type',
          value: pump.type!.toString(),
        ),
        PropertyWidget(
          label: 'Permissible Total Wear',
          value: "${pump.permissibleTotalWear.toStringAsFixed(0)} %",
        ),
        if (pump.rotorGeometry != null && pump.rotorGeometry!.label.isNotEmpty)
        PropertyWidget(
          label: 'Rotor Geometry',
          value: pump.rotorGeometry!.label,
        ),
        if (pump.solidConcentration != null)
        PropertyWidget(
          label: 'Solid Concentration',
          value: "${pump.solidConcentration} %",
        ),
        if (pump.medium != null && pump.medium!.isNotEmpty)
        PropertyWidget(
          label: 'Medium',
          value: pump.medium,
        ),
        PropertyWidget(
          label: 'Type Of Time Entry',
          value: pump.typeOfTimeEntry!.label.replaceAll('per day', ''),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 400,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 20, 20, 20),
            child: SumLineChart(
              blueLineSpots: blueSpots,
              grayLineSpots: regression ?? [],
              xAxisStart: firstMeasurement?.currentOperatingHours.toDouble() ?? 0.0,
              xAxisEnd: xAxisEnd,
              minY: _calculateMinY(pump.permissibleTotalWear),
              maxY: 1.1,
              yInterval: 0.1,
              adjustments: adjustments,
              predictions: predictions,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(height: 10, thickness: 1.5, indent: 10, endIndent: 10, color: Colors.grey),
        AdjustmentsTable(
          adjustments: adjustments,
          totalMeasurements: measurements ?? [],
          predictions: predictions ?? [],
        ),
        const SizedBox(height: 20),
      ]
    );
  }

  double _calculateMinY(double permissibleTotalWear) {
    return 1 - (permissibleTotalWear / 100);
  }
}