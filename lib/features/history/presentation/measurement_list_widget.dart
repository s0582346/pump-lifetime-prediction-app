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
              headingRowAlignment: MainAxisAlignment.center,
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
              label: Text(
                lCLabel,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
            if (adjustment!.status == 'open')
            DataColumn(
              headingRowAlignment: MainAxisAlignment.center,
              label: Center(
                child: CircleAvatar(
                  backgroundColor: AppColors.primaryColor,
                  radius: 14,
                  child: IconButton(
                    onPressed: () => _navigateToFormScreen(context),
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
            ),
          ],
          rows: (measurements ?? []).map((data) {
            final slCVal = (pump?.measurableParameter == 'volume flow') ? data.volumeFlow : data.pressure;
            final lCVal = (pump?.measurableParameter == 'volume flow') ? data.Qn : data.pn;
            
            return DataRow(cells: [
              DataCell(Center(child: Text(_formatDate(data.date)))),
              DataCell(Center(child: Text(data.currentOperatingHours.toStringAsFixed(0)))),
              DataCell(Center(child: Text(data.rotationalFrequency.toStringAsFixed(_hasDecimals(data.rotationalFrequency) ? 2 : 1)))),
              DataCell(Center(child: Text(slCVal.toStringAsFixed(2)))),
              DataCell(Center(child: Text(lCVal.toStringAsFixed(2)))),
              if (adjustment!.status == 'open') 
              DataCell(
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 30, // Match height with add button
                    width: 30,
                    child: IconButton(
                      onPressed: () {
                        ref.read(measurementProvider.notifier).loadMeasurement(data);
                        _navigateToFormScreen(context);
                      },
                      icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(), // Remove default sizing
                    ),
                  ),
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

  bool _hasDecimals(double value) {
    return (value % 1) != 0;
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
