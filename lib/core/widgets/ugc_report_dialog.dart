import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

enum UgcReportType { post, comment }

class UgcReportDialog extends StatefulWidget {
  const UgcReportDialog({
    super.key,
    required this.itemId,
    required this.type,
    this.authorName,
  });

  final String itemId;
  final UgcReportType type;
  final String? authorName;

  static Future<bool?> show(
    BuildContext context, {
    required String itemId,
    required UgcReportType type,
    String? authorName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => UgcReportDialog(
        itemId: itemId,
        type: type,
        authorName: authorName,
      ),
    );
  }

  @override
  State<UgcReportDialog> createState() => _UgcReportDialogState();
}

class _UgcReportDialogState extends State<UgcReportDialog> {
  String _selectedReason = 'INAPPROPRIATE';
  final _detailsController = TextEditingController();

  final List<Map<String, String>> _reasons = const [
    {'value': 'INAPPROPRIATE', 'label': 'Inappropriate Content'},
    {'value': 'HARASSMENT', 'label': 'Harassment or Bullying'},
    {'value': 'HATE_SPEECH', 'label': 'Hate Speech or Discrimination'},
    {'value': 'SPAM', 'label': 'Spam or Advertising'},
    {'value': 'MISINFORMATION', 'label': 'Misleading or False Information'},
    {'value': 'OTHER', 'label': 'Other Violation'},
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(true);
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDark ? const Color(0xFF1E2B22) : Colors.white,
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 24),
              SizedBox(width: 8),
              Text('Report Submitted', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Report submitted. Reviewed within 24 hours. We maintain a zero-tolerance policy against objectionable content.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              height: 1.4,
              color: isDark ? Colors.white70 : AppColors.inkDark,
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemType = widget.type == UgcReportType.post ? 'Post' : 'Comment';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1B2A1F) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flag_rounded, color: Colors.redAccent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report Objectionable $itemType',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Flag offensive content for 24-hr moderator action',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: isDark ? Colors.white60 : AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),

            Text(
              'Select a reason:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.inkDark,
              ),
            ),
            const SizedBox(height: 8),

            // Radio choices
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF142017) : const Color(0xFFF8FAF7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF283B2C) : const Color(0xFFE2EBE0),
                ),
              ),
              child: Column(
                children: _reasons.map((r) {
                  final isSelected = _selectedReason == r['value'];
                  return InkWell(
                    onTap: () => setState(() => _selectedReason = r['value']!),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? AppColors.primaryGreen : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              r['label']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isDark ? Colors.white : AppColors.inkDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Optional explanation
            TextField(
              controller: _detailsController,
              maxLines: 2,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isDark ? Colors.white : AppColors.inkDark,
              ),
              decoration: InputDecoration(
                hintText: 'Additional details (optional)...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: isDark ? const Color(0xFF142017) : const Color(0xFFF8FAF7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF283B2C) : const Color(0xFFE2EBE0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.flag, size: 16),
                  label: const Text('Submit Report'),
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
