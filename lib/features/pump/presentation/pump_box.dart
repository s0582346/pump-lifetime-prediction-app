import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/presentation/pump_controller.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';
import 'package:flutter_predictive_maintenance_app/shared/widgets/settings_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PumpBox extends ConsumerWidget {
  final Pump pump;

  const PumpBox({super.key, required this.pump});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => Navigation(selectedPump: pump), // pass the selected pump to the Navigation widget
          ),
          (route) => false, // remove all the routes from the stack
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pump.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SettingsWidget(options: [
                  SettingsOption(
                    label: 'Delete',
                    onTap: () {
                      ref.read(pumpFormProvider.notifier).deletePump(pump.id);
                      if (context.mounted) {
                        ref.invalidate(pumpsProvider);
                      }                    
                    },
                  ),
                ]),
              ],
            ),

            Row(
              children: [
                const Text('Pump Type: ', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(pump.type)
              ],
            ),

            Row(
              children: [
                const Text('Measurable Parameter: ', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(pump.measurableParameter)
              ],
            ),
            Row(
              children: [
                const Text('Permissible Total Wear: ', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text("${pump.permissibleTotalWear.toStringAsFixed(0)} %")
              ],
            ),
            
            Row(
              children: [
                const Text('Type Of Time Entry: ', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(pump.typeOfTimeEntry.replaceAll('per day', '')),
              ],
            ),

            (pump.medium ?? false) ?
              Row(
                children: [
                  const Text('Medium: ', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text(pump.medium)
                ],
              ) : Container(),
          ],
        ),
      ),
    );
  }
}