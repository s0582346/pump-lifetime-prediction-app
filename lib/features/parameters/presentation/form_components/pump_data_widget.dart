import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_controllers/pump_data_controller.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_components/input_widget.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_components/select_widget.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_components/primary_button.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';  

class PumpDataWidget extends ConsumerWidget {
  const PumpDataWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pumpDataNotifier = ref.read(pumpDataProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(40.0),
      children: [
        SelectWidget(
          label: 'Pumpentyp',
          onChanged: (value) => pumpDataNotifier.pumpType = value,
          items: ['a', 'b', 'c'],
        ),
        InputWidget(
          label: 'Medium',
          onChanged: (value) => pumpDataNotifier.medium = value,
        ),
        InputWidget(
          label: 'zulässiger Gesamtverschleiß [%]',
          placeholder: 'z.B. 70%',
          onChanged: (value) => pumpDataNotifier.permissibleTotalWear = value,
        ),
        SelectWidget(
          label: 'Messbarer Parameter',
          onChanged: (value) => pumpDataNotifier.measurableParameter = value,
          items: ['Volumenstrom', 'Druck'],
        ),
        PrimaryButton(
          onPressed: () => pumpDataNotifier.savePumpData(),
          label: 'Speichern',
          buttonColor: AppColors.greyColor,
        ),
      ],
    );
  }
}
