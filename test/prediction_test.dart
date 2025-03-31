import 'package:flutter_predictive_maintenance_app/shared/utils.dart';
import 'package:flutter_predictive_maintenance_app/shared/math_utils.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('Estimated Operating Hours Calculation Test For Volume Flow:', () {
    test('adjustment - 0', () {
      
      final coeffs = [-2.0623646683383752E-5, 0.0011516192267301544, 0.9909659551805043]; 
      const yTarget = 0.900;
      final solutions = MathUtils().findIntersectionAtY(coeffs[0], coeffs[1], coeffs[2], yTarget);
      var solution;

      for (var value in solutions) {
         if (value > 0) {
           solution = value.toInt();
         }
      }
      
      const estimatedOperatingHours = 99;
      const delta = 1;

      expect(solution, closeTo(estimatedOperatingHours, delta));
    });

    test('adjustment - 1', () {
      
      final coeffs = [-6.397691970408055E-5, 0.00996462156337774, 0.64677188383351778]; 
      const yTarget = 0.900;
      final solutions = MathUtils().findIntersectionAtY(coeffs[0], coeffs[1], coeffs[2], yTarget);
      var solution = 0;

      for (var value in solutions) {
         if (value > 0) {
           solution = value.toInt();
         }
      }
      
      const estimatedOperatingHours = 124;
      const delta = 1;

      expect(solution, closeTo(estimatedOperatingHours, delta));
    });

     test('adjustment - 3', () {
      
      final coeffs = [-3.9971783409542574E-5, 0.010418348588387161, 0.3464936653939816]; 
      const yTarget = 0.900;
      final solutions = MathUtils().findIntersectionAtY(coeffs[0], coeffs[1], coeffs[2], yTarget);
      var solution;

      for (var value in solutions) {
         if (value > 0) {
           solution = value.toInt();
         }
      }
      
      const estimatedOperatingHours = 186;
      const delta = 1;

      expect(solution, closeTo(estimatedOperatingHours, delta));
    });
  });

  group('Estimated Operating Hours Calculation Test For Pressure:', () {
    test('adjustment - 0', () {

      final coeffs = [-1.8188830719988288E-5, 8.539421837907829E-4, 0.9904507871464884]; 
      const yTarget = 0.900;
      final solutions = MathUtils().findIntersectionAtY(coeffs[0], coeffs[1], coeffs[2], yTarget);
      var solution = 0;

      for (var value in solutions) {
         if (value > 0) {
           solution = value.toInt();
         }
      }
      
      const estimatedOperatingHours = 97;
      const delta = 1;

      expect(solution, closeTo(estimatedOperatingHours, delta));
    });

    test('adjustment - 2', () {

      final coeffs = [-2.3828253801103692E-5, 0.005081808357450239, 0.7842254142484117]; 
      const yTarget = 0.900;
      final solutions = MathUtils().findIntersectionAtY(coeffs[0], coeffs[1], coeffs[2], yTarget);
      var solution = 0;

      for (var value in solutions) {
         if (value > 0) {
           solution = value.toInt();
         }
      }
      
      const estimatedOperatingHours = 192;
      const delta = 1;

      expect(solution, closeTo(estimatedOperatingHours, delta));
    });

    
  });
}