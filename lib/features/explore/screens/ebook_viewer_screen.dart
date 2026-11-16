import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:screen_protector/screen_protector.dart';

import 'package:go_router/go_router.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/app_toast.dart';
import '../../../data/models/api_models/wishlist_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home_farmer/providers/student_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';

/// Secure E-Book reader with live PDF streaming from backend and anti-piracy protection.
class EbookViewerScreen extends ConsumerStatefulWidget {
  final String ebookId;
  const EbookViewerScreen({super.key, required this.ebookId});

  @override
  ConsumerState<EbookViewerScreen> createState() => _EbookViewerScreenState();
}

class _EbookViewerScreenState extends ConsumerState<EbookViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  String? _authToken;
  bool _isLoadingPdf = true;
  String? _pdfLoadError;

  @override
  void initState() {
    super.initState();
    debugPrint('📖 [EBOOK VIEWER] Initializing reader for: ${widget.ebookId}');
    _initScreenProtector();
    _fetchAuthToken();
  }

  Future<void> _initScreenProtector() async {
    try {
      // Prevent screenshots and screen recordings while viewing copyrighted e-books
      await ScreenProtector.preventScreenshotOn();
      await ScreenProtector.protectDataLeakageOn();
      debugPrint('🛡️ [EBOOK VIEWER] DRM Screen protection enabled');
    } catch (e) {
      debugPrint('⚠️ [EBOOK VIEWER] ScreenProtector initialization notice: $e');
    }
  }

  Future<void> _fetchAuthToken() async {
    try {
      final token = await ref.read(tokenStorageProvider).getAccessToken();
      if (mounted) {
        setState(() {
          _authToken = token;
        });
      }
    } catch (e) {
      debugPrint('⚠️ [EBOOK VIEWER] Token fetch notice: $e');
    }
  }

  @override
  void dispose() {
    _disposeScreenProtector();
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> _disposeScreenProtector() async {
    try {
      await ScreenProtector.preventScreenshotOff();
      await ScreenProtector.protectDataLeakageWithColorOff();
      debugPrint('🛡️ [EBOOK VIEWER] DRM Screen protection released');
    } catch (e) {
      debugPrint('⚠️ [EBOOK VIEWER] ScreenProtector cleanup notice: $e');
    }
  }

  void _showEbookInfoDialog(dynamic ebook) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_rounded, color: AppColors.primaryGreen, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ebook.title,
                style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ebook.authorName != null && ebook.authorName!.isNotEmpty) ...[
                Text(
                  'Author: ${ebook.authorName}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
              ],
              if (ebook.instructorName != null && ebook.instructorName!.isNotEmpty) ...[
                Text(
                  'Published by: ${ebook.instructorName}',
                  style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                ),
                const SizedBox(height: 8),
              ],
              const Divider(height: 20),
              Text(
                '${tr(ref, 'Description')}:',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                ebook.description.isNotEmpty ? ebook.description : 'No description provided.',
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkSoft,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, top: 8),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1B4D2E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Close',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ebookAsync = ref.watch(ebookDetailProvider(widget.ebookId));
    final currentUser = ref.watch(authProvider).user;
    final isInstructor = currentUser?.isInstructor == true || currentUser?.isAdmin == true;

    return Scaffold(
      appBar: AppBar(
        title: ebookAsync.maybeWhen(
          data: (ebook) => Text(
            ebook.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          orElse: () => const Text('Reading E-Book'),
        ),
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        elevation: 0.5,
        actions: [
          ebookAsync.maybeWhen(
            data: (ebook) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isInstructor)
                  Consumer(
                    builder: (context, ref, _) {
                      final effectiveId = (ebook.id != null && ebook.id!.isNotEmpty) ? ebook.id! : widget.ebookId;
                      final isSaved = ref.watch(isWishlistedProvider(effectiveId)) ||
                          (ebook.slug != null && ebook.slug!.isNotEmpty && ref.watch(isWishlistedProvider(ebook.slug!))) ||
                          ref.watch(isWishlistedProvider(widget.ebookId));
                      return IconButton(
                        icon: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          color: isSaved ? Colors.redAccent : null,
                        ),
                        tooltip: isSaved ? 'Remove from Wishlist' : 'Add to Wishlist',
                        onPressed: () async {
                          try {
                            final preview = ApiWishlistItem(
                              id: '',
                              targetId: effectiveId,
                              type: 'ebook',
                              title: ebook.title,
                              slug: ebook.slug ?? (widget.ebookId.contains('-') ? widget.ebookId : ''),
                              cover: ebook.coverImage,
                              price: '0.00',
                              category: ebook.category?.toString() ?? 'General',
                              rating: 4.8,
                            );
                            final inWishlist = await ref
                                .read(wishlistProvider.notifier)
                                .toggleEbook(effectiveId, previewItem: preview);
                            if (context.mounted) {
                              AppToast.showWishlistToast(
                                context,
                                isAdded: inWishlist,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString().replaceAll('Exception: ', '')),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded, color: AppColors.primaryGreen),
                  tooltip: 'E-Book Details',
                  onPressed: () => _showEbookInfoDialog(ebook),
                ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ebookAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryGreen),
              const SizedBox(height: 16),
              Text(
                'Opening your e-book...',
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.inkSoft,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_stories_outlined, color: AppColors.accentOrange, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'E-Book Not Found or Unavailable',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This e-book may have been updated, unpublished, or is currently unavailable in the library catalog.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.inkSoft,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => ref.invalidate(ebookDetailProvider(widget.ebookId)),
                      child: const Text('Try Again'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('${RouteNames.explore}?tab=ebooks');
                        }
                      },
                      child: const Text('Browse Library'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        data: (ebook) {
          final isInstructor = currentUser?.isInstructor == true || currentUser?.isAdmin == true;
          final rawPrice = ebook.price ?? '0.00';
          final parsedPrice = double.tryParse(rawPrice) ?? 0.0;
          final isFree = parsedPrice <= 0.0;
          final targetId = (ebook.id != null && ebook.id!.isNotEmpty) ? ebook.id! : widget.ebookId;
          final isPurchased = ebook.isPurchased == true ||
              ref.watch(isEbookPurchasedProvider(targetId)) ||
              (ebook.slug != null && ebook.slug!.isNotEmpty && ref.watch(isEbookPurchasedProvider(ebook.slug!))) ||
              ref.watch(isEbookPurchasedProvider(ebook.title));

          // Access gate: Allow instructors/admins, free books, or purchased books
          if (!isInstructor && !isFree && !isPurchased) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_rounded, color: AppColors.primaryGreen, size: 44),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      ebook.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹$rawPrice',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This premium e-book requires purchase before reading. Unlock lifetime access to all chapters and offline reading.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : AppColors.inkSoft,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => context.push('/checkout?ebookId=$targetId'),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                        label: const Text('Buy Now & Read', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('${RouteNames.explore}?tab=ebooks');
                        }
                      },
                      child: const Text('Back to Catalog'),
                    ),
                  ],
                ),
              ),
            );
          }

          final pdfUrl = ebook.pdfFile;
          if (pdfUrl.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.picture_as_pdf_outlined, color: AppColors.inkSoft, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'PDF File Not Available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'The publisher has not attached a readable PDF for this e-book yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          // Build resolved URL with proper scheme
          final resolvedPdfUrl = pdfUrl.startsWith('http')
              ? pdfUrl
              : 'https://iagrow.zappcode.in${pdfUrl.startsWith('/') ? '' : '/'}$pdfUrl';

          final headers = <String, String>{
            if (_authToken != null && _authToken!.isNotEmpty) 'Authorization': 'Bearer $_authToken',
          };

          return Stack(
            children: [
              SfPdfViewer.network(
                resolvedPdfUrl,
                controller: _pdfViewerController,
                headers: headers.isNotEmpty ? headers : null,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                pageSpacing: 4,
                onDocumentLoaded: (details) {
                  debugPrint('📖 [EBOOK VIEWER] PDF successfully loaded: ${details.document.pages.count} pages');
                  if (mounted && _isLoadingPdf) {
                    setState(() {
                      _isLoadingPdf = false;
                      _pdfLoadError = null;
                    });
                  }
                },
                onDocumentLoadFailed: (details) {
                  debugPrint('❌ [EBOOK VIEWER] PDF load failed: ${details.description}');
                  if (mounted) {
                    setState(() {
                      _isLoadingPdf = false;
                      _pdfLoadError = details.description;
                    });
                  }
                },
              ),
              if (_isLoadingPdf && _pdfLoadError == null)
                Container(
                  color: (isDark ? AppColors.cardDark : Colors.white).withValues(alpha: 0.85),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primaryGreen),
                        SizedBox(height: 14),
                        Text(
                          'Streaming e-book pages...',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_pdfLoadError != null)
                Container(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 42),
                        const SizedBox(height: 12),
                        const Text(
                          'Failed to Display PDF',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _pdfLoadError!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Reload PDF'),
                          onPressed: () {
                            setState(() {
                              _isLoadingPdf = true;
                              _pdfLoadError = null;
                            });
                            ref.invalidate(ebookDetailProvider(widget.ebookId));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
