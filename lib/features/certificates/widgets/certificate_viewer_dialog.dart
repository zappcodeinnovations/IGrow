import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/course_models.dart';

class CertificateViewerDialog extends StatelessWidget {
  const CertificateViewerDialog({
    super.key,
    required this.enrollment,
    required this.studentName,
  });

  final ApiEnrollment enrollment;
  final String studentName;

  static void show(
    BuildContext context, {
    required ApiEnrollment enrollment,
    required String studentName,
  }) {
    showDialog(
      context: context,
      builder: (_) => CertificateViewerDialog(
        enrollment: enrollment,
        studentName: studentName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final issueDate = enrollment.enrolledAt != null
        ? DateFormat.yMMMMd().format(enrollment.enrolledAt!)
        : DateFormat.yMMMMd().format(DateTime.now());

    final certId = 'AGRI-${enrollment.id.length >= 8 ? enrollment.id.substring(0, 8).toUpperCase() : enrollment.id.toUpperCase()}';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Certificate Card Canvas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFDF9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFD4AF37), // Gold
                width: 3,
              ),
            ),
            child: Stack(
              children: [
                // Inner ornamental border
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'AGRILEARN ACADEMY',
                            style: TextStyle(
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Title
                      const Text(
                        'CERTIFICATE OF COMPLETION',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8B6508), // Dark Gold
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This is proudly presented to',
                        style: TextStyle(
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Student Name
                      Text(
                        studentName.isNotEmpty ? studentName : 'Verified Student',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF1E231F),
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 140,
                        height: 2,
                        color: const Color(0xFFD4AF37),
                      ),

                      // Description
                      const Text(
                        'for successfully mastering and completing all practical lectures & assessments for the course',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Course Title
                      Text(
                        enrollment.courseTitle ?? 'Agricultural Specialist Course',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Footer with Signatures & Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Left: Issue Date & ID
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Issue Date: $issueDate',
                                style: const TextStyle(fontSize: 10, color: Colors.black54),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Cert ID: $certId',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),

                          // Center: Golden Stamp Seal
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFF9E6),
                              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFD4AF37),
                              size: 32,
                            ),
                          ),

                          // Right: Verification Tag
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, color: AppColors.primaryGreen, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'VERIFIED',
                                      style: TextStyle(
                                        color: AppColors.primaryGreen,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('Share Certificate', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  // --- Build the certificate PDF ---
                  final pdf = pw.Document();
                  pdf.addPage(
                    pw.Page(
                      pageFormat: PdfPageFormat.a4.landscape,
                      margin: const pw.EdgeInsets.all(40),
                      build: (pw.Context pCtx) {
                        return pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: const PdfColor.fromInt(0xFFD4AF37), width: 4),
                            borderRadius: pw.BorderRadius.circular(12),
                          ),
                          padding: const pw.EdgeInsets.all(28),
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              // Header
                              pw.Text(
                                'AGRILEARN ACADEMY',
                                style: pw.TextStyle(
                                  fontSize: 22,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.green900,
                                  letterSpacing: 2,
                                ),
                              ),
                              pw.SizedBox(height: 14),

                              // Title
                              pw.Text(
                                'CERTIFICATE OF COMPLETION',
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: const PdfColor(0.545, 0.396, 0.031), // Dark Gold
                                  letterSpacing: 1.5,
                                ),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Text(
                                'This is proudly presented to',
                                style: const pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(height: 12),

                              // Student Name
                              pw.Text(
                                studentName.isNotEmpty ? studentName : 'Verified Student',
                                style: pw.TextStyle(
                                  fontSize: 26,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Container(
                                margin: const pw.EdgeInsets.symmetric(vertical: 8),
                                width: 120,
                                height: 2,
                                color: const PdfColor.fromInt(0xFFD4AF37),
                              ),

                              // Body Text
                              pw.Text(
                                'for successfully mastering and completing all practical\nlectures & assessments for the course',
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                              ),
                              pw.SizedBox(height: 10),

                              // Course Title
                              pw.Text(
                                enrollment.courseTitle ?? 'Agricultural Specialist Course',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.green800,
                                ),
                              ),
                              pw.SizedBox(height: 24),

                              // Footer
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('Issue Date: $issueDate', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                                      pw.Text('Cert ID: $certId', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                    ],
                                  ),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: pw.BoxDecoration(
                                      color: PdfColors.green50,
                                      borderRadius: pw.BorderRadius.circular(6),
                                    ),
                                    child: pw.Text(
                                      'VERIFIED  •  IGROW',
                                      style: pw.TextStyle(
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.green800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );

                  // --- Save PDF to documents directory ---
                  final pdfBytes = await pdf.save();
                  final dir = await getApplicationDocumentsDirectory();
                  final fileName = 'IGrow_Certificate_$certId.pdf';
                  final file = File('${dir.path}/$fileName');
                  await file.writeAsBytes(pdfBytes);

                  // --- Open OS share sheet (WhatsApp, Email, etc.) ---
                  await Printing.sharePdf(bytes: pdfBytes, filename: fileName);

                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
