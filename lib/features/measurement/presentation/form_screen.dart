import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/presentation/measurement_data_widget.dart';


class FormScreen extends ConsumerWidget {
  const FormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final FormTab currentTab = ref.watch(currentTabProvider);
    //final pumpDataState = ref.watch(pumpDataProvider);

    return const Scaffold(
      backgroundColor: Colors.white,
      body: MeasurementDataWidget(),
    ); 
  	
    /*
    Widget buildContent() {
      switch (currentTab) {
        case FormTab.pumpData:
          return const PumpDataWidget();
        case FormTab.measurement:
          return const MeasurementDataWidget();
      }
    }

    return Column(
      children: [
        const FormTabs(),
        Expanded( // Expanded is used to take the remaining space
          child: buildContent(),
        ),
      ],
    );
    */
  }
}