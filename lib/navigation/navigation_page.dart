import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation_provider.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/history_screen.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_screen.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/chart_screen.dart';
import 'package:flutter_predictive_maintenance_app/navigation/custom_bottom_navigation_bar_item.dart';

class NavigationPage extends ConsumerWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavigationProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF007167),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HistoryScreen(),
          ChartScreen(),
          FormScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(bottomNavigationProvider.notifier).state = index;
        },
        items: [
          CustomBottomNavigationBarItem(assetPath: 'assets/nav/database.png'),
          CustomBottomNavigationBarItem(assetPath: 'assets/nav/chart.png'),
          CustomBottomNavigationBarItem(assetPath: 'assets/nav/form.png'),
        ],
      ),
    );
  }
}