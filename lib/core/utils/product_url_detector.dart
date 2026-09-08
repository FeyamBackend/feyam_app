/// Whether [value] looks like a pasted product page URL rather than a plain
/// text search query. Deliberately generic — it only checks for an absolute
/// http(s) URL with a host; deciding which retailers are actually supported
/// is the backend's job (see ProductUrlParser in Module.Products), not this
/// client-side check.
bool looksLikeProductUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;

  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;

  return uri.scheme == 'http' || uri.scheme == 'https';
}

/// Strips the query string (and anything after it) from a product URL.
/// Retailers routinely tack referral/tracking parameters onto shared links
/// (Amazon's `ref`, `pf_rd_*`, `sbo`, etc.) — none of them are needed to
/// identify the product, since the backend's ProductUrlParser only ever
/// looks at the path, so they're dropped before the URL is used for a
/// lookup or stored anywhere.
String stripUrlQueryParams(String url) {
  final queryStart = url.indexOf('?');
  return queryStart == -1 ? url : url.substring(0, queryStart);
}
