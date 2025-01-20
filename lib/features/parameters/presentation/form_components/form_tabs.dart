import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FormTabs extends ConsumerWidget {
  const FormTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FormTab currentTab = ref.watch(currentTabProvider);

    void selectTab(FormTab tab) {
      ref.read(currentTabProvider.notifier).state = tab;
    }

    return Container(
      color: const Color.fromARGB(255, 230, 229, 229), // Light grey background to match your screenshot
      child: Row(
        children: [
          // === Left Tab (Pumpendaten) ===
          Expanded(
            child: InkWell(
              onTap: () => selectTab(FormTab.pumpData),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Pumpendaten',
                    style: TextStyle(
                      color: Colors.grey,  // for unselected text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Underline indicator
                  Container(
                    height: 3,
                    width: 150,
                    decoration: BoxDecoration(
                      // Only display the color if the current tab is selected
                      color: currentTab == FormTab.pumpData ? AppColors.primaryColor : Colors.transparent,
                      boxShadow: [
                      // Give it a subtle shadow
                        BoxShadow(
                          color: (currentTab == FormTab.pumpData) ? AppColors.primaryColor : Colors.transparent,  // Shadow color
                          blurRadius: 2,                // How soft the shadow should be
                          offset: const Offset(0, 2),   // X,Y offset of the shadow
                        )
                      ],
                    ),    
                  ),
                ],
              ),
            ),
          ),

          // Vertical Divider
          Container(
            width: 1,
            height: 30,
            color: Colors.grey,
          ),

          // === Right Tab (Messwerte) ===
          Expanded(
            child: InkWell(
              onTap: () => selectTab(FormTab.measurement),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Messwerte',
                    style: TextStyle(
                      color: currentTab == FormTab.measurement
                          ? AppColors.primaryColor
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Underline indicator
                  Container(
                    height: 3,
                    width: 150,
                    decoration: BoxDecoration(
                      // Only display the color if the current tab is selected
                      color: currentTab == FormTab.measurement ? AppColors.primaryColor : Colors.transparent,
                      boxShadow: [
                      // Give it a subtle shadow
                        BoxShadow(
                          color: (currentTab == FormTab.measurement) ? AppColors.primaryColor : Colors.transparent,  // Shadow color
                          blurRadius: 2,                // How soft the shadow should be
                          offset: const Offset(0, 2),   // X,Y offset of the shadow
                        )
                      ],
                    ),    
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


final currentTabProvider = StateProvider<FormTab>((ref) => FormTab.pumpData);

enum FormTab {
  pumpData,
  measurement,
}