import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/dashboard/dashboard_screen.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/presentation/initial_screen.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation_provider.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/history_screen.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/chart_screen.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
import 'package:flutter_predictive_maintenance_app/navigation/custom_bottom_navigation_bar_item.dart';
import 'package:flutter_predictive_maintenance_app/navigation/custom_app_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

/// This acts like a global state container <br/>
/// Any widget in the app tree can access it by watching or reading it
final selectedPumpProvider = StateProvider<Pump?>((ref) => null);

/// Navigation widget is used to display the screens based on the index of the bottom navigation bar <br/>
/// It uses IndexedStack to maintain the state of the screen <br/>
/// It uses CustomAppBar to display the app bar <br/>
/// It uses CustomBottomNavigationBarItem to display the bottom navigation bar items 
class Navigation extends ConsumerStatefulWidget {
  final Pump selectedPump;
  
  const Navigation({
    super.key,
    required this.selectedPump,
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
    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        // Show app bar unless we are in landscape and the current index is 2.
        final showAppBar = isPortrait || currentIndex != 2;
        return Scaffold(
          appBar: showAppBar ? const CustomAppBar(title: 'NETZSCH') : null,
          endDrawer: Drawer(
            backgroundColor: AppColors.greyColor,
            width: 225,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox( 
                  height: 135,                    
                  child: DrawerHeader(
                  decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                ),
                child: Text(''),
                ),
                ),
              ListTile(
               title: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Switch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8), // spacing between text and icon
                  Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const InitialScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },            
              ),
            ListTile(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'How To Use',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8), // spacing between text and icon
                  Icon(
                    Icons.info,
                    color: Colors.white,
                  ),
                ],
              ),
              onTap: () => openAssetPDF(
                'assets/anleitung_app_standzeitbestimmung.pdf', 
                'anleitung_app_standzeitbestimmung.pdf',
              ),
            ),
            ListTile(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Help',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8), // spacing between text and icon
                  Icon(
                    Icons.help,
                    color: Colors.white,
                  ),
                ],
              ),
              onTap: () => launchUrlString('https://pumps-systems.netzsch.com/en-US/forms/contact-page'),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: IndexedStack(
            index: currentIndex,
            children: const [
              HistoryScreen(),
              DashboardScreen(),
              ChartScreen(),
            ],
          ),
          bottomNavigationBar: showAppBar ? BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: currentIndex,
            onTap: (index) {
              ref.read(bottomNavigationProvider.notifier).state = index;
            },
            items: [
              CustomBottomNavigationBarItem(assetPath: 'assets/nav/form.png'),
              CustomBottomNavigationBarItem(assetPath: 'assets/nav/netzsch.png'),
              CustomBottomNavigationBarItem(assetPath: 'assets/nav/chart.png'),
            ],
          ) : null,
        );
      },
    );
  }

  Future<void> openAssetPDF(String assetPath, String filename) async {
  try {
    // Load asset
    final byteData = await rootBundle.load(assetPath);

    // Get temp directory
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');

    // Write to temp file
    await file.writeAsBytes(byteData.buffer.asUint8List());

    // Open with default PDF viewer
    await OpenFile.open(file.path);
  } catch (e, stackTrace) {
    Utils().logError(e, stackTrace);
  }
  }
  
}
