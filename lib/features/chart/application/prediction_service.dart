import 'package:flutter/gestures.dart';
import 'package:flutter_predictive_maintenance_app/database/database_helper.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/prediction.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/data/prediction_repository.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/quadratic_fit_result.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scidart/numdart.dart';


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

Future<void> predict(String adjustmentId, Pump pump) async {
  final db = await DatabaseHelper().database;
  final predictionService = PredictionRepository(db: db);
  final measurementService = MeasurementService();
  

  // Check if an existing prediction already exists
  Prediction? existingPrediction = await predictionService.getPredictionByAdjustmentId(adjustmentId);
  Prediction prediction = existingPrediction ?? Prediction();
  
    final List<double> currentOperatingHours = [];
    final List<double> Qn = [];
    final List<double> pn = [];
    List<double> coeffs = [];


    final measurements = await measurementService.fetchMeasurementsFromAdjustment(adjustmentId, pump.id);

    if (measurements == null || measurements.length < 3) {
      return;
    }
  
    if (pump.measurableParameter == 'volume flow') {
      for (final m in measurements) {
        final double? hours = m.currentOperatingHours.toDouble();
        final double? flow = m.Qn;

        if (hours != null && flow != null) {
          currentOperatingHours.add(hours);
          Qn.add(flow);
        }
      }

      final zeroCount = currentOperatingHours.where((h) => h == 0.0).length;
      if (zeroCount > 1) return;
    
      coeffs = fitQuadratic(currentOperatingHours, Qn); 
    } else {
      for (final m in measurements) {
        final double? hours = m.currentOperatingHours.toDouble();
        final double? flow = m.pn;

        if (hours != null && flow != null) {
          currentOperatingHours.add(hours);
          pn.add(flow);
        }
      }

      final zeroCount = currentOperatingHours.where((h) => h == 0.0).length;
      if (zeroCount > 1) return;

      coeffs = fitQuadratic(currentOperatingHours, pn); 
    }
   
    final a = coeffs.length > 2 ? coeffs[2] : 0.0;
    final b = coeffs.length > 1 ? coeffs[1] : 0.0;
    final c = coeffs.length > 0 ? coeffs[0] : 0.0;

    final solutions = findXForY(a, b, c, 0.900);

    double? estimatedOperatingHours;
    if (solutions.isNotEmpty) {
       for (final x in solutions) {
        if (x >= 0) {
          print('At y=0.900 => x= $x (Operating Hours)');
          estimatedOperatingHours = x;
        }
      }
    }

    // format estimated maintenance date
    DateTime? estimatedMaintenanceDate;
    if (estimatedOperatingHours != null)
    {
      final remainingHoursTillMaintenance = ((estimatedOperatingHours - currentOperatingHours.last).abs()).toInt();
      estimatedMaintenanceDate = Utils().getEstimatedMaintenanceDate(remainingHoursTillMaintenance, DateTime.parse(measurements.last.date));
    }

    prediction = prediction.copyWith(
      estimatedOperatingHours: estimatedOperatingHours,
      estimatedMaintenanceDate: estimatedMaintenanceDate,
      adjusmentId: adjustmentId,
      a: a,
      b: b,
      c: c,
    );

    (existingPrediction != null) ? await predictionService.updatePrediction(prediction) : await predictionService.savePrediction(prediction, adjustmentId);
}

Future<void> predictTotal(Pump pump) async {
  List<double> QnTotal = [];
  final List<double> pnTotal = [];
  List<double> currentOperatingHoursTotal = [];
  List<double> coeffs = [];

  final adjustmentId = '${pump.id}-S'; 
  final db = await DatabaseHelper().database;
  final predictionService = PredictionRepository(db: db);
  final measurementService = MeasurementService();
  final measurementsTotal = await measurementService.fetchMeasurementsByPumpId(pump.id);

  Prediction? existingPrediction = await predictionService.getPredictionByAdjustmentId(adjustmentId);
  Prediction prediction = existingPrediction ?? Prediction(); // no prediction, then create one

  if (measurementsTotal == null || measurementsTotal.length < 3) {
    return;
  }

  if (pump.measurableParameter == 'volume flow') {
    for (final m in measurementsTotal) {
      final double? hours = m.currentOperatingHours.toDouble();
      final double? flow = m.QnTotal.toDouble();

      if (hours != null && flow != null) {
        currentOperatingHoursTotal.add(hours);
        QnTotal.add(flow);
      }
    }

    final zeroCount = currentOperatingHoursTotal.where((h) => h == 0.0).length;
    if (zeroCount > 1) return;

    coeffs = fitQuadratic(currentOperatingHoursTotal, QnTotal); 
  } else if (pump.measurableParameter == 'pressure') {
    for (final m in measurementsTotal) {
      final double? hours = m.currentOperatingHours.toDouble();
      final double? flow = m.pnTotal;

      if (hours != null && flow != null) {
        currentOperatingHoursTotal.add(hours);
        pnTotal.add(flow);
      }
    }

    final zeroCount = currentOperatingHoursTotal.where((h) => h == 0.0).length;
    if (zeroCount > 1) return;

    coeffs = fitQuadratic(currentOperatingHoursTotal, pnTotal); 
  }


  final a = coeffs.length > 2 ? coeffs[2] : 0.0;
  final b = coeffs.length > 1 ? coeffs[1] : 0.0;
  final c = coeffs.length > 0 ? coeffs[0] : 0.0;

  //print('${a}x^2 + ${b}x + ${c}');

  prediction = prediction.copyWith(
    adjusmentId: adjustmentId,
    a: a,
    b: b,
    c: c,
  );

  (existingPrediction != null) ? await predictionService.updatePrediction(prediction) : await predictionService.savePrediction(prediction, adjustmentId);
}




/// Fits a 2nd-degree polynomial y = a*x^2 + b*x + c
/// to the points (x[i], y[i]) using a least-squares approach.
///
/// Returns a QuadraticModel with coefficients (a, b, c).
List<double> fitQuadratic(xVals, yVals) {
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

  //return QuadraticModel(a, b, c);
  return coeffs;
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
List<double> findXForY(double a, double b, double c, double targetY) {
  final c_ = c - targetY; // shift so that we solve a*x^2 + b*x + c_ = 0

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