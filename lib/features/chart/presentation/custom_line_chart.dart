import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';

class CustomLineChart extends StatelessWidget {
  final double xAxisStart;
  final double xAxisEnd;
  final double yIntercept;
  final List<FlSpot> blueLineSpots;
  final List<FlSpot> grayLineSpots;

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
    List<FlSpot> yInterceptLine = [const FlSpot(0, 0)];
    if (yIntercept != 0) {
      yInterceptLine = [
        // subtract the x-axis start from the y-intercept to get the correct x value
        FlSpot(yIntercept - xAxisStart, 0.9), 
        FlSpot(yIntercept - xAxisStart, 0.8),
      ];
    }
    
    final double interval = ((xAxisEnd - xAxisStart) > 100) ? 20 : 10;
    final double adjustedMaxX = ((xAxisEnd - xAxisStart) < 50 ? 50 : (xAxisEnd - xAxisStart) + 10);

    final List<FlSpot> threshold = [
      const FlSpot(0, 0.9),
      FlSpot(adjustedMaxX, 0.9),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: adjustedMaxX,
        minY: 0.8,
        maxY: 1.1,
        lineTouchData: const LineTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, 
              interval: 0.05,
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

        gridData: const FlGridData(show: true, drawVerticalLine: false, drawHorizontalLine: true, horizontalInterval: 0.05),
        
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
            color: Colors.red, 
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
