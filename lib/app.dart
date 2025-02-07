import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/initial_screen.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump_form_widget.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: InitialScreen(),
      //home: Navigation(),
    );
  }
}

