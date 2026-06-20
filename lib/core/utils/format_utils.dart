class FormatUtils {
  FormatUtils._();

  static String fileSize(int bytes) {
    if (bytes >= 1e9) return '${(bytes / 1e9).toStringAsFixed(1)} GB';
    if (bytes >= 1e6) return '${(bytes / 1e6).toStringAsFixed(1)} MB';
    if (bytes >= 1e3) return '${(bytes / 1e3).toStringAsFixed(1)} KB';
    return '$bytes B';
  }
}
