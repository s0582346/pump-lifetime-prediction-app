class PumpValidationState {
  final String? nameError;
  final String? pumpTypeError;
  final String? measurableParameterError;
  final String? persmissibleTotalWearError;
  final String? typeOfTimeEntryError;
  

  const PumpValidationState({
    this.nameError,
    this.pumpTypeError,
    this.measurableParameterError,
    this.persmissibleTotalWearError,
    this.typeOfTimeEntryError
  });

  bool get isFormValid {
    // If all error fields are null, it means everything is valid
    return nameError == null && pumpTypeError == null 
      && measurableParameterError == null && persmissibleTotalWearError == null
      && typeOfTimeEntryError == null;
  }
}