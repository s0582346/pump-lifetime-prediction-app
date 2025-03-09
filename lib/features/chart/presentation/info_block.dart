import 'package:flutter/material.dart';

class InfoBlock extends StatelessWidget {
  final double currentOperatingHours;
  final double estimatedOperatingHours;
  final String maintenanceDate;
  final String count;

  const InfoBlock({
    super.key,
    required this.currentOperatingHours,
    required this.estimatedOperatingHours,
    required this.count,
    this.maintenanceDate = '-',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Adjustment - $count", style: const TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _infoRow('Current Operating Hours: ', "${currentOperatingHours.toStringAsFixed(1)} h"),
        _infoRow('Estimated Operating Hours: ', "${estimatedOperatingHours.toStringAsFixed(1)} h"),
        _infoRow('Estimated Adjustment Day: ', maintenanceDate),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black)),
        ],
      ),
    );
  }
}