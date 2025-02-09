import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/history/presentation/components/measurements_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MeasurementsWidget();
  }
}