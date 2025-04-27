import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/measurable_parameter.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump_type.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/rotor_geometry.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/rotor_stages.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/time_entry.dart';
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
          validator: (isSubmitting) ? validation.nameError : null,
        ),
        SelectWidget<PumpType>(
          label: 'Pump Type',
          selectedValue: pumpDataState.type,
          onChanged: (val) => pumpDataNotifier.pumpType = val,
          items: PumpType.values,
          itemLabelBuilder: (type) => type.label,
          validator: validation.pumpTypeError,
          isSubmitting: isSubmitting,
        ),
        SelectWidget<RotorGeometry>(
          label: 'Rotor Geometry',
          selectedValue: pumpDataState.rotorGeometry,
          onChanged: (value) => pumpDataNotifier.rotorGeometry = value,
          items: RotorGeometry.values,
          itemLabelBuilder: (geometry) => geometry.label,
        ),
        SelectWidget<RotorStages>(
          label: 'Number of Stages',
          selectedValue: pumpDataState.numberOfStages,
          onChanged: (value) => pumpDataNotifier.numberOfStages = value,
          items: RotorStages.values,
          itemLabelBuilder: (stages) => stages.label,
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
          validator: validation.solidConcentrationError,
        ),
        InputWidget(
          label: 'Permissible Total Wear [%]',
          placeholder: 'z.B. 70%',
          initialValue: pumpDataState.permissibleTotalWear,
          onChanged: (value) => pumpDataNotifier.permissibleTotalWear = value,
          validator: (isSubmitting) ? validation.persmissibleTotalWearError : null,
          keyboardType: TextInputType.number,
        ),
        SelectWidget<MeasurableParameter>(
          label: 'Measurable Parameter',
          selectedValue: pumpDataState.measurableParameter,
          onChanged: (value) => pumpDataNotifier.measurableParameter = value,
          items: MeasurableParameter.values,
          itemLabelBuilder: (flow) => flow.label,
          validator: validation.measurableParameterError,
          isSubmitting: isSubmitting,
        ),
        SelectWidget<TimeEntry>(
          label: 'Type of Time Entry',
          selectedValue: pumpDataState.typeOfTimeEntry,
          onChanged: (value) => pumpDataNotifier.typeOfTimeEntry = value,
          items: TimeEntry.values,
          itemLabelBuilder: (timeEntry) => timeEntry.label,
          validator: validation.typeOfTimeEntryError,
          isSubmitting: isSubmitting,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          onPressed: () {
            ref.read(isSubmittingProvider.notifier).state = true;
            final isValid = validation.isFormValid;
            pumpDataNotifier.savePumpData(context, isValid); 
          },
          label: 'Save',
          buttonColor: AppColors.greyColor,
        ),
      ],
    );
  }
}
