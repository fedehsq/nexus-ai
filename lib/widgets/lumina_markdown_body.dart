import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/lumina_colors.dart';
import '../utils/external_url_resolver.dart';

class LuminaMarkdownBody extends StatelessWidget {
  const LuminaMarkdownBody({
    super.key,
    required this.data,
    required this.isUser,
  });

  final String data;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final textColor = isUser ? LuminaColors.onPrimary : LuminaColors.onSurface;
    final linkColor = isUser ? LuminaColors.onPrimary : LuminaColors.primary;
    final codeBackground = isUser
        ? LuminaColors.onPrimary.withValues(alpha: 0.12)
        : LuminaColors.surfaceContainerHighest;

    return MarkdownBody(
      data: data,
      selectable: true,
      shrinkWrap: true,
      softLineBreak: true,
      onTapLink: (text, href, title) {
        if (href == null) return;
        _launchUrl(href);
      },
      styleSheet: MarkdownStyleSheet(
        p: GoogleFonts.inter(
          fontSize: 16,
          height: 1.6,
          color: textColor,
        ),
        strong: GoogleFonts.inter(
          fontSize: 16,
          height: 1.6,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        em: GoogleFonts.inter(
          fontSize: 16,
          height: 1.6,
          fontStyle: FontStyle.italic,
          color: textColor,
        ),
        a: GoogleFonts.inter(
          fontSize: 16,
          height: 1.6,
          color: linkColor,
          decoration: TextDecoration.underline,
          decorationColor: linkColor.withValues(alpha: 0.6),
        ),
        h1: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        h2: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        h3: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        listBullet: GoogleFonts.inter(
          fontSize: 16,
          color: textColor,
        ),
        blockSpacing: 8,
        listIndent: 24,
        blockquote: GoogleFonts.inter(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          color: textColor.withValues(alpha: 0.85),
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: linkColor.withValues(alpha: 0.5),
              width: 3,
            ),
          ),
        ),
        code: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          color: isUser ? LuminaColors.onPrimary : LuminaColors.primary,
          backgroundColor: codeBackground,
        ),
        codeblockDecoration: BoxDecoration(
          color: codeBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: LuminaColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        codeblockPadding: const EdgeInsets.all(12),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final resolved = ExternalUrlResolver.resolve(url);
    final uri = Uri.tryParse(resolved);
    if (uri == null || !ExternalUrlResolver.isValidHttpUrl(resolved)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
