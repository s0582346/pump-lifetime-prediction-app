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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF007167),
        title: const Text(
          "NETZSCH",
            style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
      body: PumpFormWidget(),
    );
  }
}