import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/prediction.dart';
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(chartControllerProvider.notifier).refresh());
  } 


  @override
  Widget build(BuildContext context) {
    final chartState = ref.watch(chartControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: chartState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryColor, backgroundColor: Colors.grey)),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (data) {
          final groupedMeasurements = data.groupedMeasurements;
          List<Prediction>? predictions = data.predictions;
          List<FlSpot> regression =  Utils().generateQuadraticSpots(predictions[0].a!, predictions[0].b!, predictions[0].c!);
                

          if (groupedMeasurements.isEmpty) {
            return const Center(child: Text("No history available", style: TextStyle(fontSize: 20)));
          }

          _tabController = TabController(length: groupedMeasurements.length, vsync: this);

          return Column(
            children: [
              TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                indicatorColor: AppColors.primaryColor,
                labelColor: AppColors.primaryColor,
                dividerHeight: 3,
                controller: _tabController,
                tabs: groupedMeasurements.keys.map((id) => Tab(text: id)).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: groupedMeasurements.keys.map((id) {
                    return ChartWidget(measurements: groupedMeasurements[id]!, adjustmentId: id);
                  }).toList(),
                ),
              ),
            ],
          );
        }
      )
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}