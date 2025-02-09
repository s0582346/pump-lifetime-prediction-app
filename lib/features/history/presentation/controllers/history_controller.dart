import 'package:flutter_predictive_maintenance_app/features/measurement/application/measurement_service.dart';
import 'package:flutter_predictive_maintenance_app/features/measurement/domain/measurement.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class HistoryController extends Notifier<List<Measurement>> {
  //final MeasurementService _measurementService = MeasurementService();

  @override
  List<Measurement> build() {
    return [];
  }


  // controller methods
}



final measurementServiceProvider = Provider((ref) => MeasurementService());

final measurementsProvider = FutureProvider<List<Measurement>>(
  (ref) async {
    final pump = ref.watch(selectedPumpProvider);

    // if pump is null, return an empty list
    if (pump == null) {
      return [];
    }

    final repo = ref.read(measurementServiceProvider);
    return repo.fetchMeasurements(pump.id);
  },
);
