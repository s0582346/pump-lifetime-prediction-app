class ResultInfo {
  final bool success;
  final errorMessage;

  ResultInfo.success() : success = true, errorMessage = null;
  
  ResultInfo.error(this.errorMessage) : success = false;
  
}