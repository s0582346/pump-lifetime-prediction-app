import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation_provider.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/history_screen.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/presentation/form_screen.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/chart_screen.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump.dart';
import 'package:flutter_predictive_maintenance_app/navigation/custom_bottom_navigation_bar_item.dart';
import 'package:flutter_predictive_maintenance_app/navigation/custom_app_bar.dart';


/* 
  This acts like a global state container 
  Any widget in your app tree can access it by watching or reading it
*/
final selectedPumpProvider = StateProvider<Pump?>((ref) => null);


/* 
  Navigation widget is used to display the screens based on the index of the bottom navigation bar
  It uses IndexedStack to maintain the state of the screen
  It uses CustomAppBar to display the app bar
  It uses CustomBottomNavigationBarItem to display the bottom navigation bar items
*/
class Navigation extends ConsumerStatefulWidget {
  final Pump selectedPump;
  
  const Navigation({
    super.key,
    required this.selectedPump
  });

  @override
  ConsumerState<Navigation> createState() => _NavigationState();
}

class _NavigationState extends ConsumerState<Navigation> {
  @override
  void initState() {
    super.initState();
    // Update the provider after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedPumpProvider.notifier).state = widget.selectedPump;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavigationProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'NETZSCH'),
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