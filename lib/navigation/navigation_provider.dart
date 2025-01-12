import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavigationProvider = StateProvider<int>((ref) => 1); // 1 is the index of the chart screen, which is the default screen
