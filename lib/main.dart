  import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_predictive_maintenance_app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that the Flutter app initializes properly
  await DatabaseHelper().database;
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}