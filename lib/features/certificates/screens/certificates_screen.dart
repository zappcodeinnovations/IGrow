import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_error_state.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final certificatesAsync = ref.watch(myCertificatesProvider);
    final inProgress = ref.watch(inProgressEnrollmentsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.editorialSurfaceDark : AppColors.editorialSurface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: false,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              backgroundColor: isDark ? AppColors.editorialSurfaceDark : AppColors.editorialSurface,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        context.go('/farmer/profile');
                      }
                    },
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLow,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: isDark ? Colors.white : AppColors.editorialOnSurface,
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                tr(ref, 'My Certificates'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : AppColors.editorialOnSurface,
                  letterSpacing: -0.4,
                ),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.lineDark : AppColors.lineLight,
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: isDark ? Colors.white : AppColors.editorialSecondary,
                    unselectedLabelColor: isDark ? Colors.white54 : AppColors.inkSoft,
                    indicatorColor: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: [
                      Tab(
                        text: certificatesAsync.maybeWhen(
                          data: (list) => '${tr(ref, 'Earned')} (${formatNum(ref, list.length)})',
                          orElse: () => tr(ref, 'Earned'),
                        ),
                      ),
                      Tab(text: '${tr(ref, 'In Progress')} (${formatNum(ref, inProgress.length)})'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── Tab 1: Official Earned Certificates ───────────────────
            certificatesAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        tr(ref, getUserFriendlyErrorMessage(err)),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AppColors.inkSoft,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.editorialSecondary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(tr(ref, 'Retry')),
                        onPressed: () => ref.invalidate(myCertificatesProvider),
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
                                    color: isDark
                                        ? AppColors.editorialSecondary.withValues(alpha: 0.25)
                                        : AppColors.editorialSecondaryFixed,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tr(ref, 'OFFICIAL CERTIFICATE'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.editorialSecondaryFixedDim
                                          : AppColors.editorialSecondary,
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 15,
                                color: isDark ? Colors.white : AppColors.editorialOnSurface,
                              ),
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
                          '${tr(ref, 'Recipient:')} ${cert.studentName}',
                          style: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft, fontSize: 12),
                        ),
                      ),
                      Text(
                        issuedDate,
                        style: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft, fontSize: 12),
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
                          '${tr(ref, 'Instructor:')} ${cert.instructorName}',
                          style: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft, fontSize: 12),
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
                            backgroundColor: AppColors.editorialSecondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                          label: Text(tr(ref, 'View Certificate'), style: const TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () => CertificateViewerDialog.show(
                            context,
                            certificate: cert,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : AppColors.editorialSecondary,
                          side: BorderSide(
                            color: isDark ? AppColors.lineDark : AppColors.editorialSecondary.withValues(alpha: 0.5),
                          ),
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
              Text(
                tr(ref, 'No Courses in Progress'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                tr(ref, 'All enrolled courses are completed or you haven\'t started a course yet.'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
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
                  item.courseTitle ?? tr(ref, 'Courses'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${formatNum(ref, item.completionPercentage.toInt())}% ${tr(ref, 'Completed')}',
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold, 
                        color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                      ),
                    ),
                    Text(
                      tr(ref, 'Reach 100% to unlock Certificate'),
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppColors.inkSoft),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : AppColors.editorialSecondary,
                      side: BorderSide(
                        color: isDark ? AppColors.lineDark : AppColors.editorialSecondary.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: Text(tr(ref, 'Continue Course')),
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
