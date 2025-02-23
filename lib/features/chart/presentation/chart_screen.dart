import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/prediction.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/chart_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/chart_widget.dart';

class ChartScreen extends ConsumerStatefulWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Load measurements & predictions
    Future.microtask(() => ref.read(chartControllerProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final chartState = ref.watch(chartControllerProvider);
    final pump = ref.watch(selectedPumpProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: chartState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
            backgroundColor: Colors.grey,
          ),
        ),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (data) {
          final groupedMeasurements = data.groupedMeasurements;
          final predictions = data.predictions;

          if (groupedMeasurements.isEmpty) {
            return const Center(
              child: Text(
                "No history available",
                style: TextStyle(fontSize: 20),
              ),
            );
          }

          // Create a TabController for as many adjustmentIds as we have
          _tabController = TabController(
            length: groupedMeasurements.length,
            vsync: this,
          );

          return Column(
            children: [
              TabBar(
                // tabAlignment is only available in newer Flutter versions;
                // remove it if you get an error.
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                indicatorColor: AppColors.primaryColor,
                labelColor: AppColors.primaryColor,
                dividerHeight: 3,
                controller: _tabController,
                tabs: groupedMeasurements.keys
                    .map((adjustmentId) => Tab(text: adjustmentId))
                    .toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: groupedMeasurements.keys.map((adjustmentId) {
                    // Find the matching Prediction for this adjustmentId
                    final predictionForTab = predictions.firstWhere(
                      (p) => p.adjusmentId == adjustmentId,
                      orElse: () => Prediction(
                        adjusmentId: adjustmentId,
                        estimatedOperatingHours: 0,
                        a: 0,
                        b: 0,
                        c: 0,
                      ),
                    );

                    // If a, b, c are non-null, generate regression spots
                    final List<FlSpot> regressionSpots;
                    if (predictionForTab.a != null &&
                        predictionForTab.b != null &&
                        predictionForTab.c != null) {
                      regressionSpots = Utils().generateQuadraticSpots(
                        predictionForTab.a!,
                        predictionForTab.b!,
                        predictionForTab.c!,
                        start: groupedMeasurements[adjustmentId]!.first.currentOperatingHours,
                        end: groupedMeasurements[adjustmentId]!.last.currentOperatingHours,
                      );
                    } else {
                      regressionSpots = [];
                    }

                    // Pass everything to your ChartWidget
                    return ChartWidget(
                      measurements: groupedMeasurements[adjustmentId]!,
                      adjustmentId: adjustmentId,
                      estimatedOperatingHours: predictionForTab.estimatedOperatingHours,
                      estimatedAdjustmentDay: predictionForTab.estimatedMaintenanceDate,
                      // Either pass the full Prediction...
                      // ... or just pass the regressionSpots if that’s all you need
                      regression: regressionSpots,
                      pump: pump!,
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
