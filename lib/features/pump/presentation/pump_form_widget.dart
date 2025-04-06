import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/presentation/pump_controller.dart';
import 'package:flutter_predictive_maintenance_app/shared/components/input_widget.dart';
import 'package:flutter_predictive_maintenance_app/shared/components/select_widget.dart';
import 'package:flutter_predictive_maintenance_app/shared/components/primary_button.dart';
import 'package:flutter_predictive_maintenance_app/constants/app_colors.dart';

class PumpFormWidget extends ConsumerWidget {
  const PumpFormWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pumpDataNotifier = ref.read(pumpFormProvider.notifier);
    final pumpDataState = ref.watch(pumpFormProvider);
    final validation = ref.watch(pumpValidationProvider);
    final isSubmitting = ref.watch(isSubmittingProvider);

    return ListView(
      padding: const EdgeInsets.all(40.0),
      children: [
        InputWidget(
          label: 'Name',
          initialValue: pumpDataState.name,
          onChanged: (value) => pumpDataNotifier.name = value,
          keyboardType: TextInputType.text,
          validator: validation.nameError,
          isSubmitting: isSubmitting,
        ),
        SelectWidget(
          label: 'Pump Type',
          selectedValue: pumpDataState.type,
          onChanged: (value) => pumpDataNotifier.pumpType = value,
          items: const ['NM045', 'NM063', 'NM070', 'NM090', 'NM100', 'NM150'],
          validator: validation.pumpTypeError,
          isSubmitting: isSubmitting,
        ),
        SelectWidget(
          label: 'Rotor Geometry',
          selectedValue: pumpDataState.rotorGeometry,
          onChanged: (value) => pumpDataNotifier.rotorGeometry = value,
          items: const ['S', 'L', 'D', 'P'],
        ),
        SelectWidget(
          label: 'Number of Stages',
          selectedValue: pumpDataState.numberOfStages,
          onChanged: (value) => pumpDataNotifier.numberOfStages = value,
          items: const ['1', '2'],
        ),
        InputWidget(
          label: 'Medium',
          initialValue: pumpDataState.medium,
          onChanged: (value) => pumpDataNotifier.medium = value,
          keyboardType: TextInputType.text,
        ),
         InputWidget(
          label: 'Solid Concentration [%]',
          placeholder: 'z.B. 30%',
          initialValue: pumpDataState.solidConcentration,
          onChanged: (value) => pumpDataNotifier.solidConcentration = value,
          keyboardType: TextInputType.number,
        ),
        InputWidget(
          label: 'Permissible Total Wear [%]',
          placeholder: 'z.B. 70%',
          initialValue: pumpDataState.permissibleTotalWear,
          onChanged: (value) => pumpDataNotifier.permissibleTotalWear = value,
          validator: validation.persmissibleTotalWearError,
          isSubmitting: isSubmitting,
          keyboardType: TextInputType.number,
        ),
        SelectWidget(
          label: 'Measurable Parameter',
          selectedValue: pumpDataState.measurableParameter,
          onChanged: (value) => pumpDataNotifier.measurableParameter = value,
          items: const ['volume flow', 'pressure'],
          validator: validation.measurableParameterError,
          isSubmitting: isSubmitting,
        ),
        SelectWidget(
          label: 'Type of Time Entry',
          selectedValue: pumpDataState.typeOfTimeEntry,
          onChanged: (value) => pumpDataNotifier.typeOfTimeEntry = value,
          items: const ['operating time (absolute)', 'operating time (relative)', 'average operating time per day'],
          validator: validation.typeOfTimeEntryError,
          isSubmitting: isSubmitting,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          onPressed: () async {
            ref.read(isSubmittingProvider.notifier).state = true;
            final success = ref.read(pumpValidationProvider);

            if (context.mounted && success.isFormValid) {
                Navigator.of(context).pop();
                await pumpDataNotifier.savePumpData();
                ref.invalidate(pumpsProvider);  // Invalidate the provider to trigger a rebuild
                ref.read(isSubmittingProvider.notifier).state = false;
            }
          },
          label: 'Save',
          buttonColor: AppColors.greyColor,
        ),
      ],
    );
  }
}
