import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/domain/adjustment.dart';
import 'package:flutter_predictive_maintenance_app/features/chart/presentation/chart_controller.dart';
import 'package:flutter_predictive_maintenance_app/shared/widgets/settings_widget.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/domain/pump.dart';
import 'package:flutter_predictive_maintenance_app/shared/widgets/alert_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InfoBlock extends ConsumerWidget {
  final double currentOperatingHours;
  final double estimatedOperatingHours;
  final String maintenanceDate;
  final String count;
  final residualWear;
  final Adjustment adjustment;
  final Pump pump;
  final bool isLast;

  const InfoBlock({
    super.key,
    required this.currentOperatingHours,
    required this.estimatedOperatingHours,
    required this.count,
    this.maintenanceDate = '-',
    required this.residualWear,
    required this.adjustment,
    required this.pump,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = adjustment.status == 'open';

    // build the dropdown menu
    final dropDownOpt = isOpen ? 'Close ${adjustment.id}' : 'Open ${adjustment.id}';
    final SettingsOption stateOption = SettingsOption(
      label: dropDownOpt,
      onTap: () => isOpen
        ? ref.read(chartControllerProvider.notifier).closeAdjustment(adjustment.id)
        : ref.read(chartControllerProvider.notifier).openAdjustment(adjustment.id),
    );
    final SettingsOption createOption = SettingsOption(
      label: 'New adjustment',
      onTap: () => {
        if (isOpen) {
           showDialog(
            context: context, // Make sure context is available here
            builder: (BuildContext dialogContext) {
              return AlertWidget(
                body: 'The current adjustment is still open. Do you still want to proceed?',
                onTap: () {
                  ref.read(chartControllerProvider.notifier).createAdjustment(adjustment.id);
                },
              );
            },
        )
        } else {
          ref.read(chartControllerProvider.notifier).createAdjustment(adjustment.id)
        }
      },
    );
   
    List<SettingsOption?> options = [
      stateOption,
    ];

    residualWear > 10 ? options.add(createOption) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Adjustment - $count", style: const TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold)),
            (adjustment.status != 'close' || isLast) ? SettingsWidget(options: options) : Container(),
          ],
        ),
        const SizedBox(height: 15),
        _infoRow('Current Operating Hours: ', "${currentOperatingHours.toStringAsFixed(1)} h"),
        _infoRow('Estimated Operating Hours: ', "${estimatedOperatingHours.toStringAsFixed(0)} h"),
        _infoRow('Estimated Adjustment Day: ', maintenanceDate),
        _infoRow('Residual Wear: ', '${residualWear.toString()} %'),
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