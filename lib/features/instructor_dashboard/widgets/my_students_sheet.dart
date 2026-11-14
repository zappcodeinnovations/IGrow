import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';

/// Represents a distinct student enrolled with an instructor,
/// aggregating all their individual course enrollments and activities.
class InstructorStudentProfile {
  final String name;
  final String? email;
  final String? phone;
  final String? avatar;
  final List<Map<String, dynamic>> enrollments;

  InstructorStudentProfile({
    required this.name,
    this.email,
    this.phone,
    this.avatar,
    required this.enrollments,
  });

  int get coursesCount => enrollments.length;

  double get totalSpent {
    double sum = 0;
    for (final e in enrollments) {
      final a = num.tryParse(e['amount']?.toString() ?? '0') ?? 0;
      sum += a.toDouble();
    }
    return sum;
  }

  String get latestEnrollmentDate {
    if (enrollments.isEmpty) return 'Recently';
    return enrollments.first['date']?.toString() ??
        enrollments.first['created_at']?.toString() ??
        'Recently';
  }

  String get earliestEnrollmentDate {
    if (enrollments.isEmpty) return 'Recently';
    return enrollments.last['date']?.toString() ??
        enrollments.last['created_at']?.toString() ??
        'Recently';
  }

  /// Groups raw transactions/enrollments into distinct student profiles.
  static List<InstructorStudentProfile> groupTransactions(
      List<Map<String, dynamic>> txs) {
    final Map<String, List<Map<String, dynamic>>> map = {};

    for (final tx in txs) {
      final rawBuyer = (tx['buyer'] ??
              tx['student_name'] ??
              tx['user_name'] ??
              tx['buyer_name'] ??
              'Student')
          .toString()
          .trim();
      if (rawBuyer.isEmpty) continue;
      final key = rawBuyer.toLowerCase();
      map.putIfAbsent(key, () => []).add(tx);
    }

    final List<InstructorStudentProfile> students = [];
    map.forEach((key, list) {
      final first = list.first;
      final name = (first['buyer'] ??
              first['student_name'] ??
              first['user_name'] ??
              first['buyer_name'] ??
              'Student')
          .toString()
          .trim();
      final email = first['email'] ??
          first['buyer_email'] ??
          first['user_email'] ??
          first['student_email'];
      final phone = first['phone'] ??
          first['buyer_phone'] ??
          first['phone_number'] ??
          first['student_phone'];
      final avatar = first['avatar'] ??
          first['buyer_avatar'] ??
          first['user_avatar'] ??
          first['student_avatar'];

      students.add(
        InstructorStudentProfile(
          name: name,
          email: email?.toString(),
          phone: phone?.toString(),
          avatar: avatar?.toString(),
          enrollments: list,
        ),
      );
    });

    // Default sort: highest number of enrolled courses first
    students.sort((a, b) => b.coursesCount.compareTo(a.coursesCount));
    return students;
  }
}

/// The main "My Students" bottom sheet displaying only distinct students.
class MyStudentsSheet extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final int totalStudents;
  final int totalEnrollments;
  final ScrollController scrollController;
  final VoidCallback? onOpenLedger;
  final VoidCallback? onViewAll;

  const MyStudentsSheet({
    super.key,
    required this.transactions,
    required this.totalStudents,
    required this.totalEnrollments,
    required this.scrollController,
    this.onOpenLedger,
    this.onViewAll,
  });

  @override
  ConsumerState<MyStudentsSheet> createState() => _MyStudentsSheetState();
}

class _MyStudentsSheetState extends ConsumerState<MyStudentsSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final String _sortMode = 'COURSES';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showStudentDetails(BuildContext context, InstructorStudentProfile student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StudentDetailsSheet(student: student),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allStudents = InstructorStudentProfile.groupTransactions(widget.transactions);
    final displayStudentCount = allStudents.isNotEmpty ? allStudents.length : widget.totalStudents;
    final displayEnrollmentCount = widget.transactions.isNotEmpty ? widget.transactions.length : widget.totalEnrollments;

    // Filter students by search
    final filteredStudents = allStudents.where((s) {
      if (_searchQuery.isEmpty) return true;
      final name = s.name.toLowerCase();
      final email = (s.email ?? '').toLowerCase();
      return name.contains(_searchQuery) || email.contains(_searchQuery);
    }).toList();

    // Sort students
    if (_sortMode == 'NAME') {
      filteredStudents.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (_sortMode == 'RECENT') {
      // Recent stays in transaction arrival order
    } else {
      filteredStudents.sort((a, b) => b.coursesCount.compareTo(a.coursesCount));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ListView(
        controller: widget.scrollController,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Icon + Title + Counts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: AppColors.skyBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(ref, 'My Students'),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${formatNum(ref, displayStudentCount)} ${tr(ref, 'Total Students').toLowerCase()} • ${formatNum(ref, displayEnrollmentCount)} ${tr(ref, 'enrollments')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const Divider(height: 24),

          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: tr(ref, 'Search students by name...'),
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                fontSize: 13,
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              filled: true,
              fillColor: isDark ? AppColors.cardDark : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.lineDark : const Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.lineDark : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.8,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Section Label & View All Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${tr(ref, 'Enrolled Students')} (${formatNum(ref, filteredStudents.length)})',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  if (widget.onViewAll != null) {
                    widget.onViewAll!();
                  } else {
                    Navigator.pop(context);
                    context.push(RouteNames.instructorStudents);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tr(ref, 'View All'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.primaryGreen,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Distinct Students List or Empty State
          if (filteredStudents.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _searchQuery.isNotEmpty
                          ? '${tr(ref, 'No student found matching')} "$_searchQuery"'
                          : tr(ref, 'No students enrolled yet'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _searchQuery.isNotEmpty
                          ? tr(ref, 'Check the name spelling or clear the search.')
                          : tr(ref, 'When students purchase your courses or e-books, they will appear here.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Column(
              children: filteredStudents.map((student) {
                final initial = student.name.isNotEmpty
                    ? student.name[0].toUpperCase()
                    : 'S';
                final coursesCount = student.coursesCount;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.lineDark : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black26
                            : const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _showStudentDetails(context, student),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            // Student Avatar
                            CircleAvatar(
                              backgroundColor: AppColors.skyBlue.withValues(alpha: 0.15),
                              foregroundColor: AppColors.skyBlue,
                              radius: 22,
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Student Name & Activity Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark ? Colors.white : AppColors.inkDark,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          coursesCount == 1 ? '1 ${tr(ref, 'Course')}' : '${formatNum(ref, coursesCount)} ${tr(ref, 'Courses')}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '• ${tr(ref, 'Active')} ${student.latestEnrollmentDate}',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: isDark ? Colors.white54 : AppColors.inkSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Right Arrow indicator
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: isDark ? Colors.white38 : Colors.grey.shade400,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// The dedicated Student Details bottom sheet opened when tapping any student.
class StudentDetailsSheet extends ConsumerWidget {
  final InstructorStudentProfile student;

  const StudentDetailsSheet({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial = student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Student Profile Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.skyBlue.withValues(alpha: 0.15),
                    foregroundColor: AppColors.skyBlue,
                    radius: 28,
                    child: Text(
                      initial,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tr(ref, 'Active Enrolled Student'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        if (student.email != null && student.email!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            student.email!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Summary Metrics Row
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.lineDark : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(
                      label: tr(ref, 'Enrolled Courses'),
                      value: formatNum(ref, student.coursesCount),
                      icon: Icons.school_rounded,
                      color: AppColors.skyBlue,
                    ),
                    Container(width: 1, height: 32, color: Colors.grey.withValues(alpha: 0.2)),
                    _buildMetricItem(
                      label: tr(ref, 'Total Paid'),
                      value: '₹${formatNum(ref, student.totalSpent.toStringAsFixed(0))}',
                      icon: Icons.payments_rounded,
                      color: AppColors.primaryGreen,
                    ),
                    Container(width: 1, height: 32, color: Colors.grey.withValues(alpha: 0.2)),
                    _buildMetricItem(
                      label: tr(ref, 'First Active'),
                      value: student.earliestEnrollmentDate.split(' ').first,
                      icon: Icons.event_rounded,
                      color: AppColors.signalYellow,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Enrolled Courses List
              Text(
                '${tr(ref, 'Enrolled Courses')} (${formatNum(ref, student.coursesCount)})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ...student.enrollments.map((enr) {
                final course = enr['course_title'] ?? enr['item'] ?? enr['description'] ?? 'Enrolled Course';
                final date = enr['date'] ?? enr['created_at'] ?? 'Recently';
                final amount = enr['amount'] != null ? '₹${enr['amount']}' : '₹0.00';
                final paymentMethod = enr['payment_method'] ?? enr['payment_mode'] ?? 'Online';
                final txnId = enr['id'] ?? enr['transaction_id'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.lineDark : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.play_lesson_rounded,
                          color: AppColors.primaryGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Enrolled: $date • $paymentMethod${txnId.toString().isNotEmpty ? ' • #$txnId' : ''}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : AppColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        amount,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Activity History
              Text(
                'Student Activity Timeline',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...student.enrollments.map((enr) {
                final course = enr['course_title'] ?? enr['item'] ?? 'Course';
                final date = enr['date'] ?? enr['created_at'] ?? 'Recently';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primaryGreen),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : AppColors.inkDark,
                            ),
                            children: [
                              const TextSpan(text: 'Enrolled in '),
                              TextSpan(
                                text: '$course',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: ' on $date',
                                style: const TextStyle(color: AppColors.inkSoft),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
        ),
      ],
    );
  }
}
