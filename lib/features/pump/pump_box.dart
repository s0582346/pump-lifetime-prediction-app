import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/pump.dart';
import 'package:flutter_predictive_maintenance_app/navigation/navigation.dart';

class PumpBox extends StatelessWidget {
  final Pump pump;

  const PumpBox({Key? key, required this.pump}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => Navigation()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pump.id,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text('Measurable Parameter: ${pump.measurableParameter}'),
            Text('Permissible Total Wear: ${pump.permissibleTotalWear}'),
            Text('Medium: ${pump.medium}'),
          ],
        ),
      ),
    );
  }
}