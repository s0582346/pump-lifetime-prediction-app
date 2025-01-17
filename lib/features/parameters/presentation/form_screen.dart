import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_components/pump_data_widget.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/presentation/form_components/measurement_data_widget.dart';
class FormScreen extends ConsumerWidget {
  const FormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      child: PumpDataWidget(),
      //child: MeasurementDataWidget(),
    );
  }
}