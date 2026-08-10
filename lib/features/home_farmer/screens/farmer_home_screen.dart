import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/growth_ring_progress.dart';
import '../../../core/widgets/app_card.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/swagger_generated/app_api.swagger.dart';
import '../providers/student_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/shimmer_placeholders.dart';


/// Placeholder farmer/student home dashboard.
///
/// This will be fully built out in Phase 2 with weather, wallet,
/// courses, categories, live classes, etc.
class FarmerHomeScreen extends ConsumerWidget {
  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final userName = (user != null && user.fullName.isNotEmpty) ? user.fullName : 'Ravi Kumar';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning 🌾',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft,),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ],
                    ),
                  ),
                  // Weather Chip
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wb_sunny_rounded,
                          color: AppColors.accentOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('32°C', style: Theme.of(context).textTheme.titleSmall?.copyWith(height: 1)),
                            Text('Pune', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.inkSoft, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Notification bell
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No new notifications')),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.lineDark : AppColors.lineLight,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            color: isDark ? AppColors.white : AppColors.inkDark,
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),


              // Top Instructors Stories
              ref.watch(topInstructorsProvider).when(
                data: (instructors) {
                  if (instructors.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return const Column(
                    children: [
                      _TopInstructorsStories(),
                      SizedBox(height: 28),
                    ],
                  );
                },
                loading: () => const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerContainer(width: 150, height: 24),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        ShimmerContainer(width: 72, height: 72, borderRadius: 36),
                        SizedBox(width: 16),
                        ShimmerContainer(width: 72, height: 72, borderRadius: 36),
                        SizedBox(width: 16),
                        ShimmerContainer(width: 72, height: 72, borderRadius: 36),
                      ],
                    ),
                    SizedBox(height: 28),
                  ],
                ),
                error: (err, _) => const SizedBox.shrink(),
              ),

              // Learning Progress
              ref.watch(studentEnrollmentsProvider).when(
                data: (enrollments) {
                  if (enrollments.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final first = enrollments.first;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Learning Progress', style: Theme.of(context).textTheme.headlineSmall),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Full learning progress list coming soon!')),
                              );
                            },
                            child: Text(
                              'See All',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primaryGreen,),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        child: Row(
                          children: [
                            GrowthRingProgress(
                              percent: ((first.completionPercentage ?? 0) / 100).clamp(0.0, 1.0),
                              size: 80,
                              strokeWidth: 8,
                              label: '${first.completionPercentage?.toInt() ?? 0}%',
                              sublabel: 'Done',
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    first.courseTitle ?? 'Unknown Course',
                                    style: Theme.of(context).textTheme.titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Resume learning',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft,),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => context.push('/player/${first.courseSlug}'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Continue',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.white,),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  );
                },
                loading: () => const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerContainer(width: 180, height: 24),
                    SizedBox(height: 12),
                    ShimmerCard(height: 120),
                    SizedBox(height: 28),
                  ],
                ),
                error: (err, _) => const SizedBox.shrink(),
              ),

              // Featured Courses
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Featured Courses', style: Theme.of(context).textTheme.headlineSmall),
                  TextButton(
                    onPressed: () {
                      context.push('/farmer/explore'); // Navigates to the Explore tab which acts as the catalog
                    },
                    child: Text(
                      'See All',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primaryGreen,),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ref.watch(studentCatalogProvider((search: '', category: ''))).when(
                data: (courses) {
                  if (courses.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        return _CourseCard(course: courses[index], index: index);
                      },
                    ),
                  );
                },
                loading: () => SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) => const ShimmerCourseCard(),
                  ),
                ),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
              const SizedBox(height: 28),

              // Categories
              Text('Categories', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 14),
              ref.watch(studentCategoriesProvider).when(
                data: (categories) {
                  if (categories.isEmpty) return const SizedBox.shrink();
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: categories.map((cat) => _CategoryChip(icon: Icons.label, label: cat.name ?? 'Category')).toList(),
                  );
                },
                loading: () => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(5, (_) => const ShimmerCategoryChip()),
                ),
                error: (err, _) => const Center(child: Text('categories not found')),
              ),
              const SizedBox(height: 28),

              // Daily Tip
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.signalYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppColors.signalYellow,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Daily Tip',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Water your crops early morning to reduce evaporation and improve absorption.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft,),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.index});

  final CourseList course;
  final int index;

  static const _colors = [
    AppColors.primaryGreen,
    AppColors.skyBlue,
    AppColors.accentOrange,
    AppColors.earthBrown,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _colors[index % _colors.length];

    return GestureDetector(
      onTap: () {
        context.push('/farmer/course/${course.id}');
      },
      child: Container(
        width: 170,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.greenShadow(
          blurRadius: 16,
          offset: const Offset(0, 4),
          opacity: isDark ? 0.06 : 0.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail placeholder
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              image: course.thumbnail != null
                  ? DecorationImage(
                      image: NetworkImage(course.thumbnail!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: course.thumbnail == null ? Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 40,
                color: color,
              ),
            ) : null,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: Theme.of(context).textTheme.labelMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: AppColors.signalYellow),
                    const SizedBox(width: 3),
                    Text(
                      '4.5',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Spacer(),
                    Text(
                      course.price == '0.00' ? 'Free' : '₹${course.price}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primaryGreen,),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.lineDark : AppColors.lineLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _InstructorStory {
  final String name;
  final String exp;
  final String imageUrl;

  const _InstructorStory(this.name, this.exp, this.imageUrl);
}

const _topInstructors = [
  _InstructorStory('Ramesh K.', '12 yrs exp', 'https://i.pravatar.cc/150?u=21'),
  _InstructorStory('Suresh S.', '10 yrs exp', 'https://i.pravatar.cc/150?u=22'),
  _InstructorStory('Amit P.', '8 yrs exp', 'https://i.pravatar.cc/150?u=23'),
  _InstructorStory('Vijay M.', '7 yrs exp', 'https://i.pravatar.cc/150?u=24'),
  _InstructorStory('Anil D.', '6 yrs exp', 'https://i.pravatar.cc/150?u=25'),
  _InstructorStory('Kiran R.', '5 yrs exp', 'https://i.pravatar.cc/150?u=26'),
  _InstructorStory('Sunil Y.', '5 yrs exp', 'https://i.pravatar.cc/150?u=27'),
  _InstructorStory('Rajesh T.', '4 yrs exp', 'https://i.pravatar.cc/150?u=28'),
  _InstructorStory('Mohan L.', '3 yrs exp', 'https://i.pravatar.cc/150?u=29'),
  _InstructorStory('Hari G.', '3 yrs exp', 'https://i.pravatar.cc/150?u=30'),
];

class _TopInstructorsStories extends StatefulWidget {
  const _TopInstructorsStories({Key? key}) : super(key: key);

  @override
  State<_TopInstructorsStories> createState() => _TopInstructorsStoriesState();
}

class _TopInstructorsStoriesState extends State<_TopInstructorsStories> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
  }

  void _autoScroll() async {
    while (_isScrolling && mounted) {
      if (_scrollController.hasClients) {
        final double maxScroll = _scrollController.position.maxScrollExtent;
        final double currentScroll = _scrollController.position.pixels;
        
        if (maxScroll > 0) {
          if (currentScroll >= maxScroll - 1) {
            _scrollController.jumpTo(0);
          } else {
            await _scrollController.animateTo(
              currentScroll + 40,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.linear,
            );
          }
        } else {
          await Future.delayed(const Duration(milliseconds: 1000));
        }
      } else {
         await Future.delayed(const Duration(milliseconds: 1000));
      }
    }
  }

  @override
  void dispose() {
    _isScrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  Color _getBadgeColor(int index) {
    if (index == 0) return const Color(0xFFFFD700); // Gold
    if (index == 1) return const Color(0xFFC0C0C0); // Silver
    if (index == 2) return const Color(0xFFCD7F32); // Bronze
    return AppColors.primaryGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Top Instructors', style: Theme.of(context).textTheme.headlineSmall),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Full instructors list coming soon!')),
                );
              },
              child: Text(
                'View All',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primaryGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _topInstructors.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final instructor = _topInstructors[index];
              final isTop3 = index < 3;
              final badgeColor = _getBadgeColor(index);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isTop3 ? LinearGradient(
                        colors: [badgeColor.withValues(alpha: 0.4), badgeColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ) : null,
                      border: !isTop3 ? Border.all(
                        color: badgeColor.withValues(alpha: 0.3),
                        width: 2,
                      ) : null,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage: NetworkImage(instructor.imageUrl),
                          ),
                          if (isTop3)
                            Positioned(
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
                                ),
                                child: Text(
                                  '#${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    instructor.name,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    instructor.exp,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.inkSoft,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

