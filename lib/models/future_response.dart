class FutureResponse {
  final bool isSuccess;
  final String message;

  FutureResponse({required this.isSuccess, required this.message});

  bool get success => isSuccess;

  String get futureMessage => message;
}
