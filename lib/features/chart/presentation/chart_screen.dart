import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/prediction/prediction.dart';
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
    // Refresh chart data after the first build.
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

          // If no adjustments are available, show a message.
          if (adjustments.isEmpty) {
            return const Center(child: Text("No adjustments available."));
          }

          // Initialize or update the tab controller based on adjustments.
          _initializeTabControllerIfNeeded(adjustments);

          return OrientationBuilder(
            builder: (context, orientation) {
              final isPortrait = orientation == Orientation.portrait;
              return Column(
                children: [
                  // Only show the TabBar in portrait mode.
                  if (isPortrait)
                    TabBar(
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      indicatorColor: AppColors.primaryColor,
                      dividerHeight: 3,
                      labelColor: AppColors.primaryColor,
                      controller: _tabController,
                      tabs: adjustments
                          .map((a) => Tab(text: Utils().formatTabLabel(a.id)))
                          .toList(),
                    ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: adjustments.map((adjustment) {
                        final predictionForTab = predictions.firstWhere(
                          (p) => p.adjusmentId == adjustment.id,
                          orElse: () => Prediction(
                            adjusmentId: adjustment.id,
                            estimatedOperatingHours: 0,
                            a: 0.0,
                            b: 0.0,
                            c: 0.0,
                          ),
                        );

                        final regressionSpots = _calculateRegressionSpots(
                          predictionForTab,
                          groupedMeasurements[adjustment.id] ?? [],
                        );

                        return ChartWidget(
                          measurements: groupedMeasurements[adjustment.id] ?? [],
                          adjustment: adjustment,
                          prediction: predictionForTab,
                          regression: regressionSpots,
                          pump: pump!,
                          isLast: adjustment.id == adjustments.last.id,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _initializeTabControllerIfNeeded(List adjustments) {
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
  }

  List<FlSpot> _calculateRegressionSpots(Prediction prediction, List measurements) {
    if (prediction.a == 0 && prediction.b == 0 && prediction.c == 0) {
      return [];
    }
    if (measurements.isEmpty) return [];
    final xOffset = measurements.first.currentOperatingHours.toDouble();
    return Utils().generateQuadraticSpots(
      prediction.a!,
      prediction.b!,
      prediction.c!,
      start: xOffset,
      end: measurements.last.currentOperatingHours.toDouble(),
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
