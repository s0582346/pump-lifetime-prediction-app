class QuadraticModel {
  /// The model: y = a*x^2 + b*x + c
  final double a;
  final double b;
  final double c;

  const QuadraticModel(this.a, this.b, this.c);

  /// Evaluate y at a given x.
  double call(double x) => a * x * x + b * x + c;

  @override
  String toString() {
    return 'y = ${a.toStringAsFixed(3)}x^2 + '
           '${b.toStringAsFixed(3)}x + '
           '${c.toStringAsFixed(3)}';
  }
}