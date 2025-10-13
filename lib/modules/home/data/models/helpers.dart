// lib/models/helpers.dart

DateTime? parseDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v.toUtc();
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
  if (v is String && v.trim().isNotEmpty) return DateTime.parse(v).toUtc();
  return null;
}

double? toDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String && v.trim().isNotEmpty) return double.tryParse(v);
  return null;
}

List<String> asStringList(dynamic v) {
  if (v == null) return const <String>[];
  if (v is List) {
    return v
        .where((e) => e != null)
        .map((e) => e.toString())
        .toList(growable: false);
  }
  return const <String>[];
}
