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
  TabController? _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch measurements when the screen initializes
    Future.microtask(() => ref.read(historyControllerProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: historyState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryColor, backgroundColor: Colors.grey)), // TODO make a custom loading widget
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (data) {
          final groupedMeasurements = data.groupedMeasurements;
          final adjustments = data.adjustments;


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
                labelColor: AppColors.primaryColor,
                dividerHeight: 3,
                controller: _tabController,
                tabs: adjustments.map((a) => Tab(text: a.id)).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: adjustments.map((a) {
                    return MeasurementListWidget(measurements: groupedMeasurements[a.id], adjustment: a);
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  _onTabChanged() {
    setState(() {
      _currentTabIndex = _tabController!.index;
    });
  }

  /// Dispose the tab controller when the widget is removed
  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }


}
