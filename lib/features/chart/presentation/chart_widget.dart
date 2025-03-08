import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/primary_button.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/chart_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';


class ChartWidget extends ConsumerWidget {
  final estimatedOperatingHours;
  final estimatedAdjustmentDay;
  final List<Measurement> measurements;
  final List<FlSpot>? regression;
  final String adjustmentId;
  final Pump pump;

  const ChartWidget({super.key, required this.measurements, required this.adjustmentId, this.regression, this.estimatedOperatingHours, this.estimatedAdjustmentDay, required this.pump});
 // adjustmentId = NM045
   

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    RegExp regex = RegExp(r'\d$');
    Match? match = regex.firstMatch(adjustmentId);
    final count = match![0];
  
  return Scaffold(
    backgroundColor: Colors.white,
    body: SingleChildScrollView(
        child: Column(
        children: [
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.topLeft,
              child: InfoBlock(
                currentOperatingHours: measurements.last.currentOperatingHours, 
                estimatedOperatingHours: estimatedOperatingHours, 
                count: count, 
                maintenanceDate: estimatedAdjustmentDay != null ? Utils().formatDate(estimatedAdjustmentDay) : '-'
                ),
            ),
          ),
          
          SizedBox(
            height: 275,
            width: double.infinity,
            child: Padding(
            // Use reasonable padding values
            padding: const EdgeInsets.fromLTRB(2, 20, 10, 20),
            child: CustomLineChart(
              blueLineSpots: measurements
                  .map((measurement) => FlSpot(
                        measurement.currentOperatingHours,
                        (pump.measurableParameter == 'volume flow') ? measurement.Qn : measurement.pn,
                      ))
                  .toList(),
              grayLineSpots: regression ?? [],
              xAxisStart: measurements.first.currentOperatingHours,
              xAxisEnd: measurements.last.currentOperatingHours,
              ),
            ),
          ),
          
          Align(
            alignment: Alignment.center,
            child: PrimaryButton(
              label: 'Adjustment took place',
              buttonColor: AppColors.greyColor,
              onPressed: () {
                  ref.read(chartControllerProvider.notifier).closeAdjustment(adjustmentId);
              },
            )
          ),
        ],
      ),
  )
  );
}

}

class InfoBlock extends StatelessWidget {
  final double currentOperatingHours;
  final double estimatedOperatingHours;
  final String maintenanceDate;
  final count;

  InfoBlock({super.key, required this.currentOperatingHours,required this.estimatedOperatingHours, required this.count, this.maintenanceDate = '-'});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$count - Adjustment",
          style: const TextStyle(fontSize: 23.0 , fontWeight: FontWeight.bold)),
        SizedBox(height: 15),

        Row(
          children: [
            Text(
              'Current Operating Hours: ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            Text(
              "${currentOperatingHours.toStringAsFixed(1)} h",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),

        SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Estimated Operating Hours: ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            Text(
              "${estimatedOperatingHours.toStringAsFixed(1)} h",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Estimated Adjustment Day: ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            Text(
              maintenanceDate,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class CustomLineChart extends StatelessWidget {
  final xAxisStart;
  final xAxisEnd ;
  final List<FlSpot> blueLineSpots;
  final List<FlSpot> grayLineSpots;
  
  const CustomLineChart({
    super.key,
    required this.blueLineSpots,
    required this.grayLineSpots,
    required this.xAxisStart,
    required this.xAxisEnd
  });

  @override
  Widget build(BuildContext context) {
    final flSpotStart = FlSpot(xAxisStart, 0.9);
    final flSpotEnd = FlSpot(xAxisEnd + 40, 0.9);

    final List<FlSpot> redHorizontalSpots = [
      flSpotStart,
      flSpotEnd,
    ];
    
    return LineChart(
      LineChartData(
        // Adjust these min/max values dynamically
        minX: xAxisStart,
        maxX: xAxisEnd + 40,
        minY: 0.8,
        maxY: 1.1,

        // Enable touch interactions
        lineTouchData: LineTouchData(enabled: true),

        // Axis Titles and Ticks
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: 0.05, // Keep density as required
            ),
          ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 15, // Ensure bottom titles appear at interval of 10
          getTitlesWidget: (value, meta) {
            if (value % 15 == 0) {
              return Text(value.toInt().toStringAsFixed(1),
                style: TextStyle(fontSize: 15, color: Colors.black),);
            }
            return Container(); // Hide non-matching values
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),

    // Grid lines
    gridData: const FlGridData(
      show: true,
      drawVerticalLine: false,  // Ensure vertical lines match bottom interval
      drawHorizontalLine: true,
      verticalInterval: 10,  // Match bottom title interval
      horizontalInterval: 0.05,
    ),

    // Borders
    borderData: FlBorderData(
      show: true,
      border: const Border(
        bottom: BorderSide(color: Colors.grey, width: 1),
        left: BorderSide(color: Colors.grey, width: 1),
        right: BorderSide(color: Colors.transparent),
        top: BorderSide(color: Colors.transparent),
      ),
    ),

    // Line chart data
    lineBarsData: [
      // Blue Line Data
      LineChartBarData(
        spots: blueLineSpots,
        isCurved: false,
        color: Colors.blue,
        barWidth: 2,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, _, __, ___) {
            return FlDotCirclePainter(
              radius: 4,
              color: Colors.blue,
              strokeColor: Colors.white,
              strokeWidth: 1,
            );
          },
        ),
      ),

      // Gray Line Data
      LineChartBarData(
        spots: grayLineSpots,
        isCurved: true,
        color: Colors.grey,
        barWidth: 2,
        dotData: FlDotData(show: false),
      ),

      // Red Horizontal Line at y=0.9
      LineChartBarData(
        spots: redHorizontalSpots,
        isCurved: false,
        color: Colors.red,
        barWidth: 2,
        dashArray: [5, 5],
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, _, __, ___) {
            return FlDotCirclePainter(
              radius: 1,
              color: Colors.red,
              strokeColor: Colors.red,
              strokeWidth: 2,
            );
          },
        ),
      ),
      ],
    ),
  );

  
  }
}
