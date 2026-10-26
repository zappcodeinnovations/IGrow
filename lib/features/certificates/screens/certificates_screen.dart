import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/api_models/certificate_model.dart';
import '../../../data/models/api_models/course_models.dart';
import '../providers/certificates_provider.dart';
import '../widgets/certificate_viewer_dialog.dart';

class CertificatesScreen extends ConsumerStatefulWidget {
  const CertificatesScreen({super.key});

  @override
  ConsumerState<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends ConsumerState<CertificatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showVerifyCertificateDialog() {
    final codeController = TextEditingController();
    bool isChecking = false;
    CertificateVerificationResult? result;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E231F) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sheet Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: AppColors.primaryGreen, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verify Certificate',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Check the authenticity of any IAgrow certificate',
                                style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Input Field
                    TextField(
                      controller: codeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Certificate Code',
                        hintText: 'e.g. IAG-2026-A8F4C2',
                        prefixIcon: const Icon(Icons.qr_code_rounded, color: AppColors.primaryGreen),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.paste_rounded),
                          tooltip: 'Paste from clipboard',
                          onPressed: () async {
                            final data = await Clipboard.getData(Clipboard.kTextPlain);
                            if (data?.text != null) {
                              codeController.text = data!.text!.trim();
                            }
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Verify Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isChecking
                          ? null
                          : () async {
                              final code = codeController.text.trim();
                              if (code.isEmpty) return;

                              setSheetState(() {
                                isChecking = true;
                                result = null;
                              });

                              try {
                                final repo = ref.read(certificateRepositoryProvider);
                                final res = await repo.verifyCertificate(code);
                                setSheetState(() {
                                  result = res;
                                  isChecking = false;
                                });
                              } catch (e) {
                                setSheetState(() {
                                  result = CertificateVerificationResult(
                                    isValid: false,
                                    error: 'Failed to verify certificate. Please check connection.',
                                  );
                                  isChecking = false;
                                });
                              }
                            },
                      child: isChecking
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Verify Authenticity', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),

                    // Result View
                    if (result != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: result!.isValid
                              ? AppColors.primaryGreen.withValues(alpha: 0.08)
                              : AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: result!.isValid ? AppColors.primaryGreen : AppColors.error,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  result!.isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  color: result!.isValid ? AppColors.primaryGreen : AppColors.error,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  result!.isValid ? 'Valid & Authentic Certificate' : 'Invalid Certificate',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: result!.isValid ? AppColors.primaryGreen : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            if (result!.isValid) ...[
                              _buildResultRow('Student Name:', result!.studentName ?? 'N/A'),
                              const SizedBox(height: 6),
                              _buildResultRow('Course:', result!.courseTitle ?? 'N/A'),
                              const SizedBox(height: 6),
                              _buildResultRow('Instructor:', result!.instructorName ?? 'N/A'),
                              const SizedBox(height: 6),
                              _buildResultRow(
                                'Issued Date:',
                                result!.issuedAt != null
                                    ? DateFormat.yMMMMd().format(result!.issuedAt!)
                                    : 'N/A',
                              ),
                              const SizedBox(height: 6),
                              _buildResultRow('Certificate ID:', result!.certificateCode ?? 'N/A'),
                            ] else ...[
                              Text(
                                result!.error ?? 'Certificate not found or invalid verification code.',
                                style: const TextStyle(fontSize: 13, color: AppColors.error),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.inkSoft),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final certificatesAsync = ref.watch(myCertificatesProvider);
    final inProgress = ref.watch(inProgressEnrollmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Certificates', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Verify Certificate',
            onPressed: _showVerifyCertificateDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.inkSoft,
          indicatorColor: AppColors.primaryGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(
              text: certificatesAsync.maybeWhen(
                data: (list) => 'Earned (${list.length})',
                orElse: () => 'Earned',
              ),
            ),
            Tab(text: 'In Progress (${inProgress.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: Official Earned Certificates ───────────────────
          certificatesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Failed to load certificates',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      err.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => ref.invalidate(myCertificatesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            data: (certificates) => _buildCompletedTab(context, certificates, isDark),
          ),

          // ── Tab 2: In Progress Courses ────────────────────────────
          _buildInProgressTab(context, inProgress, isDark),
        ],
      ),
    );
  }

  Widget _buildCompletedTab(
    BuildContext context,
    List<CertificateModel> items,
    bool isDark,
  ) {
    if (items.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: () async => ref.invalidate(myCertificatesProvider),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 80),
            EmptyState(
              icon: Icons.workspace_premium_outlined,
              title: 'No Certificates Earned Yet',
              subtitle: 'Complete 100% of lectures in your enrolled courses to automatically unlock official verified certificates.',
              actionLabel: 'Explore Courses',
              onAction: () => context.go('/farmer/explore'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async => ref.invalidate(myCertificatesProvider),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final cert = items[index];
          final issuedDate = cert.issuedAt != null
              ? DateFormat.yMMMMd().format(cert.issuedAt!)
              : 'Recently Issued';

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
            ),
            color: isDark ? const Color(0xFF1E231F) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Color(0xFFD4AF37),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'OFFICIAL CERTIFICATE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGreen,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  cert.certificateCode,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8B6508),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cert.courseTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.inkSoft),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Recipient: ${cert.studentName}',
                          style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
                        ),
                      ),
                      Text(
                        issuedDate,
                        style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
                      ),
                    ],
                  ),
                  if (cert.instructorName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.school_outlined, size: 14, color: AppColors.inkSoft),
                        const SizedBox(width: 4),
                        Text(
                          'Instructor: ${cert.instructorName}',
                          style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                          label: const Text('View Certificate', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () => CertificateViewerDialog.show(
                            context,
                            certificate: cert,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(color: AppColors.primaryGreen),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          final shareUrl = cert.verificationUrl ??
                              'https://iagrow.zappcode.in/verify/${cert.certificateCode}';
                          // ignore: deprecated_member_use
                          Share.share(
                            '🎓 Check out my verified completion certificate for "${cert.courseTitle}" on IAgrow!\n$shareUrl',
                          );
                        },
                        child: const Icon(Icons.share_rounded, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInProgressTab(
    BuildContext context,
    List<ApiEnrollment> items,
    bool isDark,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 54, color: Colors.grey.shade400),
              const SizedBox(height: 14),
              const Text(
                'No Courses in Progress',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'All enrolled courses are completed or you haven\'t started a course yet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final progress = item.completionPercentage / 100.0;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
          ),
          color: isDark ? const Color(0xFF1E231F) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.courseTitle ?? 'Course',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.completionPercentage.toInt()}% Completed',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                    const Text(
                      'Reach 100% to unlock Certificate',
                      style: TextStyle(fontSize: 11, color: AppColors.inkSoft),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Continue Course'),
                    onPressed: () {
                      final target = item.courseSlug ?? item.course;
                      context.push('/player/$target');
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
