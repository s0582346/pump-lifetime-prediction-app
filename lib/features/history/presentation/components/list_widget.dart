import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/controllers/measurement_list_controller.dart';


class ListWidget extends ConsumerWidget {
  const ListWidget({Key? key}) : super(key: key);

    @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurement = ref.watch(measurementDataProvider);

    return LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: constraints.maxWidth),
        child: DataTable(
          columnSpacing: 15.0,
          columns: const [
          DataColumn(label: Text(
            "Datum",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.0
              ),
          )),
          DataColumn(label: Text(
            "  h",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0
              ),
          )),
          DataColumn(label: Text("   n")),
          DataColumn(label: Text("   Q")),
          DataColumn(label: Text(" Q/n")),
          DataColumn(label: Text("")),
        ],
        rows: measurement.map((data) {
          return DataRow(cells: [
            DataCell(Text(_formatDate(data.date))),
            DataCell(Text(data.currentOperatingHours.toStringAsFixed(2))),
            DataCell(Text(data.pressure.toStringAsFixed(2))),
            DataCell(Text(data.currentOperatingHours.toStringAsFixed(2))),
            DataCell(Text('1000')),
            DataCell(IconButton(
              onPressed: () => (),
              icon: Icon(Icons.more_horiz),
            )),
          ]);
        }).toList(),
      ),
    )
      );
    }
    );    
  }

  // Helper to format DateTime to match UI
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} - "
           "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}