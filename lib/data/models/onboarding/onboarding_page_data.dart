enum GlyphType { focus, black, vault, gesture, ready }

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.button,
    required this.glyph,
  });

  final String title;
  final String subtitle;
  final String body;
  final String button;
  final GlyphType glyph;
}
