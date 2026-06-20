class MatuDbResult<T> {
  const MatuDbResult({this.data, this.error});

  final T? data;
  final String? error;

  bool get isSuccess => error == null;
}
