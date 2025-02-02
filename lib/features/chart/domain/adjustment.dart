class Adjustment {
  final id;
  final status;
  final date = DateTime.now();
  final pumpId;

  Adjustment({
    this.id,
    this.status,
    this.pumpId
  });

  Adjustment copyWith({
    id,
    status,
    pumpId
  }) {
    return Adjustment(
      id: id ?? this.id,
      status: status ?? this.status,
      pumpId: pumpId ?? this.pumpId
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'date': date,
      'pumpId': pumpId
    };
  } 

}