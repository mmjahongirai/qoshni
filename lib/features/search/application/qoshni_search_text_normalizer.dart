/// Whitespace-safe normalization for deterministic matching (not destructive transliteration).
String qoshniSearchNormalizeQueryText(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  final collapsed = trimmed.split(RegExp(r'\s+')).join(' ');
  return collapsed.toLowerCase();
}

/// Case-insensitive prefix check preserving normalized forms.
bool qoshniSearchNormalizedPrefixMatch(String normalizedHaystack, String normalizedNeedle) {
  if (normalizedNeedle.isEmpty) {
    return false;
  }
  return normalizedHaystack.startsWith(normalizedNeedle) ||
      normalizedHaystack.contains(' $normalizedNeedle');
}
