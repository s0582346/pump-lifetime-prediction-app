import 'package:flutter/material.dart';
import 'package:flutter_predictive_maintenance_app/features/pump/presentation/initial_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;

  // constructor
  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: const Color(0xFF007167),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
          onPressed: () {
            // TODO: WIP - this needs to open a side menu
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => InitialScreen(), // pass the selected pump to the Navigation widget
                ),
                (Route<dynamic> route) => false // remove all the routes from the stack
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}