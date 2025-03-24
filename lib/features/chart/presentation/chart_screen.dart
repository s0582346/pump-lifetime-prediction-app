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
  const ChartScreen({super.key});

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
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
          final adjustments = data.adjustments;
          final groupedMeasurements = data.groupedMeasurements;
          final predictions = data.predictions;

          // If no adjustments are available, show a message
          if (adjustments.isEmpty) {
            return const Center(child: Text("No adjustments available."));
          }

          // Set the initial tab index to adjustments.length - 1
          final newIndex = adjustments.length - 1;
          if (_tabController == null || _tabController!.length != adjustments.length) {
            _currentTabIndex = newIndex;
            _tabController?.removeListener(_onTabChanged);
            _tabController = TabController(
              length: adjustments.length,
              vsync: this,
              initialIndex: _currentTabIndex,
            )..addListener(_onTabChanged);
          }

          return Column(
            children: [
              TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                indicatorColor: AppColors.primaryColor,
                dividerHeight: 3,
                labelColor: AppColors.primaryColor,
                controller: _tabController,
                tabs: adjustments.map((a) => Tab(text: Utils().formatTabLabel(a.id))).toList(),
              ),

              // Display the chart for each adjustment
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: adjustments.map((a) {
                    final adjustmentId = a.id;

                    // Get the prediction for the current tab
                    final predictionForTab = predictions.firstWhere(
                      (p) => p.adjusmentId == adjustmentId,
                      orElse: () => Prediction(
                        adjusmentId: adjustmentId,
                        estimatedOperatingHours: 0,
                        a: 0.0,
                        b: 0.0,
                        c: 0.0,
                      ),
                    );

                    List<FlSpot> regressionSpots = [];
                    if (predictionForTab.a != 0 || predictionForTab.b != 0 || predictionForTab.c != 0) {
                      final measurementList = groupedMeasurements[adjustmentId] ?? [];
                      if (measurementList.isNotEmpty) {
                        final xOffset = measurementList.first.currentOperatingHours.toDouble() ?? 0.0;

                        regressionSpots = Utils().generateQuadraticSpots(
                          predictionForTab.a!,
                          predictionForTab.b!,
                          predictionForTab.c!,
                          start: xOffset,
                          end: measurementList.last.currentOperatingHours.toDouble(),
                        );
                      }
                    }
                   
                    return ChartWidget(
                      measurements: groupedMeasurements[adjustmentId] ?? [],
                      adjustment: a,
                      prediction: predictionForTab,
                      regression: regressionSpots,
                      pump: pump!,
                      isLast: a.id == adjustments.last.id,
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

  void _onTabChanged() {
    setState(() {
      _currentTabIndex = _tabController!.index;
    });
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }
}
