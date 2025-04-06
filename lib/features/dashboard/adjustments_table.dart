import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/history/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/prediction/prediction.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';

class AdjustmentsTable extends StatelessWidget {
  final List<Adjustment> adjustments;
  final List<Measurement>? totalMeasurements;
  final List<Prediction>? predictions;
  
  const AdjustmentsTable({
    super.key,
    required this.adjustments,
    required this.totalMeasurements,
    required this.predictions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
  padding: const EdgeInsets.all(10.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Divider(height: 10, thickness: 1.5, color: Colors.grey),
      DataTable(
        columnSpacing: 40.0,
        headingRowHeight: 50.0,
        columns: const [
          DataColumn(label: Text('Adjustment')),
          DataColumn(label: Text('h - target')),
          DataColumn(label: Text('h - actual')),
        ],
        rows: adjustments.map((data) {

          // Filter measurements matching the current adjustment
          final matchingMeasurements = totalMeasurements!
              .where((m) => m.adjustmentId == data.id)
              .toList();

          // Safely get operating hours from the last measurement or a fallback if none exist
          final operatingHours = matchingMeasurements.isNotEmpty
              ? matchingMeasurements.last.currentOperatingHours.toStringAsFixed(0)
              : '-';

          // Find a prediction for the current adjustment or return a default Prediction
          final prediction = predictions!.firstWhere(
            (p) => p.adjusmentId == data.id,
            orElse: () => Prediction(),
          );

          // Safely get the estimated operating hours from prediction or a fallback
          final estimatedOperatingHours = prediction.estimatedOperatingHours != null
              ? prediction.estimatedOperatingHours!.toStringAsFixed(0)
              : '-';

          return DataRow(
            cells: [
              DataCell(Text(Utils().formatTabLabel(data.id))),
              DataCell(Text(estimatedOperatingHours)),
              DataCell(Text(operatingHours)),
            ],
          );
        }).toList(),
      ),
    ],
  ),
);

  }
}