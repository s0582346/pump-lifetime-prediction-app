import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const NavigationPage(),
    );
  }
}

