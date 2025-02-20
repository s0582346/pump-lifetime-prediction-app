import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';


class ChartWidget extends ConsumerWidget {
  final List<Measurement> measurements;
  final List<FlSpot>? regression;
  final String adjustmentId;

  const ChartWidget({super.key, required this.measurements, required this.adjustmentId, this.regression});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the list of data points from the provider
    
    // adjustmentId = NM045
    RegExp regex = RegExp(r'\d$');
    Match? match = regex.firstMatch(adjustmentId);
    final count = match![0];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("$count - Adjustment",
          style: const TextStyle(fontSize: 20.0 , fontWeight: FontWeight.bold)),
      ),

      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: CustomLineChart(
                blueLineSpots: measurements.map((measurement) => FlSpot(measurement.currentOperatingHours, measurement.Qn)).toList(),
                grayLineSpots: regression ?? [],
                // If you want custom axis titles/ranges, you can pass them here:
                //xAxisTitle: "Betriebsstunden [h]",
                //yAxisTitle: "Q/n norm [-]",
                //minX: 103,
                //maxX: 128,
                //minY: 0.7,
                //maxY: 1.1,
              ),
            ),
          ],
        ),
      )
      ,
    );
  }
}


class CustomLineChart extends StatelessWidget {
  final List<FlSpot> blueLineSpots;
  final List<FlSpot> grayLineSpots;
  
  /// This red line is just an example for y = 0.9
  /// from x = 0 to x = 120. Adjust as needed.
  final List<FlSpot> redHorizontalSpots = const [
    FlSpot(0, 0.9),
    FlSpot(120, 0.9),
  ];

  const CustomLineChart({
    Key? key,
    required this.blueLineSpots,
    required this.grayLineSpots,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        // Adjust these min/max values to match your data range
        minX: 0,
        maxX: 160,
        minY: 0.8,
        maxY: 1.1,
        // Optional: enable touch/tooltip
        lineTouchData: LineTouchData(
          enabled: true,
        ),
        // Axis Titles and Ticks
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: 0.05, // or 0.1, depending on your needed density
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 20, // for labels every 20 hours, for example
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          verticalInterval: 20,
          horizontalInterval: 0.05,
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          // 1) Blue line (with diamond-like markers)
          LineChartBarData(
            spots: blueLineSpots,
            isCurved: false, 
            color: Colors.blue,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) {
                // Make your dot diamond-shaped
                return FlDotCirclePainter(
                  radius: 1, // Adjust size to your preference
                  color: Colors.blue,
                  strokeColor: Colors.white,
                  strokeWidth: 1,
                );
              },
            ),
          ),

          // 2) Gray line (smooth curve, no dots)
          LineChartBarData(
            spots: grayLineSpots,
            isCurved: true,
            color: Colors.grey,
            barWidth: 2,
            dotData: FlDotData(show: false),
          ),

          // 3) Red dashed horizontal line at y=0.9
          LineChartBarData(
            spots: redHorizontalSpots,
            isCurved: false,
            color: Colors.red,
            barWidth: 2,
            dashArray: [5, 5], // Make the line dashed
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) {
                // Red diamonds at the endpoints
                return FlDotCirclePainter(
                  radius: 1,
                  color: Colors.red,
                  strokeColor: Colors.red,
                  strokeWidth: 2,
                );
              },
            ),
          ),

          // If you wanted the vertical red line from x=120 to some lower y:
          // just add another LineChartBarData with two spots, e.g.,
          // (120, 0.9) -> (120, 0.85), dashArray = [5,5], etc.
          // Omit since you said you don't need the vertical line.
        ],
      ),
    );
  }
}
