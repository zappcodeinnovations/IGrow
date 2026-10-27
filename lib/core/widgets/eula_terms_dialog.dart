import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class EulaTermsDialog extends StatelessWidget {
  const EulaTermsDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EulaTermsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B2A1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top drag pill
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terms of Use & EULA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.inkDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'End User License Agreement & Safety Policy',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                      color: isDark ? Colors.white70 : AppColors.inkSoft,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Content Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildCallout(
                      isDark,
                      'ZERO-TOLERANCE POLICY FOR OBJECTIONABLE CONTENT',
                      'IAgrow maintains a strict ZERO-TOLERANCE policy for objectionable content, hate speech, abusive language, harassment, spam, and inappropriate materials. Any user violating these terms will be immediately suspended or permanently ejected from the platform.',
                      Icons.gavel_rounded,
                      Colors.amber.shade800,
                    ),
                    const SizedBox(height: 18),
                    _buildSection(
                      isDark,
                      '1. Acceptance of Terms',
                      'By creating an account or accessing IAgrow, you agree to be bound by this End User License Agreement (EULA) and all community guidelines. If you do not agree with any part of these terms, you must not use or access the services.',
                    ),
                    _buildSection(
                      isDark,
                      '2. User-Generated Content & Conduct',
                      'Users are strictly prohibited from posting, uploading, or transmitting any content that:\n'
                          '• Is abusive, harassing, threatening, or promotes violence.\n'
                          '• Contains hate speech, discrimination, or defamation.\n'
                          '• Is sexually explicit, obscene, or inappropriate.\n'
                          '• Infringes on intellectual property rights or spreads misinformation.',
                    ),
                    _buildSection(
                      isDark,
                      '3. 24-Hour Moderation & Review Policy',
                      'IAgrow actively monitors the platform. Any objectionable post or comment reported by the community will be formally reviewed and acted upon within 24 hours. Offending content will be removed, and offending users will be ejected.',
                    ),
                    _buildSection(
                      isDark,
                      '4. User Blocking & Filtering',
                      'Users have the absolute right to block abusive users. When you block a user, their content is immediately removed from your feed and hidden from your view.',
                    ),
                    _buildSection(
                      isDark,
                      '5. Termination of Service',
                      'We reserve the right to remove any content and terminate user accounts without prior notice if they violate these safety guidelines or applicable laws.',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'I Understand & Agree',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCallout(
    bool isDark,
    String title,
    String body,
    IconData icon,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? Colors.white70 : AppColors.inkDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(bool isDark, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.inkDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              height: 1.45,
              color: isDark ? Colors.white70 : AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
