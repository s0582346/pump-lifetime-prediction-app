import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/prediction/prediction.dart';


// Source: ChatGPT: ChatGPT o4, 22-03-2025
// Prompt: I need to build a custom line chart widget with flutter which works with Riverpod. 
// This chart needs to be built as a component since ill be reusing it depending on how many tabs there are. 
// This means each chart will have different outputs and it should retains its state when the user navigates to other widgets. 
// It should receive a list which contains the points to be plotted. It should be required.
class SumLineChart extends StatelessWidget {
  final double xAxisStart;
  final double xAxisEnd;
  final double yIntercept;
  final List<FlSpot> blueLineSpots;
  final List<FlSpot> grayLineSpots;
  final List<Adjustment> adjustments;
  final List<Prediction>? predictions;
  final minY;
  final maxY;
  final yInterval;

  const SumLineChart({
    super.key,
    required this.blueLineSpots,
    required this.grayLineSpots,
    required this.xAxisStart,
    required this.xAxisEnd,
    required this.adjustments,
    this.predictions,
    this.yIntercept = 0,
    this.minY = 0.8,
    this.maxY = 1.1,
    this.yInterval = 0.05,
  });

  @override
  Widget build(BuildContext context) { 
    final difference = (xAxisEnd - xAxisStart).toInt();
    final double interval = (difference > 180) ? 50 : (difference > 100) ? 20 : (difference > 50) ? 10 : 5;
    final double adjustedMaxX = (difference < 10) ? 20 : (difference < 30) ? 30 : difference + 10; // some margin depending on the range

    final List<LineChartBarData> thresholdLines = _generateThresholdLines(adjustmentCount: adjustments.length, adjustedMaxX: adjustedMaxX);
    final List<LineChartBarData> predictionLines = _generatePredictionLines(predictions: predictions, adjustments: adjustments,  xAxisStart: xAxisStart, minY: minY);

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
          ...thresholdLines,

          // Y-Intercept Line Data
          ...predictionLines,
        ],
        
      ),
    );
  }

  List<LineChartBarData> _generateThresholdLines({
    required int adjustmentCount,
    required double adjustedMaxX,
    double startY = 0.9,
    double step = 0.1,
    int maxLines = 10,
  }) {
  final List<LineChartBarData> thresholdLines = [];

  for (int i = 0; i <= adjustmentCount - 1 && i < maxLines; i++) {
    final double y = startY - (i * step);
    final List<FlSpot> threshold = [
      FlSpot(0, y),
      FlSpot(adjustedMaxX, y),
    ];

    thresholdLines.add(
      LineChartBarData(
        spots: threshold,
        isCurved: false,
        color: Colors.amber,
        barWidth: 2,
        dashArray: [5, 5],
      ),
    );
    }

  return thresholdLines;
  }

  List<LineChartBarData> _generatePredictionLines({
    List<Prediction>? predictions,
    required List<Adjustment> adjustments,
    double xAxisStart = 0,
    double minY = 0.3
  }) {
    double limit = 0.9;
    final List<LineChartBarData> predictionLines = [];

    if (predictions == null) return predictionLines;

    for (var a in adjustments) {
      if (a.status == 'open') continue; 

      // Find prediction for the current adjustment
      final prediction = predictions.firstWhere(
        (p) => p.adjusmentId == a.id,
        orElse: () => Prediction(),
      );
    
      final estimatedOperatingHours = prediction.estimatedOperatingHours;
      
      final List<FlSpot> predictionLine = [
        FlSpot(estimatedOperatingHours ?? 0, limit),
        FlSpot(estimatedOperatingHours ?? 0, minY),
      ];

      predictionLines.add(
        LineChartBarData(
          spots: predictionLine,
          isCurved: false,
          color: estimatedOperatingHours != null ? Colors.amber : Colors.transparent,
          barWidth: 2,
          dashArray: [5, 5],
        ),
      );

      limit = double.parse((limit - 0.1).toStringAsFixed(2));
    }

    return predictionLines;
  }
}
