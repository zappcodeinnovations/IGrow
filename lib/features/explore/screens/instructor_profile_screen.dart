import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/swagger_generated/app_api.swagger.dart' show EBook;
import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/instructor_model.dart';
import '../../home_farmer/providers/student_provider.dart';

class InstructorProfileScreen extends ConsumerWidget {
  const InstructorProfileScreen({
    super.key,
    required this.instructorId,
    this.fallbackInstructor,
  });

  final String instructorId;
  final ApiTopInstructor? fallbackInstructor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(publicInstructorDetailProvider(instructorId));
    final ebooksAsync = ref.watch(
      studentEbooksProvider(EbooksQuery(instructorId: instructorId)),
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1710) : const Color(0xFFF9FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2822) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : AppColors.inkDark,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ),
        title: Text(
          tr(ref, 'Your instructor'),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.inkDark,
          ),
        ),
        centerTitle: false,
      ),
      body: detailAsync.when(
        data: (detail) {
          if (detail == null && fallbackInstructor == null) {
            return Center(
              child: Text(
                'Instructor details not found.',
                style: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft),
              ),
            );
          }
          return _buildProfileContent(
            context,
            ref,
            detail: detail,
            fallback: fallbackInstructor,
            ebooks: ebooksAsync.value ?? const [],
            isDark: isDark,
          );
        },
        loading: () {
          if (fallbackInstructor != null) {
            return _buildProfileContent(
              context,
              ref,
              detail: null,
              fallback: fallbackInstructor,
              ebooks: ebooksAsync.value ?? const [],
              isDark: isDark,
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        },
        error: (_, __) => _buildProfileContent(
          context,
          ref,
          detail: null,
          fallback: fallbackInstructor,
          ebooks: ebooksAsync.value ?? const [],
          isDark: isDark,
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref, {
    required ApiPublicInstructorDetail? detail,
    required ApiTopInstructor? fallback,
    required List<EBook> ebooks,
    required bool isDark,
  }) {
    final name = detail?.fullName.isNotEmpty == true
        ? detail!.fullName
        : (fallback?.fullName ?? 'Agricultural Instructor');

    final avatarUrl = detail?.avatar ?? fallback?.avatar;

    final specialty = (detail?.specialtyCrops != null && detail!.specialtyCrops!.trim().isNotEmpty)
        ? detail.specialtyCrops!.trim()
        : ((detail?.expertiseTags != null && detail!.expertiseTags!.trim().isNotEmpty)
            ? detail.expertiseTags!.trim()
            : (fallback?.specialtyCrops ?? fallback?.expertiseTags ?? 'Crop production specialist'));

    final experience = detail?.experience.isNotEmpty == true
        ? detail!.experience
        : (fallback?.experience ?? '10+ years experience');

    final rating = detail?.rating ?? fallback?.rating ?? 4.9;
    final studentsCount = detail?.totalStudents ?? fallback?.totalStudents ?? 0;
    final studentsFormatted = studentsCount >= 1000
        ? '${(studentsCount / 1000).toStringAsFixed(studentsCount % 1000 == 0 ? 0 : 1)}k'
        : '$studentsCount';

    final bio = (detail?.bio != null && detail!.bio!.trim().isNotEmpty && detail.bio != '.')
        ? detail.bio!.trim()
        : 'Learn practical, research-backed farming methods with hands-on lessons, modern crop management, and field guidance.';

    final courses = detail?.courses ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),

          // ── 1. Instructor Avatar ──
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD8ECD9),
                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 54,
                          color: AppColors.primaryGreen,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 54,
                        color: AppColors.primaryGreen,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // ── 2. Instructor Name & Specialty Subtitle ──
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.inkDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$specialty • $experience',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // ── 3. Stats Card (Rating & Students) ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF19251C) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF2C3C2F) : const Color(0xFFE5E7EB),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr(ref, 'Rating'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        studentsFormatted,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr(ref, 'Students'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),

          // ── 4. About Instructor ──
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              tr(ref, 'About instructor'),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.inkDark,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              bio,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                height: 1.5,
                color: isDark ? Colors.white70 : AppColors.inkSoft,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── 5. Courses Directly Under About Instructor ──
          if (courses.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tr(ref, 'Courses'),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
              ),
            ),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = courses[index];
                return InkWell(
                  onTap: () {
                    final targetSlug = (c.slug != null && c.slug!.isNotEmpty) ? c.slug! : c.id;
                    context.push('/course/$targetSlug');
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF19251C) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2C3C2F) : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 64,
                            height: 64,
                            color: isDark ? const Color(0xFF142017) : Colors.grey.shade200,
                            child: c.thumbnail != null && c.thumbnail!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: c.thumbnail!,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.image_not_supported_rounded,
                                      color: Colors.grey,
                                    ),
                                  )
                                : const Icon(
                                    Icons.school_rounded,
                                    color: AppColors.primaryGreen,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.inkDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    c.price != null && double.tryParse(c.price!) != 0
                                        ? '₹${c.price}'
                                        : 'Free',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                  if (c.level != null && c.level!.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '•  ${c.level!.toUpperCase()}',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // ── 6. E-Books Directly Under Courses ──
          if (ebooks.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tr(ref, 'E-Books'),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
              ),
            ),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ebooks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final eb = ebooks[index];
                return InkWell(
                  onTap: () {
                    final targetId = (eb.id != null && eb.id!.isNotEmpty)
                        ? eb.id!
                        : (eb.slug ?? '');
                    if (targetId.isNotEmpty) {
                      context.push('/farmer/ebook/$targetId');
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF19251C) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2C3C2F) : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 64,
                            height: 64,
                            color: isDark ? const Color(0xFF142017) : Colors.grey.shade200,
                            child: eb.coverImage != null && eb.coverImage!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: eb.coverImage!,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.menu_book_rounded,
                                      color: Colors.grey,
                                    ),
                                  )
                                : const Icon(
                                    Icons.menu_book_rounded,
                                    color: AppColors.primaryGreen,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eb.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.inkDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    eb.price != null && double.tryParse(eb.price!) != 0
                                        ? '₹${eb.price}'
                                        : 'Free',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                  if (eb.authorName.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '•  ${eb.authorName}',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}


