import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';

class MeasurementListWidget extends ConsumerWidget {
  final List<Measurement> measurements;

  const MeasurementListWidget({super.key, required this.measurements});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pump = ref.watch(selectedPumpProvider);
    final slCLabel = (pump?.measurableParameter == 'volume flow') ? 'Q' : 'n';
    final lCLabel = (pump?.measurableParameter == 'volume flow') ? 'Q/n' : 'p/n';
    
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 20.0,
          headingRowHeight: 40.0,
          columns: [
            const DataColumn(
              label: Text(
                "Datum",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
            const DataColumn(
              label: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Text("h",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
              ), 
            ),
            const DataColumn(
              label: Text(
                "n",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
            DataColumn(
              label: Text(
                slCLabel,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
            DataColumn(
              label: Text(
                lCLabel,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
          ],
          rows: measurements.map((data) {
            final slCVal = (pump?.measurableParameter == 'volume flow') ? data.volumeFlow : data.pressure;
            final lCVal = (pump?.measurableParameter == 'volume flow') ? data.Qn : data.pn;

            return DataRow(cells: [
              DataCell(Text(_formatDate(data.date))),
              DataCell(Text(data.currentOperatingHours.toStringAsFixed(1))),
              DataCell(Text(data.rotationalFrequency.toStringAsFixed(2))),
              DataCell(Text(slCVal.toStringAsFixed(2))),
              DataCell(Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(lCVal.toStringAsFixed(3)),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz),
                  ),
                ],
                )
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
