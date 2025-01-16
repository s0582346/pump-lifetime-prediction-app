import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_controllers/pump_data_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_components/input_widget.dart';

class PumpDataWidget extends ConsumerWidget {
    const PumpDataWidget({super.key});


    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final pumpDataState = ref.watch(pumpDataProvider);
      final pumpDataNotifier = ref.read(pumpDataProvider.notifier);

      return Center( 
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20), // TODO: tabs
          InputWidget(label: 'Medium', onChanged: (value) => pumpDataNotifier.medium = value),
          InputWidget(label: 'Festoffkonzentration [%]', placeholder: 'z.B. 30%', onChanged: (value) => pumpDataNotifier.measurableParameter = value),
          InputWidget(label: 'zulässiger Gesamtverschleiß [%]', placeholder: 'z.B. 70%', onChanged: (value) => pumpDataNotifier.permissibleTotalWear = value),

          ElevatedButton(
            onPressed: () {
              pumpDataNotifier.savePumpData();
            },
            child: const Text('Save'),
          ),
        ],
        )
      );
    }

}   