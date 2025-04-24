class ResultInfo {
  final bool success;
  final errorMessage;
  final prop;

  ResultInfo.success() : success = true, errorMessage = null, prop = null;
  
  ResultInfo.error(this.prop, this.errorMessage) : success = false;
}