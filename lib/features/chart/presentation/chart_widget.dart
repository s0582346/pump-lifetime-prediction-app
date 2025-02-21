import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/primary_button.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/chart_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';


class ChartWidget extends ConsumerWidget {
  final estimatedOperatingHours;
  final List<Measurement> measurements;
  final List<FlSpot>? regression;
  final String adjustmentId;

  const ChartWidget({super.key, required this.measurements, required this.adjustmentId, this.regression, this.estimatedOperatingHours});
 // adjustmentId = NM045
   

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    RegExp regex = RegExp(r'\d$');
    Match? match = regex.firstMatch(adjustmentId);
    final count = match![0];
  
  return Scaffold(
    backgroundColor: Colors.white,
    body: Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Ensure alignment starts from the left
        children: [
          SizedBox(height: 10),
          Align(
            alignment: Alignment.topLeft, // Align the content to the top left
            child: EstimatedOperatingHours(hours: estimatedOperatingHours, count: count),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: CustomLineChart(
              blueLineSpots: measurements
                  .map((measurement) => FlSpot(measurement.currentOperatingHours, measurement.Qn))
                  .toList(),
              grayLineSpots: regression ?? [],
              xAxisStart: measurements.first.currentOperatingHours,
              xAxisEnd: measurements.last.currentOperatingHours,
            ),
          ),
          SizedBox(height: 20),
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
    ),
  );
}

}

class EstimatedOperatingHours extends StatelessWidget {
  final double hours;
  final count;
  const EstimatedOperatingHours({super.key, required this.hours, required this.count});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$count - Adjustment",
          style: const TextStyle(fontSize: 23.0 , fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text(
          'Estimated Operating Hours',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 2), // Small spacing between texts
        Text(
          hours.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
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
  
  /// This red line is just an example for y = 0.9
  /// from x = 0 to x = 120. Adjust as needed.

  const CustomLineChart({
    Key? key,
    required this.blueLineSpots,
    required this.grayLineSpots,
    required this.xAxisStart,
    required this.xAxisEnd
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flSpotStart = FlSpot(xAxisStart, 0.9);
    final flSpotEnd = FlSpot(xAxisEnd + 50, 0.9);

    final List<FlSpot> redHorizontalSpots = [
      flSpotStart,
      flSpotEnd,
    ];
    
    return LineChart(
  LineChartData(
    // Adjust these min/max values dynamically
    minX: xAxisStart,
    maxX: xAxisEnd + 50,  // Extend 30 times beyond the last point
    minY: 0.8,
    maxY: 1.1,

    // Enable touch interactions
    lineTouchData: LineTouchData(enabled: true),

    // Axis Titles and Ticks
    titlesData: FlTitlesData(
      leftTitles: AxisTitles(
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
          interval: 10, // Ensure bottom titles appear at interval of 10
          getTitlesWidget: (value, meta) {
            if (value % 10 == 0) {
              return Text(value.toInt().toString(),
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
