import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/chart_widget.dart';
import 'package:flutter_predictive_maintenance_app/features/dashboard/dashboard_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/dashboard/dashboard_widget.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardControllerProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final pump = ref.watch(selectedPumpProvider);

  return Scaffold(
  backgroundColor: Colors.white,
  body: SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: dashboardState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
          backgroundColor: Colors.grey,
        ),
      ),
      error: (e, _) => Center(child: Text("Error: $e")),
      data: (data) {
        final measurements = data.measurements;
        final prediction = data.prediction;

        List<FlSpot> regressionSpots = [];
        if (prediction?.a != null && measurements!.isNotEmpty) {
          //final xOffset = measurements.first.currentOperatingHours.toDouble() ?? 0.0;

          regressionSpots = Utils().generateQuadraticSpots(
            prediction?.a,
            prediction?.b,
            prediction?.c,
            start: measurements.first.currentOperatingHours.toDouble() ?? 0.0,
            end: measurements.last.currentOperatingHours.toDouble() + 10,
            targetY: 0.0,
          );
        }

        return DashboardWidget(
          measurements: measurements,
          prediction: prediction,
          regression: regressionSpots,
          pump: pump!,
        );
      },
    ),
  ),
);
  }
}