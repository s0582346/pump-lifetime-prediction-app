import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/prediction.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/custom_line_chart.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class DashboardWidget extends ConsumerWidget {
  final Prediction? prediction;
  final List<Measurement>? measurements;
  final List<FlSpot>? regression;
  //final Adjustment adjustment;
  final Pump pump;

  const DashboardWidget({
    super.key,
    required this.measurements,
    //required this.adjustment,
    this.regression,
    required this.prediction,
    required this.pump,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    /*for (var m in measurements!) {
      print(m.adjustmentId);
      print(m.QnTotal);
    }*/


    List<FlSpot> blueSpots = [];
    bool hasMeasurements = measurements != null && measurements!.isNotEmpty;
    
    final firstMeasurement = hasMeasurements ? measurements!.first : null;
    final lastMeasurement = hasMeasurements ? measurements!.last : null;

    final xOffset = firstMeasurement?.currentOperatingHours.toDouble() ?? 0.0;
    if (hasMeasurements) {
      blueSpots = measurements!.map((m) {
      return FlSpot(m.currentOperatingHours - xOffset, 
        (pump.measurableParameter == 'volume flow') ? m.QnTotal : m.pnTotal);
      }).toList();
    }

    return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const SizedBox(height: 20),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            pump.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          const Text('Pump Type: ', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(pump.type),
        ],
      ),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          const Text('Permissible Total Wear: ', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text("${pump.permissibleTotalWear.toStringAsFixed(0)} %"),
        ],
      ),
    ),
     if (pump.rotorGeometry != null && pump.rotorGeometry!.isNotEmpty)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
          children: [
            const Text('Rotor Geometry: ', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(pump.rotorGeometry),
          ],
        ),
    ),
    if (pump.medium != null && pump.medium!.isNotEmpty)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
          children: [
            const Text('Medium: ', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(pump.medium),
          ],
        ),
      ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          const Text('Type Of Time Entry: ', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(pump.typeOfTimeEntry.replaceAll('per day', '')),
        ],
      ),
    ),
    SizedBox(
      height: 400,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 20, 20, 20),
        child: CustomLineChart(
          blueLineSpots: blueSpots,
          grayLineSpots: regression ?? [],
          xAxisStart: firstMeasurement?.currentOperatingHours.toDouble() ?? 0.0,
          xAxisEnd: lastMeasurement?.currentOperatingHours.toDouble() ?? 0.0,
          minY: 0.2,
          maxY: 1.1,
          yInterval: 0.1,
        ),
      ),
    ),
  ],
);
  }

  
}