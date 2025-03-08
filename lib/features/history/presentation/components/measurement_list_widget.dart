import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/presentation/form_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';
import 'package:intl/intl.dart';

class MeasurementListWidget extends ConsumerWidget {
  final List<Measurement> measurements;

  const MeasurementListWidget({super.key, required this.measurements});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pump = ref.watch(selectedPumpProvider);
    final slCLabel = (pump?.measurableParameter == 'volume flow') ? 'Q' : 'p'; // Second last column
    final lCLabel = (pump?.measurableParameter == 'volume flow') ? 'Q/n' : 'p/n'; // Last column

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 20.0,
          headingRowHeight: 50.0,
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
                child: Text(
                  "h",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
            DataColumn(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lCLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  const SizedBox(width: 25),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryColor, // Change as needed
                    radius: 15,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const FormScreen(),
                          ),
                        ); 
                      },
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
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
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lCVal.toStringAsFixed(3)),
                    const SizedBox(width: 7),
                    IconButton(
                      onPressed: () {
                        // Define the edit action
                      },
                      icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    DateTime parsedDate;

    if (date is DateTime) {
      parsedDate = date;
    } else if (date is String) {
      // Assuming the string is in the format "dd.MM.yyyy"
      parsedDate = DateFormat('yyyy-MM-dd').parse(date);
    } else {
      throw Exception('Unsupported date format');
    }

    return "${parsedDate.day.toString().padLeft(2, '0')}"
        ".${parsedDate.month.toString().padLeft(2, '0')}"
        ".${parsedDate.year}";
  }
}
