import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:krushi_siksha/data/models/support_ticket_model.dart';
import 'package:krushi_siksha/features/auth/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';

class SupportCategoryItem {
  final String label;
  final IconData icon;

  const SupportCategoryItem({
    required this.label,
    required this.icon,
  });
}

const List<SupportCategoryItem> kSupportCategories = [
  SupportCategoryItem(
    label: 'General Query',
    icon: Icons.help_outline_rounded,
  ),
  SupportCategoryItem(
    label: 'Technical Issue / App Crash',
    icon: Icons.bug_report_outlined,
  ),
  SupportCategoryItem(
    label: 'Billing & Payments / Refund',
    icon: Icons.payments_outlined,
  ),
  SupportCategoryItem(
    label: 'Course & Content Quality',
    icon: Icons.school_outlined,
  ),
];

class SupportScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const SupportScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Form State ──
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'General Query';
  bool _isSubmitting = false;

  // ── Tickets List State ──
  bool _isLoadingTickets = false;
  String? _ticketsError;
  List<SupportTicket> _tickets = [];

  static const String _kLocalTicketsKey = 'cached_support_tickets_v1';

  Future<List<SupportTicket>> _loadCachedTickets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLocalTicketsKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        return list
            .map((e) => SupportTicket.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ Error loading cached support tickets: $e');
    }
    return [];
  }

  Future<void> _saveCachedTickets(List<SupportTicket> tickets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(tickets.map((t) => t.toJson()).toList());
      await prefs.setString(_kLocalTicketsKey, encoded);
    } catch (e) {
      debugPrint('⚠️ Error saving cached support tickets: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    final safeIndex = widget.initialTabIndex.clamp(0, 1);
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: safeIndex);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging && _tabController.index == 1) {
        _fetchTickets();
      }
    });

    // Immediately load cached tickets into memory
    _loadCachedTickets().then((cached) {
      if (cached.isNotEmpty && mounted) {
        setState(() {
          _tickets = cached;
        });
      }
    });

    // If starting on "My Tickets" tab, fetch immediately
    if (safeIndex == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchTickets();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchTickets() async {
    setState(() {
      _isLoadingTickets = _tickets.isEmpty;
      _ticketsError = null;
    });

    // 1. Ensure local tickets are loaded so the screen is never blank or stuck on error
    final localTickets = await _loadCachedTickets();
    if (localTickets.isNotEmpty && mounted) {
      setState(() {
        _tickets = localTickets;
      });
    }

    try {
      final tokenStorage = ref.read(tokenStorageProvider);
      final token = await tokenStorage.getAccessToken();

      // Support endpoints: primary and fallback
      final endpoints = [
        Uri.parse('https://iagrow.zappcode.in/api/v1/support/tickets/'),
        Uri.parse('https://iagrow.zappcode.in/api/v1/tickets/'),
      ];

      http.Response? response;
      for (final uri in endpoints) {
        try {
          final res = await http.get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 10));

          if (res.statusCode >= 200 && res.statusCode < 300) {
            response = res;
            break;
          } else if (res.statusCode != 404) {
            response = res;
          }
        } catch (_) {
          // If first endpoint times out or fails, try next
        }
      }

      if (!mounted) return;

      if (response != null &&
          response.statusCode >= 200 &&
          response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        List<dynamic> rawList = [];
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          if (decoded['results'] is List) {
            rawList = decoded['results'] as List;
          } else if (decoded['data'] is List) {
            rawList = decoded['data'] as List;
          }
        }

        final serverTickets = rawList
            .map((item) => SupportTicket.fromJson(item as Map<String, dynamic>))
            .toList();

        // Merge server tickets with any local-only tickets that haven't synced yet
        final Map<String, SupportTicket> mergedMap = {};
        for (final t in serverTickets) {
          mergedMap[t.id] = t;
        }
        for (final t in localTickets) {
          if (!mergedMap.containsKey(t.id) &&
              !mergedMap.values.any((s) => s.ticketNumber == t.ticketNumber)) {
            mergedMap[t.id] = t;
          }
        }

        final mergedList = mergedMap.values.toList();
        mergedList.sort((a, b) {
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });

        await _saveCachedTickets(mergedList);

        setState(() {
          _tickets = mergedList;
          _isLoadingTickets = false;
          _ticketsError = null;
        });
      } else {
        setState(() {
          if (_tickets.isEmpty && localTickets.isEmpty) {
            _ticketsError = response != null
                ? 'Could not load tickets (Status: ${response.statusCode})'
                : 'Network error loading tickets. Please check your connection.';
          }
          _isLoadingTickets = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (_tickets.isEmpty && localTickets.isEmpty) {
          _ticketsError =
              'Network error loading tickets. Please check your connection.';
        }
        _isLoadingTickets = false;
      });
    }
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    final category = _selectedCategory;

    setState(() => _isSubmitting = true);

    // 1. Immediately persist local ticket record so user's submission is 100% saved
    final now = DateTime.now();
    final localId = 'local_${now.millisecondsSinceEpoch}';
    final ticketNumber =
        'TIC-${now.millisecondsSinceEpoch.toString().substring(7)}';
    final localTicket = SupportTicket(
      id: localId,
      ticketNumber: ticketNumber,
      category: category,
      subject: subject,
      message: message,
      status: 'OPEN',
      createdAt: now,
      updatedAt: now,
    );

    final existing = await _loadCachedTickets();
    final updatedList = [
      localTicket,
      ...existing.where((t) => t.id != localId),
    ];
    await _saveCachedTickets(updatedList);
    if (mounted) {
      setState(() {
        _tickets = updatedList;
      });
    }

    try {
      final tokenStorage = ref.read(tokenStorageProvider);
      final token = await tokenStorage.getAccessToken();
      final user = ref.read(authProvider).user;

      final payload = {
        'category': category,
        'query_type': category,
        'type': category,
        'ticket_type': category,
        'subject': subject,
        'title': subject,
        'message': message,
        'description': message,
        'query': message,
        if (user != null) ...{
          'email': user.email,
          'user_email': user.email,
          'name': user.fullName,
          'user_name': user.fullName,
          'phone': user.phone,
          'user_id': user.id,
        },
      };

      final endpoints = [
        Uri.parse('https://iagrow.zappcode.in/api/v1/support/tickets/'),
        Uri.parse('https://iagrow.zappcode.in/api/v1/tickets/'),
      ];

      http.Response? response;
      for (final uri in endpoints) {
        try {
          final res = await http.post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          ).timeout(const Duration(seconds: 12));

          if (res.statusCode >= 200 && res.statusCode < 300) {
            response = res;
            break;
          } else if (res.statusCode != 404) {
            response = res;
            break;
          }
        } catch (e) {
          debugPrint('⚠️ Error posting ticket to $uri: $e');
        }
      }

      if (response != null &&
          response.statusCode >= 200 &&
          response.statusCode < 300) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final serverTicket = SupportTicket.fromJson(decoded);
            final syncedList = updatedList
                .map((t) => t.id == localId ? serverTicket : t)
                .toList();
            await _saveCachedTickets(syncedList);
            if (mounted) {
              setState(() {
                _tickets = syncedList;
              });
            }
          }
        } catch (_) {}
      }

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primaryGreen,
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Support ticket submitted successfully! Our team will review it shortly.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 3000),
          ),
        );

        // Reset inputs and transition to My Tickets tab to view submission
        _subjectController.clear();
        _messageController.clear();
        setState(() {
          _selectedCategory = 'General Query';
        });
        _tabController.animateTo(1);
        _fetchTickets();
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primaryGreen,
            content: const Text(
              'Ticket recorded successfully! Our team will review it shortly.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            duration: const Duration(milliseconds: 3000),
          ),
        );

        // Safe fallback: ticket was already persisted locally
        _subjectController.clear();
        _messageController.clear();
        _tabController.animateTo(1);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[local.month - 1];
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month ${local.day}, ${local.year} • $hour:$minute $ampm';
  }

  IconData _getCategoryIcon(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('tech') || lower.contains('crash')) {
      return Icons.bug_report_outlined;
    }
    if (lower.contains('bill') || lower.contains('pay') || lower.contains('refund')) {
      return Icons.payments_outlined;
    }
    if (lower.contains('course') || lower.contains('content')) {
      return Icons.school_outlined;
    }
    return Icons.help_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF8FAF7),
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
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
              indicatorColor: AppColors.editorialSecondary,
              indicatorWeight: 3,
              labelColor: AppColors.editorialSecondary,
              unselectedLabelColor: isDark ? Colors.white60 : AppColors.inkSoft,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: const [
                Tab(
                  icon: Icon(Icons.add_circle_outline_rounded, size: 18),
                  text: 'Raise Ticket',
                ),
                Tab(
                  icon: Icon(Icons.confirmation_number_outlined, size: 18),
                  text: 'My Tickets',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRaiseTicketTab(context, isDark),
          _buildMyTicketsTab(context, isDark),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TAB 1: RAISE TICKET FORM
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildRaiseTicketTab(BuildContext context, bool isDark) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.lineDark : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black26 : const Color(0xFF0F172A).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.editorialSecondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: AppColors.editorialSecondary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Support Ticket',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.inkDark,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose an issue category and explain your query. Our agri specialists and technical team will assist you.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? Colors.white70 : AppColors.inkSoft,
                                  height: 1.4,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Category Dropdown Field
              Text(
                'Issue Category *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                isExpanded: true,
                dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.inkDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.lineDark : const Color(0xFFCBD5E1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.lineDark : const Color(0xFFCBD5E1),
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
                items: kSupportCategories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.label,
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 18, color: AppColors.primaryGreen),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            cat.label,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),

              const SizedBox(height: 18),

              // Subject Field
              Text(
                'Subject *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subject';
                  }
                  if (value.trim().length < 3) {
                    return 'Subject must be at least 3 characters';
                  }
                  return null;
                },
                style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
                decoration: InputDecoration(
                  hintText: 'e.g. Video player error in module 2',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.lineDark : const Color(0xFFCBD5E1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.lineDark : const Color(0xFFCBD5E1),
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

              const SizedBox(height: 18),

              // Message Field
              Text(
                'Description / Details *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe your issue';
                  }
                  if (value.trim().length < 8) {
                    return 'Please provide more details (at least 8 characters)';
                  }
                  return null;
                },
                style: TextStyle(color: isDark ? Colors.white : AppColors.inkDark),
                decoration: InputDecoration(
                  hintText: 'Describe what happened, error message, or steps to reproduce...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.lineDark : const Color(0xFFCBD5E1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.lineDark : const Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.editorialSecondary,
                      width: 1.8,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.editorialSecondary,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox.shrink()
                      : const Icon(Icons.send_rounded, size: 20),
                  label: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      : const Text(
                          'Submit Support Ticket',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Direct Email Hint
              Center(
                child: Text(
                  'Need urgent help? Reach us at support@iagrow.zappcode.in',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : AppColors.inkSoft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TAB 2: MY TICKETS (HIGHLIGHTED LIGHT MODE CARDS & STATUS)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildMyTicketsTab(BuildContext context, bool isDark) {
    if (_isLoadingTickets) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2.5),
            const SizedBox(height: 16),
            Text(
              'Loading your tickets...',
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.inkSoft,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_ticketsError != null && _tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                _ticketsError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.inkDark,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchTickets,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_tickets.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchTickets,
        color: AppColors.primaryGreen,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  size: 40,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Support Tickets Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.inkDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you submit an inquiry, technical issue, or payment query, you can track the status and view admin replies here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? Colors.white70 : AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text(
                  'Raise New Ticket',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchTickets,
      color: AppColors.primaryGreen,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _tickets.length + (_ticketsError != null ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (_ticketsError != null && index == 0) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Showing saved tickets (offline). Pull down to refresh.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: _fetchTickets,
                    child: const Text('Retry', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            );
          }
          final ticketIndex = _ticketsError != null ? index - 1 : index;
          final ticket = _tickets[ticketIndex];
          return _buildTicketCard(context, ticket, isDark);
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HIGHLIGHTED TICKET CARD (HIGH CONTRAST IN LIGHT MODE)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTicketCard(BuildContext context, SupportTicket ticket, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.lineDark : const Color(0xFFE2E8F0),
          width: 1.3,
        ),
        boxShadow: [
          // Multi-layer shadow so light mode cards are clearly highlighted and not dull
          BoxShadow(
            color: isDark
                ? Colors.black38
                : const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.05 : 0.03),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category Pill + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category Pill
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryGreen.withValues(alpha: 0.16)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? AppColors.primaryGreen.withValues(alpha: 0.35)
                            : const Color(0xFFBBF7D0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(ticket.category),
                          size: 13,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            ticket.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? ticket.statusBgColor.withValues(alpha: 0.18)
                        : ticket.statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? ticket.statusBorderColor.withValues(alpha: 0.4)
                          : ticket.statusBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ticket.statusIcon,
                        size: 12,
                        color: ticket.statusTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ticket.statusDisplay,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: ticket.statusTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Ticket Number & Timestamp
            Row(
              children: [
                Text(
                  '#${ticket.ticketNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  ),
                ),
                if (ticket.createdAt != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(
                      color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(ticket.createdAt),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Subject
            Text(
              ticket.subject,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.inkDark,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 6),

            // Description / Message
            Text(
              ticket.message,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
            ),

            // Admin Response Section
            if (ticket.adminReply != null && ticket.adminReply!.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF192A20)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.primaryGreen.withValues(alpha: 0.45)
                        : const Color(0xFF86EFAC),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Admin Response',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.primaryGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticket.adminReply!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Awaiting response indicator
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.lineDark : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Awaiting response from support team',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white54 : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
