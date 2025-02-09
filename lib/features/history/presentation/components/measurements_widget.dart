import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/controllers/history_controller.dart';

/// Widget to display a list of measurements
class MeasurementsWidget extends ConsumerWidget {
  const MeasurementsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementsAsync = ref.watch(measurementsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return measurementsAsync.when(
          data: (measurements) => SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: 15.0,
                columns: const [
                  DataColumn(
                    label: Text(
                      "Datum",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0
                      ),
                    )
                  ),
                  DataColumn(
                    label: Text(
                      "h",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0
                      ),
                    )
                  ),
                  DataColumn(label: Text("n")),
                  DataColumn(label: Text("Q")),
                  DataColumn(label: Text(" Q/n")),
                  DataColumn(label: Text("")),
                ],
                rows: measurements.map((data) {
                  return DataRow(cells: [
                    DataCell(Text(_formatDate(data.date))),
                    DataCell(Text(data.currentOperatingHours.toString())),
                    DataCell(Text(data.rotationalFrequency.toString())),
                    DataCell(Text(data.volumeFlow.toString())),
                    DataCell(Text('1000')),
                    DataCell(IconButton(
                      onPressed: () => (),
                      icon: const Icon(Icons.more_horiz),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Text('Error loading measurements: $error'),
          ),
        );
      }
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} - "
           "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}