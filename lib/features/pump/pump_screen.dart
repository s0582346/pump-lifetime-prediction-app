// pump_data_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/navigation/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump_form_widget.dart';

/// A simple page that hosts PumpDataWidget inside a Scaffold.
class PumpScreen extends ConsumerWidget {
  const PumpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'NETZSCH'),
      body: PumpFormWidget(),
    );
  }
}