import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


// Source: ChatGPT: ChatGPT o4, 22-03-2025
// Prompt: I need to build a custom line chart widget with flutter which works with Riverpod. 
// This chart needs to be built as a component since ill be reusing it depending on how many tabs there are. 
// This means each chart will have different outputs and it should retains its state when the user navigates to other widgets. 
// It should receive a list which contains the points to be plotted. It should be required.
class CustomLineChart extends StatelessWidget {
  final double xAxisStart;
  final double xAxisEnd;
  final double yIntercept;
  final List<FlSpot> blueLineSpots;
  final List<FlSpot> grayLineSpots;
  final maxY = 1.1;
  final yInterval = 0.05;

  const CustomLineChart({
    super.key,
    required this.blueLineSpots,
    required this.grayLineSpots,
    required this.xAxisStart,
    required this.xAxisEnd,
    this.yIntercept = 0,
  });

  @override
  Widget build(BuildContext context) {

    const double yAxisStart = 0.8;

    // calculate actual min value based on the blue line spots
    final double actualMin = blueLineSpots
    .map((spot) => spot.y)
    .reduce((a, b) => a < b ? a : b);

    final double minY = (actualMin < yAxisStart)
    ? (yAxisStart - 0.1) : yAxisStart;


    List<FlSpot> yInterceptLine = [const FlSpot(0, 0)];
    if (yIntercept != 0) {
      yInterceptLine = [
        // subtract the x-axis start from the y-intercept to get the correct x value
        FlSpot(yIntercept - xAxisStart, 0.9), 
        FlSpot(yIntercept - xAxisStart, minY),
      ];
    }
    
    final difference = (xAxisEnd - xAxisStart).toInt();
    final double interval = (difference > 180) ? 50 : (difference > 100) ? 20 : (difference > 50) ? 10 : 5;
    final double adjustedMaxX = (difference < 10) ? 20 : (difference < 30) ? 30 : difference + 10; // some margin depending on the range

    final List<FlSpot> threshold = [
      const FlSpot(0, 0.9),
      FlSpot(adjustedMaxX, 0.9),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: adjustedMaxX,
        minY: minY,
        maxY: maxY,
        lineTouchData: const LineTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, 
              interval: yInterval,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                );
              }
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              getTitlesWidget: (value, meta) {
                if (value % interval == 0) {
                  final originalValue = value + xAxisStart;
                  return Text(
                    originalValue.toInt().toString(),
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  );
                }
                return Container(); // Hide non-matching values
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        gridData: FlGridData(show: true, drawVerticalLine: false, drawHorizontalLine: true, horizontalInterval: yInterval),
        
        // Borders
        borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.grey, width: 1,),
          left: BorderSide(color: Colors.grey, width: 1),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
          ),
        ),

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

          // Threshold Line Data
          LineChartBarData(
            spots: threshold, 
            isCurved: false, 
            color: Colors.amber, 
            barWidth: 2, 
            dashArray: [5, 5]
          ),

          // Y-Intercept Line Data
          LineChartBarData(
            spots: yInterceptLine, 
            isCurved: false,
            color: Colors.black,
            barWidth: 2,
            dashArray: [5, 5],
          )
        ],
        
      ),
    );
  }
}
