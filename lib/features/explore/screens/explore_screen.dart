import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/swagger_generated/app_api.swagger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/shell_scaffold.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../../data/models/api_models/course_models.dart' show CourseCategory;
import '../../home_farmer/providers/student_provider.dart';
import 'ebooks_tab.dart';

/// Explore screen matching prototype Screen 12 ("Explore Categories")
/// and Screen 13 ("Search Courses / Filtered Results").
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({
    super.key,
    this.initialSearch,
    this.initialCategory,
    this.initialTab = 0,
    this.initialInstructorId,
  });

  final String? initialSearch;
  final String? initialCategory;
  final int initialTab;
  final String? initialInstructorId;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  int _selectedTab = 0; // 0 = Courses, 1 = E-Books
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String? _selectedInstructorId;
  String _selectedLevel = '';
  String _selectedLanguage = '';
  String _selectedOrdering = '';
  String _selectedPricePreset = 'all';
  String _selectedQuickFilter = 'All';
  num? _minPrice;
  num? _maxPrice;
  double? _minRating;
  final _searchController = TextEditingController();

  /// Returns true when user is browsing the category grid (Screen 12)
  bool get _isCategoriesView =>
      _selectedTab == 0 &&
      _selectedCategory == 'all' &&
      _searchQuery.isEmpty &&
      _activeFilterCount == 0 &&
      _selectedQuickFilter == 'All' &&
      (_selectedInstructorId == null || _selectedInstructorId!.isEmpty);

  int get _activeFilterCount {
    int count = 0;
    if (_selectedLevel.isNotEmpty) count++;
    if (_selectedLanguage.isNotEmpty) count++;
    if (_selectedOrdering.isNotEmpty && _selectedOrdering != '-created_at') count++;
    if (_selectedPricePreset != 'all') count++;
    if (_minRating != null && _minRating! > 0) count++;
    if (_selectedInstructorId != null && _selectedInstructorId!.isNotEmpty) count++;
    return count;
  }

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab.clamp(0, 1);
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _selectedCategory = widget.initialCategory!;
    }
    if (widget.initialInstructorId != null && widget.initialInstructorId!.isNotEmpty) {
      _selectedInstructorId = widget.initialInstructorId;
    }
    if (widget.initialSearch != null && widget.initialSearch!.isNotEmpty) {
      _searchQuery = widget.initialSearch!;
      _searchController.text = widget.initialSearch!;
    }
  }

  @override
  void didUpdateWidget(covariant ExploreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _selectedTab = widget.initialTab.clamp(0, 1);
      });
    }
    if (widget.initialCategory != oldWidget.initialCategory &&
        widget.initialCategory != null &&
        widget.initialCategory!.isNotEmpty) {
      setState(() {
        _selectedCategory = widget.initialCategory!;
      });
    }
    if (widget.initialInstructorId != oldWidget.initialInstructorId) {
      setState(() {
        _selectedInstructorId = widget.initialInstructorId;
      });
    }
    if (widget.initialSearch != oldWidget.initialSearch) {
      setState(() {
        _searchQuery = widget.initialSearch ?? '';
        _searchController.text = widget.initialSearch ?? '';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearchAndFilters() {
    _searchController.clear();
    setState(() {
      _selectedTab = 0;
      _searchQuery = '';
      _selectedCategory = 'all';
      _selectedQuickFilter = 'All';
      _selectedLevel = '';
      _selectedLanguage = '';
      _selectedOrdering = '';
      _selectedPricePreset = 'all';
      _minPrice = null;
      _maxPrice = null;
      _minRating = null;
      _selectedInstructorId = null;
    });
  }

  void _showFilterBottomSheet() {
    String tempLevel = _selectedLevel;
    String tempLanguage = _selectedLanguage;
    String tempOrdering = _selectedOrdering;
    String tempPricePreset = _selectedPricePreset;
    num? tempMinPrice = _minPrice;
    num? tempMaxPrice = _maxPrice;
    double? tempMinRating = _minRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            int getTempCount() {
              int count = 0;
              if (tempLevel.isNotEmpty) count++;
              if (tempLanguage.isNotEmpty) count++;
              if (tempOrdering.isNotEmpty && tempOrdering != '-created_at') count++;
              if (tempPricePreset != 'all') count++;
              if (tempMinRating != null && tempMinRating! > 0) count++;
              return count;
            }

            final tempCount = getTempCount();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.lineDark : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B4D2E).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.tune_rounded, color: Color(0xFF1B4D2E), size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                tr(ref, 'Filter & Sort Courses'),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                              ),
                            ],
                          ),
                          if (tempCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B4D2E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$tempCount ${tr(ref, 'active')}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Rating Filter
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                          const SizedBox(width: 6),
                          Text(tr(ref, 'Minimum Rating'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(tr(ref, 'All Ratings')),
                            selected: tempMinRating == null,
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempMinRating == null ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempMinRating == null ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() => tempMinRating = null);
                              }
                            },
                          ),
                          ...[4.5, 4.0, 3.5, 3.0].map((rating) {
                            final isSelected = tempMinRating == rating;
                            return ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text('${formatNum(ref, rating)} ${tr(ref, '& up')}'),
                                ],
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: isSelected ? const Color(0xFF1B4D2E) : null,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (val) {
                                setModalState(() => tempMinRating = val ? rating : null);
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Price Preset Filter
                      Row(
                        children: [
                          const Icon(Icons.payments_outlined, size: 18, color: Color(0xFF1B4D2E)),
                          const SizedBox(width: 6),
                          Text(tr(ref, 'Price Filter'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(tr(ref, 'All Prices')),
                            selected: tempPricePreset == 'all',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempPricePreset == 'all' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempPricePreset == 'all' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() {
                                  tempPricePreset = 'all';
                                  tempMinPrice = null;
                                  tempMaxPrice = null;
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: Text(tr(ref, 'Free Courses')),
                            selected: tempPricePreset == 'free',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempPricePreset == 'free' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempPricePreset == 'free' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() {
                                  tempPricePreset = 'free';
                                  tempMinPrice = 0;
                                  tempMaxPrice = 0;
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: Text(tr(ref, 'Paid Courses')),
                            selected: tempPricePreset == 'paid',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempPricePreset == 'paid' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempPricePreset == 'paid' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() {
                                  tempPricePreset = 'paid';
                                  tempMinPrice = 1;
                                  tempMaxPrice = null;
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: Text(tr(ref, 'Under ₹500')),
                            selected: tempPricePreset == 'under_500',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempPricePreset == 'under_500' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempPricePreset == 'under_500' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() {
                                  tempPricePreset = 'under_500';
                                  tempMinPrice = 1;
                                  tempMaxPrice = 500;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Skill Level
                      Row(
                        children: [
                          const Icon(Icons.signal_cellular_alt_rounded, size: 18, color: Color(0xFF1B4D2E)),
                          const SizedBox(width: 6),
                          Text(tr(ref, 'Skill Level'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(tr(ref, 'All Levels')),
                            selected: tempLevel.isEmpty,
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLevel.isEmpty ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempLevel.isEmpty ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) setModalState(() => tempLevel = '');
                            },
                          ),
                          ChoiceChip(
                            label: Text(tr(ref, 'Beginner')),
                            selected: tempLevel == 'beginner',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLevel == 'beginner' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempLevel == 'beginner' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempLevel = val ? 'beginner' : '');
                            },
                          ),
                          ChoiceChip(
                            label: Text(tr(ref, 'Intermediate')),
                            selected: tempLevel == 'intermediate',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLevel == 'intermediate' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempLevel == 'intermediate' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempLevel = val ? 'intermediate' : '');
                            },
                          ),
                          ChoiceChip(
                            label: Text(tr(ref, 'Advanced')),
                            selected: tempLevel == 'advanced',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLevel == 'advanced' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempLevel == 'advanced' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempLevel = val ? 'advanced' : '');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Language Filter
                      Row(
                        children: [
                          const Icon(Icons.language_rounded, size: 18, color: Color(0xFF1B4D2E)),
                          const SizedBox(width: 6),
                          Text(tr(ref, 'Language Filter'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(tr(ref, 'All Languages')),
                            selected: tempLanguage.isEmpty,
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLanguage.isEmpty ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempLanguage.isEmpty ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) setModalState(() => tempLanguage = '');
                            },
                          ),
                          ChoiceChip(
                            label: Text(tr(ref, 'Hindi')),
                            selected: tempLanguage == 'Hindi',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLanguage == 'Hindi' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempLanguage == 'Hindi' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempLanguage = val ? 'Hindi' : '');
                            },
                          ),
                          ChoiceChip(
                            label: Text(tr(ref, 'Marathi')),
                            selected: tempLanguage == 'Marathi',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLanguage == 'Marathi' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempLanguage == 'Marathi' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempLanguage = val ? 'Marathi' : '');
                            },
                          ),
                          ChoiceChip(
                            label: Text(tr(ref, 'English')),
                            selected: tempLanguage == 'English',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLanguage == 'English' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempLanguage == 'English' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempLanguage = val ? 'English' : '');
                            },
                          ),
                          ChoiceChip(
                            label: Text(tr(ref, 'Gujarati')),
                            selected: tempLanguage == 'Gujarati',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLanguage == 'Gujarati' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempLanguage == 'Gujarati' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempLanguage = val ? 'Gujarati' : '');
                            },
                          ),
                          ChoiceChip(
                            label: Text(tr(ref, 'Punjabi')),
                            selected: tempLanguage == 'Punjabi',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLanguage == 'Punjabi' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempLanguage == 'Punjabi' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempLanguage = val ? 'Punjabi' : '');
                            },
                          ),
                          ChoiceChip(
                            label: Text(tr(ref, 'Telugu')),
                            selected: tempLanguage == 'Telugu',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLanguage == 'Telugu' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempLanguage == 'Telugu' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempLanguage = val ? 'Telugu' : '');
                            },
                          ),
                          ChoiceChip(
                            label: Text(tr(ref, 'Tamil')),
                            selected: tempLanguage == 'Tamil',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempLanguage == 'Tamil' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempLanguage == 'Tamil' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              setModalState(() => tempLanguage = val ? 'Tamil' : '');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Sort By
                      Row(
                        children: [
                          const Icon(Icons.sort_rounded, size: 18, color: Color(0xFF1B4D2E)),
                          const SizedBox(width: 6),
                          Text(tr(ref, 'Sort by'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(tr(ref, 'Newest')),
                            selected: tempOrdering == '-created_at' || tempOrdering == '',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: (tempOrdering == '-created_at' || tempOrdering == '') ? const Color(0xFF1B4D2E) : null,
                              fontWeight: (tempOrdering == '-created_at' || tempOrdering == '') ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) setModalState(() => tempOrdering = '-created_at');
                            },
                          ),
                          ChoiceChip(
                            label: Text(tr(ref, 'Most Popular')),
                            selected: tempOrdering == '-views_count',
                            selectedColor: const Color(0xFF1B4D2E).withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: tempOrdering == '-views_count' ? const Color(0xFF1B4D2E) : null,
                              fontWeight: tempOrdering == '-views_count' ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) setModalState(() => tempOrdering = '-views_count');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Reset & Apply Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {
                                setModalState(() {
                                  tempLevel = '';
                                  tempLanguage = '';
                                  tempOrdering = '';
                                  tempPricePreset = 'all';
                                  tempMinPrice = null;
                                  tempMaxPrice = null;
                                  tempMinRating = null;
                                });
                              },
                              child: Text(tr(ref, 'Reset All'), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B4D2E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  _selectedLevel = tempLevel;
                                  _selectedLanguage = tempLanguage;
                                  _selectedOrdering = tempOrdering;
                                  _selectedPricePreset = tempPricePreset;
                                  _minPrice = tempMinPrice;
                                  _maxPrice = tempMaxPrice;
                                  _minRating = tempMinRating;
                                });
                              },
                              child: Text(tr(ref, 'Apply Filters'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFFBFBFA),
      appBar: _buildAppBar(context, isDark),
      body: SafeArea(
        child: _isCategoriesView
            ? _buildExploreCategoriesScreen(context, isDark)
            : _buildSearchResultsScreen(context, isDark),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    if (_isCategoriesView) {
      // ── Screen 12 App Bar: "Explore farming topics" ──
      return AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: InkWell(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  context.pop();
                } else if (shellScaffoldKey.currentState != null) {
                  shellScaffoldKey.currentState!.openDrawer();
                } else {
                  Scaffold.of(context).openDrawer();
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.cardDark : const Color(0xFFE8EFE8),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFF1B4D2E),
                ),
              ),
            ),
          ),
        ),
        titleSpacing: 12,
        title: Text(
          tr(ref, 'Explore farming topics'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: isDark ? Colors.white : const Color(0xFF1B4D2E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            color: isDark ? Colors.white70 : const Color(0xFF1B4D2E),
            tooltip: tr(ref, 'Filter Courses'),
            onPressed: _showFilterBottomSheet,
          ),
          const SizedBox(width: 8),
        ],
      );
    }

    // Determine category display name if filtered
    final categories = ref.watch(studentCategoriesProvider).maybeWhen(
          data: (cats) => cats,
          orElse: () => null,
        );
    String? categoryDisplayName;
    if (_selectedCategory != 'all' && categories != null) {
      try {
        final catName = categories
            .firstWhere((c) => c.id == _selectedCategory || c.name.toLowerCase() == _selectedCategory.toLowerCase())
            .name;
        categoryDisplayName = tr(ref, catName);
      } catch (_) {
        categoryDisplayName = tr(ref, _selectedCategory);
      }
    }

    final headerTitle = (categoryDisplayName != null && categoryDisplayName.isNotEmpty)
        ? categoryDisplayName
        : (_selectedTab == 1 ? tr(ref, 'Search E-Books') : tr(ref, 'Search Courses'));

    // ── Screen 13 App Bar: Selected Category Name or "Search Courses" ──
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: InkWell(
            onTap: _clearSearchAndFilters,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.cardDark : const Color(0xFFE8EFE8),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: isDark ? Colors.white : const Color(0xFF1B4D2E),
              ),
            ),
          ),
        ),
      ),
      titleSpacing: 12,
      title: Text(
        headerTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: isDark ? Colors.white : const Color(0xFF1B4D2E),
        ),
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              color: _activeFilterCount > 0 ? AppColors.accentOrange : const Color(0xFF1B4D2E),
              tooltip: 'Filter Courses',
              onPressed: _showFilterBottomSheet,
            ),
            if (_activeFilterCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.accentOrange,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$_activeFilterCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // SCREEN 12: EXPLORE CATEGORIES (Clean Grid View, NO courses below)
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildExploreCategoriesScreen(BuildContext context, bool isDark) {
    final categoriesAsync = ref.watch(studentCategoriesProvider);

    return RefreshIndicator(
      color: const Color(0xFF1B4D2E),
      onRefresh: () async {
        ref.invalidate(studentCategoriesProvider);
        ref.invalidate(studentCatalogProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline matching Screen 12 Prototype
            Text(
              tr(ref, 'What would you like to learn?'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: isDark ? Colors.white : const Color(0xFF1B4D2E),
              ),
            ),
            const SizedBox(height: 16),

            // Segmented switch between Courses and E-Books
            _buildTabSelector(isDark),
            const SizedBox(height: 18),

            // 2-Column Categories Grid
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.category_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            tr(ref, 'No categories found'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    mainAxisExtent: 82,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final iconData = _getCategoryIcon(cat.name);
                    final iconBg = _getCategoryBg(index, isDark);
                    final iconColor = _getCategoryColor(index, isDark);

                    return InkWell(
                      onTap: () {
                        // Transitions into Screen 13 Search / Filtered View for this category
                        setState(() {
                          _selectedCategory = cat.id ?? 'all';
                          _selectedQuickFilter = 'All';
                        });
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? AppColors.lineDark : const Color(0xFFE8EFE8),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: iconBg,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Icon(
                                  iconData,
                                  size: 22,
                                  color: iconColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tr(ref, cat.name),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  height: 1.25,
                                  color: isDark ? Colors.white : const Color(0xFF1B4D2E),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  mainAxisExtent: 82,
                ),
                itemCount: 8,
                itemBuilder: (context, index) => const ShimmerContainer(
                  width: double.infinity,
                  height: 82,
                  borderRadius: 18,
                ),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 40, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        tr(ref, isOfflineOrNetworkError(err) ? 'No internet connection. Please try again later.' : 'Unable to load categories'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(studentCategoriesProvider),
                        child: Text(tr(ref, 'Retry')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(bool isDark) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xFFEFF4F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.lineDark : const Color(0xFFE0ECE2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (_selectedTab != 0) {
                  setState(() {
                    _selectedTab = 0;
                  });
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _selectedTab == 0
                      ? const Color(0xFF1B4D2E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTab == 0
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1B4D2E).withValues(alpha: 0.28),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 16,
                        color: _selectedTab == 0
                            ? Colors.white
                            : (isDark ? Colors.white60 : const Color(0xFF556559)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tr(ref, 'Courses'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w600,
                          color: _selectedTab == 0
                              ? Colors.white
                              : (isDark ? Colors.white70 : const Color(0xFF2C3E30)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () {
                if (_selectedTab != 1) {
                  setState(() {
                    _selectedTab = 1;
                  });
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? const Color(0xFF1B4D2E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTab == 1
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1B4D2E).withValues(alpha: 0.28),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        size: 16,
                        color: _selectedTab == 1
                            ? Colors.white
                            : (isDark ? Colors.white60 : const Color(0xFF556559)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tr(ref, 'E-Books'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w600,
                          color: _selectedTab == 1
                              ? Colors.white
                              : (isDark ? Colors.white70 : const Color(0xFF2C3E30)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // SCREEN 13: SEARCH COURSES / FILTERED RESULTS
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildSearchResultsScreen(BuildContext context, bool isDark) {
    final catalogAsync = ref.watch(studentCatalogProvider(CatalogQuery(
      search: _searchQuery.trim(),
      category: _selectedCategory == 'all' ? '' : _selectedCategory,
      level: _selectedLevel,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      ordering: _selectedOrdering,
      minRating: _minRating,
      instructor: _selectedInstructorId,
    )));

    return RefreshIndicator(
      color: const Color(0xFF1B4D2E),
      onRefresh: () async {
        if (_selectedTab == 1) {
          ref.invalidate(studentEbooksProvider);
        } else {
          ref.invalidate(studentCatalogProvider);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab Switcher (Courses vs E-Books)
            _buildTabSelector(isDark),
            const SizedBox(height: 16),

            // Search Input Field matching Prototype Screen 13
            Text(
              _selectedTab == 1 ? tr(ref, 'Search e-books') : tr(ref, 'Search courses'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.lineDark : const Color(0xFFE5ECE5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF192A1D),
                      ),
                      decoration: InputDecoration(
                        hintText: _selectedTab == 1
                            ? tr(ref, 'Search farming guides, manuals...')
                            : tr(ref, 'Search wheat, soil, irrigation...'),
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: isDark ? Colors.white60 : Colors.black54,
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content based on selected tab
            if (_selectedTab == 1)
              EbooksTab(
                searchQuery: _searchQuery,
                category: _selectedCategory == 'all' ? null : _selectedCategory,
                instructorId: _selectedInstructorId,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              )
            else
              // Results List of Large Course Cards
              catalogAsync.when(
              data: (courses) {
                // Apply language filter (from filter sheet or quick filter)
                var filteredCourses = courses;
                final activeLang = _selectedLanguage.isNotEmpty
                    ? _selectedLanguage
                    : (_selectedQuickFilter != 'All' ? _selectedQuickFilter : '');

                if (activeLang.isNotEmpty) {
                  final lang = activeLang.toLowerCase();
                  filteredCourses = courses.where((c) {
                    final t = c.title.toLowerCase();
                    final desc = (c.shortDescription ?? '').toLowerCase();
                    if (lang == 'hindi') {
                      return t.contains('hindi') || t.contains('हिंदी') || t.contains('हिन्दी') || desc.contains('hindi') || desc.contains('हिंदी');
                    } else if (lang == 'marathi') {
                      return t.contains('marathi') || t.contains('मराठी') || desc.contains('marathi') || desc.contains('मराठी');
                    } else if (lang == 'english') {
                      return t.contains('english') || desc.contains('english') || (!t.contains('hindi') && !t.contains('हिंदी') && !t.contains('marathi') && !t.contains('मराठी'));
                    } else {
                      return t.contains(lang) || desc.contains(lang);
                    }
                  }).toList();
                }

                if (filteredCourses.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2820) : const Color(0xFFE8F3EA),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.menu_book_rounded,
                                size: 38,
                                color: Color(0xFF1B4D2E),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tr(ref, 'No matching courses found'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1B4D2E),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tr(ref, 'Try adjusting your search terms or filters.'),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B4D2E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              elevation: 0,
                            ),
                            onPressed: _clearSearchAndFilters,
                            child: Text(
                              tr(ref, 'Back to Categories'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (int i = 0; i < filteredCourses.length; i++) ...[
                      _PrototypeCourseCard(course: filteredCourses[i], index: i),
                      if (i < filteredCourses.length - 1) const SizedBox(height: 16),
                    ],
                  ],
                );
              },
              loading: () => Column(
                children: const [
                  ShimmerCourseCard(),
                  SizedBox(height: 14),
                  ShimmerCourseCard(),
                ],
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        isOfflineOrNetworkError(err) ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                        size: 36,
                        color: isOfflineOrNetworkError(err) ? Colors.orange : Colors.redAccent,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tr(ref, isOfflineOrNetworkError(err) ? 'No internet connection. Please try again later.' : 'Unable to load results'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(studentCatalogProvider),
                        child: Text(tr(ref, 'Try Again')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('crop') || lower.contains('plant') || lower.contains('prod')) {
      return Icons.agriculture_rounded;
    } else if (lower.contains('water') || lower.contains('irrig') || lower.contains('hydro')) {
      return Icons.water_drop_rounded;
    } else if (lower.contains('pest') || lower.contains('protect')) {
      return Icons.pest_control_rounded;
    } else if (lower.contains('organic') || lower.contains('soil')) {
      return Icons.eco_rounded;
    } else if (lower.contains('animal') || lower.contains('dairy') || lower.contains('husbandry')) {
      return Icons.pets_rounded;
    } else if (lower.contains('tech') || lower.contains('machin')) {
      return Icons.precision_manufacturing_rounded;
    } else if (lower.contains('horticult') || lower.contains('fruit') || lower.contains('veget')) {
      return Icons.local_florist_rounded;
    } else if (lower.contains('climate') || lower.contains('weather')) {
      return Icons.cloud_outlined;
    }
    return Icons.eco_outlined;
  }

  Color _getCategoryBg(int index, bool isDark) {
    if (isDark) return const Color(0xFF1F2D24);
    const tints = [
      Color(0xFFE8F5E9), // Crops / light green
      Color(0xFFE1F5FE), // Water / light cyan
      Color(0xFFE8F8F5), // Pests / light teal
      Color(0xFFF1F8E9), // Organic / light lime
      Color(0xFFFFF3E0), // Animal / light orange
      Color(0xFFF3E5F5), // Tech / light purple
      Color(0xFFFFEBEE), // Horticulture / light pink
      Color(0xFFECEFF1), // Climate / light blue-grey
    ];
    return tints[index % tints.length];
  }

  Color _getCategoryColor(int index, bool isDark) {
    if (isDark) return const Color(0xFF86EFAC);
    const colors = [
      Color(0xFF2E7D32), // Crops
      Color(0xFF0288D1), // Water
      Color(0xFF00897B), // Pests
      Color(0xFF558B2F), // Organic
      Color(0xFFE65100), // Animal
      Color(0xFF7B1FA2), // Tech
      Color(0xFFC2185B), // Horticulture
      Color(0xFF455A64), // Climate
    ];
    return colors[index % colors.length];
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PROTOTYPE COURSE CARD (Matches Screen 11 & Screen 13 Large Card)
// ═════════════════════════════════════════════════════════════════════════════
class _PrototypeCourseCard extends StatelessWidget {
  const _PrototypeCourseCard({required this.course, required this.index});

  final CourseList course;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFree = course.price == null ||
        course.price == '0' ||
        course.price == '0.00' ||
        course.price == '0.0';
    final priceText = isFree ? 'FREE' : '₹${course.price}';
    final categoryName = course.category?.name ??
        CourseCategory.fromValue(course.category?.slug)?.display;
    final badgeLabel = (categoryName != null && categoryName.trim().isNotEmpty)
        ? categoryName.trim()
        : (isFree ? 'Free course' : (index % 2 == 0 ? 'Beginner' : 'Bestseller'));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push('/farmer/course/${course.id}');
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.lineDark : const Color(0xFFE5ECE5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Thumbnail Container with Bestseller/Free Badge
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: isDark ? const Color(0xFF24242A) : const Color(0xFFE9EFE9),
                        child: course.thumbnail != null && course.thumbnail!.isNotEmpty
                            ? Image.network(
                                course.thumbnail!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.spa_rounded,
                                    size: 48,
                                    color: Color(0xFF86EFAC),
                                  ),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.spa_rounded,
                                  size: 48,
                                  color: Color(0xFF86EFAC),
                                ),
                              ),
                      ),
                      // Top Left Badge Pill
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3A2F) : Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            badgeLabel,
                            style: TextStyle(
                              color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF132A13),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Details Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Title
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: -0.3,
                        color: isDark ? Colors.white : const Color(0xFF192A1D),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Instructor Row
                    Text(
                      'By ${course.instructorName ?? "IAGROW Agriculture Experts"}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Rating & Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 17,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '4.8 (248)',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          priceText,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isFree
                                ? const Color(0xFF1B4D2E)
                                : (isDark ? const Color(0xFF86EFAC) : const Color(0xFF1B4D2E)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
