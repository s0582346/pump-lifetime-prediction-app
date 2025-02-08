import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump_data_controller.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/input_widget.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/select_widget.dart';
import 'package:flutter_predictive_maintenance_app/components/form_components/primary_button.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump.dart';  

class PumpFormWidget extends ConsumerWidget {
  const PumpFormWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pumpDataNotifier = ref.read(pumpFormProvider.notifier);
    final pumpDataState = ref.watch(pumpFormProvider);

    return ListView(
      padding: const EdgeInsets.all(40.0),
      children: [
        SelectWidget(
          label: 'Pump Type',
          selectedValue: pumpDataState.type,
          onChanged: (value) => pumpDataNotifier.pumpType = value,
          items: const ['NM045', 'NM063', 'NM070', 'NM090', 'NM100', 'NM150'],
        ),
        InputWidget(
          label: 'Medium',
          initialValue: pumpDataState.medium,
          onChanged: (value) => pumpDataNotifier.medium = value,
        ),
        InputWidget(
          label: 'Permissible Total Wear [%]',
          placeholder: 'z.B. 70%',
          initialValue: pumpDataState.permissibleTotalWear,
          onChanged: (value) => pumpDataNotifier.permissibleTotalWear = value,
        ),
        SelectWidget(
          label: 'Measurable Parameter',
          selectedValue: pumpDataState.measurableParameter,
          onChanged: (value) => pumpDataNotifier.measurableParameter = value,
          items: const ['volume flow', 'pressure'],
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          onPressed: () async {
             final success = pumpDataNotifier.savePumpData();
             if (await success) {
              ref.invalidate(pumpsProvider);  // Invalidate the provider to trigger a rebuild
              Navigator.of(context).pop();  // Handle navigation in the widget
            }
          },
          label: 'Save',
          buttonColor: AppColors.greyColor,
        ),
      ],
    );
  }
}
