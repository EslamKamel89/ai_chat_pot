import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

String cleanHtml(String raw) {
  var s = raw.trim();
  if (s.startsWith('```html')) {
    s = s.substring('```html'.length).trim();
  } else if (s.startsWith('```')) {
    s = s.substring(3).trim();
  }
  if (s.endsWith('```')) {
    s = s.substring(0, s.length - 3).trim();
  }
  return s;
}

class StyledHtmlView extends StatelessWidget {
  final String rawResponseHtml;
  final bool addStyling;
  final Color? accentColor;
  final Color? surfaceColor;
  const StyledHtmlView({
    required this.rawResponseHtml,
    super.key,
    this.addStyling = true,
    this.accentColor,
    this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final html = cleanHtml(rawResponseHtml);

    final Color accent = accentColor ?? Theme.of(context).colorScheme.primary;
    final Color accentSoft = accent.withOpacity(0.10);
    final Color surface = surfaceColor ?? Theme.of(context).colorScheme.surface;
    final Color mutedText = Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.85);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
            boxShadow: const [
              BoxShadow(blurRadius: 8, offset: Offset(0, 3), color: Color.fromRGBO(0, 0, 0, 0.04)),
            ],
          ),
          child: Html(
            data: html,
            shrinkWrap: true,
            style:
                addStyling
                    ? {
                      // reset body
                      'body': Style(
                        padding: HtmlPaddings.zero,
                        margin: Margins.zero,
                        fontSize: FontSize(16),
                        lineHeight: LineHeight(1.75),
                        textAlign: TextAlign.start,
                        color: mutedText,
                        fontFamily: null, // keep theme font; override if you add GoogleFonts
                      ),

                      // global wildcard
                      '*': Style(letterSpacing: 0.2),

                      // Main title
                      'h1': Style(
                        display: Display.block,
                        fontSize: FontSize(22),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        padding: HtmlPaddings.symmetric(vertical: 10, horizontal: 18),
                        margin: Margins.symmetric(vertical: 6),
                        backgroundColor: accent,
                        // border: BorderRadius.circular(24),
                        textAlign: TextAlign.center,
                        // subtle shadow looks nicer on some devices:
                        textDecoration: TextDecoration.none,
                      ),

                      // Section headings — small accent line and spacing
                      'h2': Style(
                        fontSize: FontSize(18),
                        fontWeight: FontWeight.w800,
                        margin: Margins.only(top: 16, bottom: 8),
                        padding: HtmlPaddings.only(bottom: 6),
                        textDecoration: TextDecoration.none,
                        color: accent,
                      ),
                      'h3': Style(
                        fontSize: FontSize(17),
                        fontWeight: FontWeight.w700,
                        margin: Margins.only(top: 12, bottom: 6),
                      ),
                      'h4': Style(
                        fontSize: FontSize(15),
                        fontWeight: FontWeight.w700,
                        margin: Margins.only(top: 10, bottom: 6),
                      ),

                      // Paragraphs
                      'p': Style(
                        fontSize: FontSize(15.5),
                        margin: Margins.symmetric(vertical: 6),
                        color: mutedText,
                      ),

                      // Lists: keep RTL in mind
                      'ul': Style(
                        margin: Margins.symmetric(vertical: 6),
                        padding: HtmlPaddings.only(right: 8),
                      ),
                      'ol': Style(
                        margin: Margins.symmetric(vertical: 6),
                        padding: HtmlPaddings.only(right: 8),
                      ),

                      // List items: subtle card with rounded corners for readability
                      'li': Style(
                        fontSize: FontSize(15.5),
                        margin: Margins.symmetric(vertical: 6),
                        padding: HtmlPaddings.symmetric(vertical: 10, horizontal: 10),
                        backgroundColor: accentSoft,

                        // border: BorderRadius.circular(2),
                        // ensure bullet alignment for RTL:
                        textAlign: TextAlign.start,
                      ),

                      // Strong emphasis
                      'strong': Style(fontWeight: FontWeight.w800, color: Colors.black87),

                      // links
                      'a': Style(textDecoration: TextDecoration.underline, color: accent),

                      // horizontal rule: lighter, thin spacing
                      'hr': Style(
                        margin: Margins.symmetric(vertical: 14),
                        padding: HtmlPaddings.zero,
                        backgroundColor:
                            Colors.transparent, // some renderers keep default; this helps
                      ),

                      // small helper for blockquote-like sections (if your HTML uses blockquote)
                      'blockquote': Style(
                        margin: Margins.symmetric(vertical: 10),
                        padding: HtmlPaddings.symmetric(vertical: 10, horizontal: 12),
                        backgroundColor: accent.withOpacity(0.04),
                        // border: BorderSide(width: 1, color: accent.withOpacity(0.12)),
                        // borderRadius: BorderRadius.circular(8),
                        fontStyle: FontStyle.italic,
                      ),
                    }
                    : {},
            // optional: handle link taps (left empty so you can hook url_launcher)
            onLinkTap: (url, _, __) {
              // Example: use url_launcher: launchUrlString(url ?? '')
            },
          ),
        ),
      ),
    );
  }
}
