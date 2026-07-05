/// Safe Date Parsing Utility
/// 
/// Resolves issues where NestJS/Prisma serializes empty dates as empty JSON objects
/// `{}` or other invalid formats, preventing the app from crashing during deserialization.
DateTime? safeParseDate(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
  // Fallback for empty Maps like {} or invalid objects
  return null;
}
