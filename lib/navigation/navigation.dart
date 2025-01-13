import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation_provider.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/history_screen.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_screen.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/chart_screen.dart';
import 'package:flutter_predictive_maintenance_app/navigation/custom_bottom_navigation_bar_item.dart';
import 'package:flutter_predictive_maintenance_app/navigation/custom_app_bar.dart';

class NavigationPage extends ConsumerWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavigationProvider); // watch the state of the bottomNavigationProvider

    return Scaffold(
      appBar: const CustomAppBar(),
      body: IndexedStack( // IndexedStack is used to display the screen based on the index / it maintains the state of the screen
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
          ref.read(bottomNavigationProvider.notifier).state = index; // update the state of the bottomNavigationProvider
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