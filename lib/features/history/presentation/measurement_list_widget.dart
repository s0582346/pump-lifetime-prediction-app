import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/form_screen.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/measurement_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/history/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';
import 'package:intl/intl.dart';

class MeasurementListWidget extends ConsumerWidget {
  final List<Measurement>? measurements;
  final Adjustment? adjustment;

  const MeasurementListWidget({super.key, required this.measurements, required this.adjustment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pump = ref.watch(selectedPumpProvider);
    final slCLabel = (pump?.measurableParameter == 'volume flow') ? 'Q' : 'p'; // Second last column
    final lCLabel = (pump?.measurableParameter == 'volume flow') ? 'Q/n' : 'p/n'; // Last column

    return DataTable(
          columnSpacing: 20.0,
          headingRowHeight: 50.0,
          columns: [
            const DataColumn(
              headingRowAlignment: MainAxisAlignment.start,
              label: Text(
                "Datum",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
            const DataColumn(
              headingRowAlignment: MainAxisAlignment.center,
              label: Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Text(
                  "h",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
              ),
            ),
            const DataColumn(
              headingRowAlignment: MainAxisAlignment.center,
              label: Text(
                "n",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
            DataColumn(
              headingRowAlignment: MainAxisAlignment.center,
              label: Text(
                slCLabel,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
            DataColumn(
              headingRowAlignment: MainAxisAlignment.center,
              label: Row(
                children: [
                  Text(
                    lCLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  //const SizedBox(width: 10),
                  (adjustment!.status == 'open')
                      ? Padding(padding: const EdgeInsets.only(left: 20.0), 
                       child: CircleAvatar(
                          backgroundColor: AppColors.primaryColor,
                          radius: 15,
                          child: IconButton(
                            onPressed: () => _navigateToFormScreen(context),
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                            padding: EdgeInsets.zero,
                          ),
                        ))
                      : Container()
                ],
              ),
            ),
          ],
          rows: (measurements ?? []).map((data) {
            final slCVal = (pump?.measurableParameter == 'volume flow') ? data.volumeFlow : data.pressure;
            final lCVal = (pump?.measurableParameter == 'volume flow') ? data.Qn : data.pn;

            return DataRow(cells: [
              DataCell(Text(_formatDate(data.date))),
              DataCell(Center(child: Text(data.currentOperatingHours.toStringAsFixed(1)))),
              DataCell(Center(child:Text(data.rotationalFrequency.toStringAsFixed(2)))),
              DataCell(Center(child:Text(slCVal.toStringAsFixed(2)))),
              DataCell(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(child: Text(lCVal.toStringAsFixed(3))),
                    //const SizedBox(width: 5),
                    (adjustment!.status == 'open') 
                      ? IconButton(
                        onPressed: () {
                          ref.read(measurementProvider.notifier).loadMeasurement(data);
                          _navigateToFormScreen(context);
                        },
                        icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                      )
                      : Container()
                  ],
                ),
              ),
            ]);
          }).toList(),
    );
  }

  void _navigateToFormScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FormScreen(),
      ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      DateTime parsedDate = date is String
          ? DateFormat('yyyy-MM-dd').parse(date)
          : date as DateTime;

      return "${parsedDate.day.toString().padLeft(2, '0')}"
          ".${parsedDate.month.toString().padLeft(2, '0')}"
          ".${parsedDate.year}";
    } catch (e) {
      return "Invalid Date"; // Fallback if parsing fails
    }
  }
}
