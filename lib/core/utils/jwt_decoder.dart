import 'dart:convert';

/// Decodes the payload (claims) of a JWT without verifying its signature.
/// Verification happens server-side; here we only need the claims already
/// validated by Keycloak (e.g. `name`, `email`) for display purposes.
Map<String, dynamic> decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw const FormatException('Invalid JWT format');
  }

  final normalized = base64Url.normalize(parts[1]);
  final payload = utf8.decode(base64Url.decode(normalized));
  return jsonDecode(payload) as Map<String, dynamic>;
}
