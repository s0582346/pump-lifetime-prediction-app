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
    this.yIntercept = 0, // TODO make it dinamically, this should not always start at 0
  });

  @override
  Widget build(BuildContext context) {
    
    final List<FlSpot> threshold = [
      FlSpot(xAxisStart, 0.9),
      FlSpot(xAxisEnd + 40, 0.9),
    ];

    List<FlSpot> yInterceptLine = [const FlSpot(0, 0)];
    if (yIntercept != 0) {
      yInterceptLine = [
      FlSpot(yIntercept, 0.9),
      FlSpot(yIntercept, 0.8),
    ];
    }

    return LineChart(
      LineChartData(
        minX: xAxisStart,
        maxX: xAxisEnd + 40,
        minY: 0.8,
        maxY: 1.1,
        lineTouchData: const LineTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, 
              interval: 0.05,
              ),
          ),
           bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              getTitlesWidget: (value, meta) {
                if (value % 20 == 0) {
                  return Text(value.toInt().toStringAsFixed(1),
                    style: TextStyle(fontSize: 15, color: Colors.black),);
                }
                return Container(); // Hide non-matching values
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        gridData: const FlGridData(show: true, drawVerticalLine: false, drawHorizontalLine: true, verticalInterval: 10, horizontalInterval: 0.05),
        
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


          //LineChartBarData(spots: redHorizontalSpots, isCurved: false, color: Colors.red, barWidth: 2, dashArray: [5, 5]),
          LineChartBarData(
            spots: threshold, 
            isCurved: false, 
            color: Colors.red, 
            barWidth: 2, 
            dashArray: [5, 5]
          ),

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
