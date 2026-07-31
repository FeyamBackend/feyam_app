/// Retailer slugs Zinc's beta cross-retailer search actually recognizes in
/// its `retailer` field (confirmed against zinc.com/docs' /retailers list).
/// Amazon/Walmart additionally get Zinc's reliable, structured per-retailer
/// search — see the backend's SearchProductsQueryHandler routing policy.
const Set<String> kZincSearchableRetailerSlugs = {
  'amazon',
  'walmart',
  'ebay',
  'target',
  'bestbuy',
  'aliexpress',
};

/// Maps a Feyam Store's domain (e.g. "www.amazon.com") to the retailer slug
/// used both by the search backend and by Zinc itself. Returns null for
/// domains with no known mapping. Note this can return a slug (e.g. "shein")
/// that Zinc doesn't actually support searching — check
/// [kZincSearchableRetailerSlugs] before offering it as a search filter;
/// callers that only need "is this store worth routing to search at all"
/// (vs. just opening the browser) can use a non-null result directly.
String? zincRetailerSlugFromHost(String host) {
  final normalized = host.toLowerCase().replaceFirst('www.', '');
  if (normalized.contains('amazon')) return 'amazon';
  if (normalized.contains('walmart')) return 'walmart';
  if (normalized.contains('ebay')) return 'ebay';
  if (normalized.contains('target')) return 'target';
  if (normalized.contains('bestbuy')) return 'bestbuy';
  if (normalized.contains('aliexpress')) return 'aliexpress';
  if (normalized.contains('shein')) return 'shein';
  return null;
}
