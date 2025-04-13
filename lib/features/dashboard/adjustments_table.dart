import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/history/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/prediction/prediction.dart';
import 'package:flutter_predictive_maintenance_app/shared/math_utils.dart';
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
      //padding: const EdgeInsets.all(10.0),
      // Ensure the container takes up full available width.
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: 10.0,
                headingRowHeight: 50.0,
                columns: const [
                  DataColumn(
                    headingRowAlignment: MainAxisAlignment.start,
                    label: Text('Name'),
                  ),
                  DataColumn(
                    headingRowAlignment: MainAxisAlignment.center,
                    label: Text('h - target')
                  ),
                  DataColumn(
                    headingRowAlignment: MainAxisAlignment.center,
                    label: Text('h - actual')
                  ),
                  DataColumn(
                    headingRowAlignment: MainAxisAlignment.center,
                    label: Text('Actual Wear %')
                  ),
                ],
                rows: adjustments.map((adjustment) {
                  if (adjustment.status == 'open') {
                    return const DataRow(cells: [
                      DataCell(Center(child: Text(('-')))),
                      DataCell(Center(child: Text(('-')))),
                      DataCell(Center(child: Text(('-')))),
                      DataCell(Center(child: Text(('-')))),
                    ]);
                  }

                  // Filter measurements matching the current adjustment.
                  final matchingMeasurements = totalMeasurements!
                      .where((m) => m.adjustmentId == adjustment.id)
                      .toList();

                  // Safely get operating hours from the last measurement or a fallback.
                  final operatingHours = matchingMeasurements.isNotEmpty
                      ? matchingMeasurements.last.currentOperatingHours.toStringAsFixed(0)
                      : '-';

                  // Find a prediction for the current adjustment or return a default Prediction.
                  final prediction = predictions!.firstWhere(
                    (p) => p.adjusmentId == adjustment.id,
                    orElse: () => Prediction(),
                  );

                  // Get estimated operating hours from prediction.
                  final estimatedOperatingHours = prediction.estimatedOperatingHours != null
                      ? prediction.estimatedOperatingHours!.toStringAsFixed(0)
                      : '-';

                  // Calculate wear if measurements exist.
                  final wear = matchingMeasurements.isNotEmpty
                      ? MathUtils().calculateActualWear(matchingMeasurements.last)?.toString() ?? '-'
                      : '-';

                  return DataRow(
                    cells: [
                      DataCell(Text(Utils().formatTabLabel(adjustment.id))),
                      DataCell(Center(child: Text(estimatedOperatingHours))),
                      DataCell(Center(child: Text(operatingHours))),
                      DataCell(Center(child: Text(wear))),
                    ],
                  );
                }).toList(),
              ),
          );
        },
      ),
    );
  }
}

