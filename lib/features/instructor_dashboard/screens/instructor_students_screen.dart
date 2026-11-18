import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';
import '../widgets/my_students_sheet.dart';

class InstructorStudentsScreen extends ConsumerStatefulWidget {
  const InstructorStudentsScreen({super.key});

  @override
  ConsumerState<InstructorStudentsScreen> createState() =>
      _InstructorStudentsScreenState();
}

class _InstructorStudentsScreenState
    extends ConsumerState<InstructorStudentsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortMode = 'ALL'; // 'ALL' | 'COURSES' | 'RECENT' | 'NAME'

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
    final transactionsAsync = ref.watch(instructorTransactionsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          tr(ref, 'My Students'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        foregroundColor: isDark ? Colors.white : AppColors.inkDark,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(instructorTransactionsProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: () async {
          ref.invalidate(instructorTransactionsProvider);
          await ref.read(instructorTransactionsProvider.future);
        },
        child: transactionsAsync.when(
          data: (txs) {
            final allStudents = InstructorStudentProfile.groupTransactions(txs);

            // Filter by search query
            final filteredStudents = allStudents.where((student) {
              if (_searchQuery.isEmpty) return true;
              final name = student.name.toLowerCase();
              final email = (student.email ?? '').toLowerCase();
              final phone = (student.phone ?? '').toLowerCase();
              return name.contains(_searchQuery) ||
                  email.contains(_searchQuery) ||
                  phone.contains(_searchQuery);
            }).toList();

            // Sort
            if (_sortMode == 'NAME') {
              filteredStudents.sort(
                  (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
            } else if (_sortMode == 'RECENT') {
              // Transactions order corresponds to recent enrollments
            } else if (_sortMode == 'COURSES') {
              filteredStudents.sort((a, b) => b.coursesCount.compareTo(a.coursesCount));
            } else {
              // Default ALL: sort by courses count then recent
              filteredStudents.sort((a, b) => b.coursesCount.compareTo(a.coursesCount));
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Stats Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.lineDark
                                  : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black26
                                    : const Color(0xFF0F172A)
                                        .withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.skyBlue.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.people_alt_rounded,
                                  color: AppColors.skyBlue,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${formatNum(ref, allStudents.length)} ${tr(ref, 'Total Students')}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.inkDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${formatNum(ref, txs.length)} ${tr(ref, 'enrollments')}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.inkSoft,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Search Bar
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search students by name or email...',
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: AppColors.inkSoft,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.inkSoft,
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: AppColors.inkSoft,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: isDark
                                ? AppColors.cardDark
                                : const Color(0xFFF1F5F9),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.lineDark
                                    : const Color(0xFFE2E8F0),
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

                        const SizedBox(height: 12),

                        // Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildSortChip('ALL', 'All Students', isDark),
                              const SizedBox(width: 8),
                              _buildSortChip('COURSES', 'Most Courses', isDark),
                              const SizedBox(width: 8),
                              _buildSortChip('RECENT', 'Recently Active', isDark),
                              const SizedBox(width: 8),
                              _buildSortChip('NAME', 'Name (A-Z)', isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // List of Students
                if (filteredStudents.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty
                                  ? Icons.search_off_rounded
                                  : Icons.people_outline_rounded,
                              size: 56,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No students found matching "$_searchQuery"'
                                  : 'No students enrolled yet',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Try checking the student name or clearing search.'
                                  : 'When learners enroll in your courses, they will appear here.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.inkSoft,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                child: const Text('Clear Search Filter'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final student = filteredStudents[index];
                          final initial = student.name.isNotEmpty
                              ? student.name[0].toUpperCase()
                              : 'S';
                          final coursesCount = student.coursesCount;
                          final totalSpent = student.totalSpent;
                          final activeDate = student.latestEnrollmentDate;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.lineDark
                                    : const Color(0xFFE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black26
                                      : const Color(0xFF0F172A)
                                          .withValues(alpha: 0.03),
                                  blurRadius: 8,
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
                                      // Avatar
                                      CircleAvatar(
                                        backgroundColor: AppColors.skyBlue
                                            .withValues(alpha: 0.15),
                                        foregroundColor: AppColors.skyBlue,
                                        radius: 24,
                                        child: Text(
                                          initial,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              student.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: isDark
                                                    ? Colors.white
                                                    : AppColors.inkDark,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryGreen
                                                        .withValues(alpha: 0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    coursesCount == 1
                                                        ? '1 Course'
                                                        : '$coursesCount Courses',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.primaryGreen,
                                                    ),
                                                  ),
                                                ),
                                                if (totalSpent > 0)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.skyBlue
                                                          .withValues(alpha: 0.12),
                                                      borderRadius:
                                                          BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      '₹${totalSpent.toStringAsFixed(0)}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors.skyBlue,
                                                      ),
                                                    ),
                                                  ),
                                                Text(
                                                  'Active $activeDate',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.inkSoft,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.grey.shade400,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: filteredStudents.length,
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ShimmerContainer(
                width: double.infinity,
                height: 80,
                borderRadius: 14,
              ),
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unable to load students',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    err.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.invalidate(instructorTransactionsProvider),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String mode, String label, bool isDark) {
    final isSelected = _sortMode == mode;
    return ChoiceChip(
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected
            ? Colors.white
            : (isDark ? Colors.white70 : AppColors.inkDark),
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryGreen,
      backgroundColor:
          isDark ? AppColors.cardDark : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isSelected
            ? AppColors.primaryGreen
            : (isDark ? AppColors.lineDark : const Color(0xFFE2E8F0)),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onSelected: (val) {
        if (val) setState(() => _sortMode = mode);
      },
    );
  }
}
