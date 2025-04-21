enum TimeEntry {
  absolute('operating time (absolute)'),
  relative('operating time (relative)'),
  average('average operating time per day');

  final String label;
  const TimeEntry(this.label);

  static TimeEntry? fromString(String? value) {
    try {
      return TimeEntry.values.firstWhere((e) => e.label == value);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => label;
}