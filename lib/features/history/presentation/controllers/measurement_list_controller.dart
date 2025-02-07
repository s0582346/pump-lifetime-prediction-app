import 'package:flutter_predictive_maintenance_app/features/parameters/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/features/parameters/domain/measurement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
class MeasurementListController extends StateNotifier<List<Measurement>> {
  //final MeasurementService _measurementService = MeasurementService();

  @override
  StateNotifier<List<Measurement>> build() {
    return this;
  }

}*/

final measurementDataProvider = Provider<List<Measurement>>((ref) {
  return [
    Measurement(currentOperatingHours: 0.00, volumeFlow: 8.24, pressure: 18.14),
    Measurement(currentOperatingHours: 4.00, volumeFlow: 8.21, pressure: 18.34),
    Measurement(currentOperatingHours: 19.5, volumeFlow: 8.3, pressure: 18.2),
    Measurement(currentOperatingHours: 23.5, volumeFlow: 8.26, pressure: 18.28),
  ];
});


final measurementServiceProvider = Provider((ref) => MeasurementService());

final a = FutureProvider<List<Measurement>>(
  (ref) async {
    final repo = ref.read(measurementServiceProvider);
    return repo.fetchMeasurements();
  },
);