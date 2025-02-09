import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';

class MeasurementListWidget extends ConsumerWidget {
  final List<Measurement> measurements;

  const MeasurementListWidget({Key? key, required this.measurements}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // Enables horizontal scrolling if needed
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 30.0,
          columns: const [
            DataColumn(
              label: Text(
                "Datum",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
            DataColumn(
              label: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Text("h",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
              ), 
            ),
            DataColumn(
              label: Text(
                "n",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
            DataColumn(
              label: Text(
                "Q",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
            DataColumn(
              label: Text(
                "Q/n",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
            DataColumn(label: Text(""),
            ),
          ],
          rows: measurements.map((data) {
            return DataRow(cells: [
              DataCell(Text(_formatDate(data.date))),
              DataCell(Text(data.currentOperatingHours.toString())),
              DataCell(Text(data.rotationalFrequency.toString())),
              DataCell(Text(data.volumeFlow.toString())),
              DataCell(Text((data.volumeFlow / data.rotationalFrequency).toStringAsFixed(2))), // Calculated value
              DataCell(
                IconButton(
                  onPressed: () {
                    // Add action when clicked
                  },
                  icon: const Icon(Icons.more_horiz),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
    // - ${date.hour}:${date.minute.toString().padLeft(2, '0')}
  }
}
