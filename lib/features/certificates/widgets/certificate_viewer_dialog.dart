import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/certificate_model.dart';
import '../../../data/models/api_models/course_models.dart';

class CertificateViewerDialog extends StatefulWidget {
  const CertificateViewerDialog({
    super.key,
    this.certificate,
    this.enrollment,
    this.studentName,
  }) : assert(certificate != null || enrollment != null, 'Either certificate or enrollment must be provided');

  final CertificateModel? certificate;
  final ApiEnrollment? enrollment;
  final String? studentName;

  static void show(
    BuildContext context, {
    CertificateModel? certificate,
    ApiEnrollment? enrollment,
    String? studentName,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => CertificateViewerDialog(
        certificate: certificate,
        enrollment: enrollment,
        studentName: studentName,
      ),
    );
  }

  @override
  State<CertificateViewerDialog> createState() => _CertificateViewerDialogState();
}

class _CertificateViewerDialogState extends State<CertificateViewerDialog> {
  bool _isGeneratingPdf = false;

  String get _studentName {
    if (widget.certificate?.studentName != null && widget.certificate!.studentName.isNotEmpty) {
      return widget.certificate!.studentName;
    }
    if (widget.studentName != null && widget.studentName!.isNotEmpty) {
      return widget.studentName!;
    }
    return 'Farmer Student';
  }

  String get _courseTitle {
    if (widget.certificate?.courseTitle != null && widget.certificate!.courseTitle.isNotEmpty) {
      return widget.certificate!.courseTitle;
    }
    if (widget.enrollment?.courseTitle != null && widget.enrollment!.courseTitle!.isNotEmpty) {
      return widget.enrollment!.courseTitle!;
    }
    return 'Agricultural Mastery Course';
  }

  String get _certCode {
    if (widget.certificate?.certificateCode != null && widget.certificate!.certificateCode.isNotEmpty) {
      return widget.certificate!.certificateCode;
    }
    final rawId = widget.enrollment?.id ?? 'IAGROW';
    return 'IAG-${rawId.length >= 8 ? rawId.substring(0, 8).toUpperCase() : rawId.toUpperCase()}';
  }

  String get _instructorName {
    if (widget.certificate?.instructorName != null && widget.certificate!.instructorName!.isNotEmpty) {
      return widget.certificate!.instructorName!;
    }
    return 'Lead Agronomist & Course Director';
  }

  String? get _instructorTitle => widget.certificate?.instructorTitle;

  String? get _signatureImage => widget.certificate?.signatureImage;

  String get _issueDate {
    if (widget.certificate?.issuedAt != null) {
      return DateFormat.yMMMMd().format(widget.certificate!.issuedAt!);
    }
    if (widget.enrollment?.enrolledAt != null) {
      return DateFormat.yMMMMd().format(widget.enrollment!.enrolledAt!);
    }
    return DateFormat.yMMMMd().format(DateTime.now());
  }

  String get _verificationUrl {
    if (widget.certificate?.verificationUrl != null && widget.certificate!.verificationUrl!.isNotEmpty) {
      return widget.certificate!.verificationUrl!;
    }
    return 'https://iagrow.zappcode.in/verify/$_certCode';
  }

  Future<void> _shareVerificationLink() async {
    final shareText = '🎓 Verified Certificate of Completion from IAgrow!\n\n'
        'Student: $_studentName\n'
        'Course: $_courseTitle\n'
        'Certificate ID: $_certCode\n\n'
        'Verify Authenticity:\n$_verificationUrl';
    // ignore: deprecated_member_use
    await Share.share(shareText, subject: 'IAgrow Course Certificate: $_courseTitle');
  }

  Future<void> _openVerificationUrl() async {
    final uri = Uri.parse(_verificationUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $_verificationUrl')),
        );
      }
    }
  }

  Future<void> _downloadAndSharePdf() async {
    setState(() => _isGeneratingPdf = true);

    try {
      // 1. Attempt to fetch signature image bytes if available
      Uint8List? signatureBytes;
      if (_signatureImage != null && _signatureImage!.isNotEmpty) {
        try {
          final res = await http.get(Uri.parse(_signatureImage!)).timeout(const Duration(seconds: 6));
          if (res.statusCode == 200) {
            signatureBytes = res.bodyBytes;
          }
        } catch (e) {
          debugPrint('⚠️ [CertificateViewer] Could not fetch signature image: $e');
        }
      }

      // 2. Build PDF Document
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context pCtx) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                color: const PdfColor(0.99, 0.99, 0.98),
                border: pw.Border.all(color: const PdfColor.fromInt(0xFFD4AF37), width: 4),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 24),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Top Header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'IAGROW ACADEMY',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green900,
                              letterSpacing: 2,
                            ),
                          ),
                          pw.Text(
                            'Center for Agricultural Excellence & Training',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.green50,
                          borderRadius: pw.BorderRadius.circular(6),
                          border: pw.Border.all(color: PdfColors.green700, width: 0.8),
                        ),
                        child: pw.Text(
                          'OFFICIAL CERTIFICATE',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Middle Section
                  pw.Column(
                    children: [
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'CERTIFICATE OF COMPLETION',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor(0.545, 0.396, 0.031), // Dark Gold
                          letterSpacing: 1.8,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'This is proudly presented to',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        _studentName,
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Container(
                        margin: const pw.EdgeInsets.symmetric(vertical: 6),
                        width: 140,
                        height: 2,
                        color: const PdfColor.fromInt(0xFFD4AF37),
                      ),
                      pw.Text(
                        'for successfully mastering and completing 100% of the curriculum for',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        _courseTitle,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800,
                        ),
                      ),
                    ],
                  ),

                  // Bottom Signature & Verification
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      // Left: QR Code & Verification
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Container(
                            width: 58,
                            height: 58,
                            padding: const pw.EdgeInsets.all(3),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              border: pw.Border.all(color: PdfColors.grey400),
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: _verificationUrl,
                            ),
                          ),
                          pw.SizedBox(width: 10),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Certificate ID: $_certCode',
                                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                              pw.Text('Issue Date: $_issueDate',
                                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                              pw.Text('Verify at: $_verificationUrl',
                                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.blue800)),
                            ],
                          ),
                        ],
                      ),

                      // Center: Gold Seal
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: const PdfColor(1, 0.98, 0.90),
                          border: pw.Border.all(color: const PdfColor.fromInt(0xFFD4AF37), width: 1.5),
                        ),
                        child: pw.Text(
                          '★ SEAL ★',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor(0.545, 0.396, 0.031),
                          ),
                        ),
                      ),

                      // Right: Instructor Signature
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          if (signatureBytes != null)
                            pw.Container(
                              height: 36,
                              child: pw.Image(pw.MemoryImage(signatureBytes)),
                            )
                          else
                            pw.Container(
                              height: 30,
                              alignment: pw.Alignment.bottomCenter,
                              child: pw.Text(
                                _instructorName,
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontStyle: pw.FontStyle.italic,
                                  color: PdfColors.grey800,
                                ),
                              ),
                            ),
                          pw.Container(
                            margin: const pw.EdgeInsets.only(top: 2, bottom: 4),
                            width: 120,
                            height: 1,
                            color: PdfColors.grey600,
                          ),
                          pw.Text(
                            _instructorName,
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            _instructorTitle ?? 'Lead Instructor & Agronomist',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      final cleanFileName = 'iAgrow_Certificate_${_certCode.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.pdf';

      bool isPublicDownload = false;
      String? savedFilePath;

      if (Platform.isAndroid) {
        // Attempt to save to public Downloads folder so it shows up in phone's Downloads app / File Manager
        final publicDownloadsDir = Directory('/storage/emulated/0/Download');
        if (await publicDownloadsDir.exists()) {
          try {
            final targetFile = File('${publicDownloadsDir.path}/$cleanFileName');
            await targetFile.writeAsBytes(pdfBytes);
            savedFilePath = targetFile.path;
            isPublicDownload = true;
          } catch (e) {
            debugPrint('⚠️ Could not write to public downloads: $e');
          }
        }

        // Fallback to app external or documents directory if public Downloads was restricted
        if (!isPublicDownload) {
          final extDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
          final targetFile = File('${extDir.path}/$cleanFileName');
          await targetFile.writeAsBytes(pdfBytes);
          savedFilePath = targetFile.path;
        }
      } else {
        final docsDir = await getApplicationDocumentsDirectory();
        final targetFile = File('${docsDir.path}/$cleanFileName');
        await targetFile.writeAsBytes(pdfBytes);
        savedFilePath = targetFile.path;
      }

      // Trigger system download notification in the Android Status Bar
      if (savedFilePath != null) {
        await NotificationService.instance.showDownloadNotification(
          fileName: cleanFileName,
          filePath: savedFilePath,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isPublicDownload
                        ? 'Certificate saved to Downloads folder ($cleanFileName)'
                        : 'Certificate saved to device ($cleanFileName)',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.amberAccent,
              onPressed: () {
                Printing.layoutPdf(
                  onLayout: (format) async => pdfBytes,
                  name: cleanFileName,
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Certificate Visual Canvas ────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
                  // Ornamental Inner Border
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'IAGROW ACADEMY',
                                style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Title
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'CERTIFICATE OF COMPLETION',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF8B6508), // Dark Gold
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'This is proudly presented to',
                          style: TextStyle(
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Student Name
                        Text(
                          _studentName,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1E231F),
                            fontWeight: FontWeight.w900,
                            fontSize: 21,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          width: 120,
                          height: 2,
                          color: const Color(0xFFD4AF37),
                        ),

                        // Description
                        const Text(
                          'for successfully mastering and completing all practical lectures & assessments for the course',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 10.5,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Course Title
                        Text(
                          _courseTitle,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Instructor Signature & Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Left: Issue Date & ID
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Issue Date: $_issueDate',
                                    style: const TextStyle(fontSize: 9.5, color: Colors.black54),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'ID: $_certCode',
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      InkWell(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: _certCode));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Certificate Code copied!'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: Icon(Icons.copy_rounded, size: 12, color: Colors.black54),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Center: Golden Stamp Seal
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFFF9E6),
                                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.workspace_premium_rounded,
                                  color: Color(0xFFD4AF37),
                                  size: 24,
                                ),
                              ),
                            ),

                            // Right: Instructor signature
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_signatureImage != null && _signatureImage!.isNotEmpty)
                                    Image.network(
                                      _signatureImage!,
                                      height: 28,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Text(
                                        _instructorName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    )
                                  else
                                    Text(
                                      _instructorName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 2, bottom: 2),
                                    width: 75,
                                    height: 1,
                                    color: Colors.grey.shade400,
                                  ),
                                  Text(
                                    _instructorName,
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_instructorTitle != null)
                                    Text(
                                      _instructorTitle!,
                                      style: const TextStyle(fontSize: 8, color: Colors.black54),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Verification link bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_user_rounded, color: AppColors.primaryGreen, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Public Verification URL: $_verificationUrl',
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              InkWell(
                                onTap: _openVerificationUrl,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(Icons.open_in_new_rounded, size: 13, color: AppColors.primaryGreen),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Action Buttons (Responsive on all screen widths) ────
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;

                final closeBtn = TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                );

                final shareBtn = OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.share_outlined, size: 15),
                  label: const Text('Share Link', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: _shareVerificationLink,
                );

                final downloadBtn = ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _isGeneratingPdf
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                        )
                      : const Icon(Icons.download_rounded, size: 16),
                  label: Text(
                    _isGeneratingPdf ? 'Generating...' : 'Download PDF',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: _isGeneratingPdf ? null : _downloadAndSharePdf,
                );

                if (isCompact) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(child: closeBtn),
                          const SizedBox(width: 8),
                          Expanded(child: shareBtn),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(width: double.infinity, child: downloadBtn),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(flex: 3, child: closeBtn),
                    const SizedBox(width: 8),
                    Expanded(flex: 4, child: shareBtn),
                    const SizedBox(width: 8),
                    Expanded(flex: 5, child: downloadBtn),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
