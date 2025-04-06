import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/dashboard/property_widget.dart';
import 'package:flutter_predictive_maintenance_app/features/prediction/prediction.dart';
import 'package:flutter_predictive_maintenance_app/features/dashboard/sum_line_chart.dart';
import 'package:flutter_predictive_maintenance_app/features/history/domain/measurement.dart';
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

    final xOffset = firstMeasurement?.currentOperatingHours.toDouble() ?? 0.0;
    if (hasMeasurements) {
      blueSpots = measurements!.map((m) {
        return FlSpot(m.currentOperatingHours - xOffset, (pump.measurableParameter == 'volume flow') ? m.QnTotal : m.pnTotal); }).toList();
    }

    return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const SizedBox(height: 20),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.0),
      child: Row(
        //mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            pump.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ],
      ),
    ),
    const Divider(height: 10, thickness: 1.5, indent: 10, endIndent: 10, color: Colors.grey),
    const SizedBox(height: 10),
    PropertyWidget(
      label: 'Pump Type',
      value: pump.type,
    ),
    PropertyWidget(
      label: 'Permissible Total Wear',
      value: "${pump.permissibleTotalWear.toStringAsFixed(0)} %",
    ),
    if (pump.rotorGeometry != null && pump.rotorGeometry!.isNotEmpty)
    PropertyWidget(
      label: 'Rotor Geometry',
      value: pump.rotorGeometry,
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
      value: pump.typeOfTimeEntry.replaceAll('per day', ''),
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
          xAxisEnd: lastMeasurement?.currentOperatingHours.toDouble() ?? 0.0,
          minY: 0.2,
          maxY: 1.1,
          yInterval: 0.1,
          adjustments: adjustments,
          predictions: predictions,
        ),
      ),
    ),
  ],
);
  }

  
}