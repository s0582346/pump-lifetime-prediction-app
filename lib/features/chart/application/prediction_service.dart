import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/application/adjustment_service.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/prediction.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/data/prediction_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/quadratic_fit_result.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';


final predictionServiceProvider = Provider((ref) => PredictionService());

class PredictionService {

 Future<List<Prediction>> getPredictions(Pump pump) async {
  try {
    final db = await DatabaseHelper().database;
    final predictionService = PredictionRepository(db: db);

    final predictionsMapList = await predictionService.getPredictions(pump.id);
    return predictionsMapList.map((map) => Prediction.fromMap(map)).toList();
  } catch (e, stackTrace) {
    // Log the error and return an empty list as a fallback
    print('Error fetching predictions: $e\n$stackTrace');
    return [];
  }
}

Future<void> savePrediction(String adjustmentId, String measurableParameter) async {
  print('Saving prediction for adjustment $adjustmentId');

  final db = await DatabaseHelper().database;
  final predictionService = PredictionRepository(db: db);
  final measurementService = MeasurementService();
  
  //final adjustmentService = AdjustmentService();
  //final adjustment = await adjustmentService.getOpenAdjustment(pump.id);

  /*
  if (adjustment == null || adjustment['id'] == null) {
    print('Error: Adjustment ID is null.');
    return;
  }*/

  // Check if an existing prediction already exists
  Prediction? existingPrediction = await predictionService.getPredictionByAdjustmentId(adjustmentId);

  // If an existing prediction is found, use it; otherwise, create a new one
  Prediction prediction = existingPrediction ?? Prediction();

  if (measurableParameter == 'volume flow') {
    final measurements = await measurementService.fetchMeasurementsByAdjustmentId(adjustmentId);

    if (measurements == null || measurements.length < 5) {
      print('Not enough measurements. Skipping prediction.');
      return;
    }

    final currentOperatingHours = measurements.map((m) => m.currentOperatingHours).toList();
    final qn = measurements.map((m) => m.Qn).toList();

    final model = fitQuadratic(currentOperatingHours, qn);
    print('Fitted Model => $model');

    final solutions = findXForY(model, 0.900);

    double? estimatedOperatingHours;
    if (solutions.isEmpty) {
      print('No real solution for y=0.900.');
    } else {
      for (final x in solutions) {
        if (x >= 0) {
          print('At y=0.900 => x= $x (Operating Hours)');
          estimatedOperatingHours = x;
        }
      }
    }

    //final remainingDaysTillMaintenance = Utils().calculateRemainingDaysTillMaintenance(measurements.last.date, estimatedOperatingHours, currentOperatingHours.last, measurements.last.averageOperatingHoursPerDay);

    // format estimated maintenance date
    DateTime? estimatedMaintenanceDate;
    if (estimatedOperatingHours != null)
    {
      final remainingHoursTillMaintenance = (estimatedOperatingHours - currentOperatingHours.last).toInt();
      estimatedMaintenanceDate = Utils().getEstimatedMaintenanceDate(remainingHoursTillMaintenance, DateTime.parse(measurements.last.date));
    }

    prediction = prediction.copyWith(
      estimatedOperatingHours: estimatedOperatingHours,
      estimatedMaintenanceDate: estimatedMaintenanceDate,
      adjusmentId: adjustmentId,
      a: model.a,
      b: model.b,
      c: model.c,
    );
  }

  print('Estimated Operating hours: ${prediction.estimatedOperatingHours}');

  // Save the updated prediction (Update if exists, Insert if new)
  if (existingPrediction != null) {
    await predictionService.updatePrediction(prediction);
    print('Updated existing prediction');
  } else {
    await predictionService.savePrediction(prediction, adjustmentId);
    print('Inserted new prediction');
  }
}




/// Fits a 2nd-degree polynomial y = a*x^2 + b*x + c
/// to the points (x[i], y[i]) using a least-squares approach.
///
/// Returns a QuadraticModel with coefficients (a, b, c).
QuadraticModel fitQuadratic(xVals, yVals) {
  assert(xVals.length == yVals.length,
      'xVals and yVals must have the same length.');

  final n = xVals.length;

  // 1. Build design matrix X (n×3):
  //    Each row: [1, x, x^2]
  final X = List.generate(n, (i) {
    final x = xVals[i];
    return [1.0, x, x * x];
  });

  // 2. Compute X^T X (3×3) and X^T y (3×1)
  final XTX = List.generate(3, (_) => List.filled(3, 0.0));
  final XTy = List.filled(3, 0.0);

  for (int i = 0; i < n; i++) {
    final row = X[i];
    final y = yVals[i];
    for (int r = 0; r < 3; r++) {
      // X^T y
      XTy[r] += row[r] * y;
      // X^T X
      for (int c = 0; c < 3; c++) {
        XTX[r][c] += row[r] * row[c];
      }
    }
  }

  // 3. Invert (X^T X)
  final inv = invert3x3(XTX);

  // 4. Solve for [c, b, a] = (X^T X)^-1 (X^T y)
  final coeffs = List.filled(3, 0.0);
  for (int i = 0; i < 3; i++) {
    double sum = 0.0;
    for (int j = 0; j < 3; j++) {
      sum += inv[i][j] * XTy[j];
    }
    coeffs[i] = sum;
  }

  // The solution order is [c, b, a].
  final c = coeffs[0];
  final b = coeffs[1];
  final a = coeffs[2];

  return QuadraticModel(a, b, c);
}



/// Determinant of a 3x3 matrix
double determinant3x3(List<List<double>> m) {
  return m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1])
       - m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0])
       + m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
}


/// Cofactor matrix of a 3x3
List<List<double>> cofactor3x3(List<List<double>> m) {
  // minors & sign flips
  final cof = List.generate(3, (_) => List.filled(3, 0.0));

  // Helper to compute 2x2 minor determinant
  double minorDet(int r0, int c0, int r1, int c1) {
    return m[r0][c0] * m[r1][c1] - m[r0][c1] * m[r1][c0];
  }

  cof[0][0] =  minorDet(1,1, 2,2);   //  (+) sign
  cof[0][1] = -minorDet(1,0, 2,2);   //  (-) sign
  cof[0][2] =  minorDet(1,0, 2,1);   //  (+) sign

  cof[1][0] = -minorDet(0,1, 2,2);   //  (-) sign
  cof[1][1] =  minorDet(0,0, 2,2);   //  (+) sign
  cof[1][2] = -minorDet(0,0, 2,1);   //  (-) sign

  cof[2][0] =  minorDet(0,1, 1,2);   //  (+) sign
  cof[2][1] = -minorDet(0,0, 1,2);   //  (-) sign
  cof[2][2] =  minorDet(0,0, 1,1);   //  (+) sign

  return cof;
}

/// Adjoint (adjugate) of a 3x3 matrix:
/// The transpose of the cofactor matrix.
List<List<double>> adjoint3x3(List<List<double>> m) {
  final cof = cofactor3x3(m);
  // transpose the cofactor matrix
  return List.generate(3, (r) => List.generate(3, (c) => cof[c][r]));
}

/// Invert a 3x3 matrix using the classical adjoint & determinant method.
///
/// Throws an Exception if the matrix is singular (det = 0).
List<List<double>> invert3x3(List<List<double>> m) {
  final det = determinant3x3(m);
  if (det == 0) {
    throw Exception('Matrix is singular and cannot be inverted.');
  }

  // Adjoint (or adjugate) of m
  final adj = adjoint3x3(m);

  // Multiply each element of adj by (1/det)
  // to get the inverse
  final inv = List.generate(3, (_) => List.filled(3, 0.0));
  for (int r = 0; r < 3; r++) {
    for (int c = 0; c < 3; c++) {
      inv[r][c] = adj[r][c] / det;
    }
  }
  return inv;
}


/// Returns all real solutions x for the equation:
/// a*x^2 + b*x + (c - targetY) = 0.
///
/// Typically you'll either get 0, 1, or 2 real solutions.
/// You can decide which solution(s) make physical sense (e.g., x >= 0).
List<double> findXForY(QuadraticModel model, double targetY) {
  final a = model.a;
  final b = model.b;
  final c_ = model.c - targetY; // shift so that we solve a*x^2 + b*x + c_ = 0

  // Edge case: If 'a' ~ 0, we have a linear equation:
  if (a.abs() < 1e-12) {
    // b*x + c_ = 0 => x = -c_/b
    if (b.abs() < 1e-12) {
      return []; // No solution if b also ~ 0
    }
    return [-c_ / b];
  }

  // Solve discriminant
  final discriminant = b * b - 4 * a * c_;
  if (discriminant < 0) {
    // No real solutions
    return [];
  } else if (discriminant == 0) {
    // One real solution
    final x = -b / (2 * a);
    return [x];
  } else {
    // Two real solutions
    final sqrtD = sqrt(discriminant);
    final x1 = (-b + sqrtD) / (2 * a);
    final x2 = (-b - sqrtD) / (2 * a);
    return [x1, x2];
  }
}



}