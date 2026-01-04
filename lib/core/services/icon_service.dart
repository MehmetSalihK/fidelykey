class IconService {
  static const String _baseUrl = 'https://logo.clearbit.com';

  /// Returns the URL for the issuer's logo.
  /// [issuer] is the name of the service (e.g. "Google", "Amazon AWS").
  /// Returns null if issuer is empty.
  static String? getIconUrl(String issuer) {
    if (issuer.trim().isEmpty) return null;
    
    final domain = _guessDomain(issuer);
    return '$_baseUrl/$domain';
  }

  /// Tries to guess the domain from the issuer name.
  /// Simple heuristic: "Amazon AWS" -> "amazon.com"
  static String _guessDomain(String issuer) {
    // 1. Clean format
    String clean = issuer.toLowerCase().trim();
    
    // 2. Remove common suffixes
    clean = clean.replaceAll(RegExp(r'\s(inc|corp|ltd|llc|gmbh|sa|sarl)\.?$'), '');
    
    // 3. Handle spaces -> take first word usually, or keep it if known
    // Clearbit is smart, but often expects a domain.
    // If it's a domain already (contains dot), return it.
    if (clean.contains('.')) return clean;
    
    // 4. Common mappings (Optional optimisation)
    final map = {
      'google': 'google.com',
      'facebook': 'facebook.com',
      'amazon': 'amazon.com',
      'aws': 'aws.amazon.com',
      'microsoft': 'microsoft.com',
      'github': 'github.com',
      'discord': 'discord.com',
      'twitter': 'twitter.com',
      'x': 'twitter.com',
      'apple': 'apple.com',
      'binance': 'binance.com',
      'coinbase': 'coinbase.com',
    };
    
    if (map.containsKey(clean)) return map[clean]!;
    
    // 5. Fallback: append .com (naive but works 80% of time for major services)
    // If there are spaces, try removing them? 'proton mail' -> 'protonmail.com'
    clean = clean.replaceAll(' ', '');
    return '$clean.com';
  }
}
