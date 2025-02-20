import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/components/measurement_list_widget.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/controllers/history_controller.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Fetch measurements when the screen initializes
    Future.microtask(() => ref.read(historyControllerProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final measurementState = ref.watch(historyControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: measurementState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryColor, backgroundColor: Colors.grey)), // TODO make a custom loading widget
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (groupedMeasurements) {
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
                    return MeasurementListWidget(measurements: groupedMeasurements[id]!);
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Dispose the tab controller when the widget is removed
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
