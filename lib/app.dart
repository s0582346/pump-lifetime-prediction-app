import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/presentation/initial_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: InitialScreen(),
    );
  }
}

