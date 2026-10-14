/// Client-side E.164 normalization aligned with backend auth contracts.
String? tryNormalizePhoneE164(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  var candidate = trimmed.replaceAll(RegExp(r'[\s\-().]'), '');
  if (candidate.startsWith('00')) {
    candidate = '+${candidate.substring(2)}';
  }
  if (!candidate.startsWith('+')) {
    return null;
  }
  final pattern = RegExp(r'^\+[1-9]\d{7,14}$');
  if (!pattern.hasMatch(candidate)) {
    return null;
  }
  return candidate;
}
