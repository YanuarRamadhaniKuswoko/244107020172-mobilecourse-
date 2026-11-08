/// Pure formatting utility functions without Flutter UI dependencies.
/// These functions can be tested purely in standard unit tests.
library;

String formatDateTime(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  final s = dt.second.toString().padLeft(2, '0');
  return '$d/$m/$y $h:$min:$s';
}

String formatDateShort(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$d/$m/$y';
}

String formatDirtyStatus(bool dirty) {
  return dirty ? 'Belum Sinkron (Offline)' : 'Tersinkron';
}

int calculateWordCount(String text) {
  if (text.trim().isEmpty) return 0;
  return text.trim().split(RegExp(r'\s+')).length;
}
