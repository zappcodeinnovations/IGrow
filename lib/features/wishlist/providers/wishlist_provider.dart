import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/api_models/wishlist_model.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for WishlistRepository.
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository(
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// Reactive StateNotifier for Wishlist items.
class WishlistNotifier extends StateNotifier<AsyncValue<List<ApiWishlistItem>>> {
  WishlistNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadWishlist();
  }

  final Ref ref;

  Future<void> loadWishlist() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(wishlistRepositoryProvider);
      final items = await repo.getWishlist();
      state = AsyncValue.data(items);
    } catch (e, st) {
      debugPrint('❌ [WishlistNotifier] loadWishlist error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// Toggle a course in the wishlist. Returns true if now in wishlist, false if removed.
  Future<bool> toggleCourse(String courseId, {ApiWishlistItem? previewItem}) async {
    final currentList = List<ApiWishlistItem>.from(state.value ?? []);
    final existingIndex = currentList.indexWhere(
      (item) =>
          item.targetId == courseId ||
          item.id == courseId ||
          item.slug == courseId ||
          (previewItem != null &&
              ((previewItem.targetId.isNotEmpty && item.targetId == previewItem.targetId) ||
                  (previewItem.slug.isNotEmpty && item.slug == previewItem.slug))),
    );

    final isCurrentlyInWishlist = existingIndex >= 0;
    final existingItem = isCurrentlyInWishlist ? currentList[existingIndex] : null;

    // Optimistic local state update
    if (isCurrentlyInWishlist) {
      currentList.removeAt(existingIndex);
      state = AsyncValue.data(currentList);
    } else if (previewItem != null) {
      currentList.insert(0, previewItem);
      state = AsyncValue.data(currentList);
    }

    try {
      final repo = ref.read(wishlistRepositoryProvider);

      if (isCurrentlyInWishlist) {
        // Prefer dedicated DELETE endpoint for clean removal without 500 server crashes
        final removeKey = (existingItem?.id.isNotEmpty == true)
            ? existingItem!.id
            : (existingItem?.targetId.isNotEmpty == true ? existingItem!.targetId : courseId);

        bool removed = false;
        try {
          removed = await repo.removeFromWishlist(removeKey);
        } catch (_) {}

        if (!removed && existingItem?.targetId.isNotEmpty == true && existingItem!.targetId != removeKey) {
          try {
            removed = await repo.removeFromWishlist(existingItem.targetId);
          } catch (_) {}
        }

        if (!removed) {
          final result = await repo.toggleWishlist(courseId: courseId);
          if (result.inWishlist) {
            await loadWishlist();
            return true;
          }
        }

        currentList.removeWhere(
          (item) => item.targetId == courseId || item.id == courseId || item.slug == courseId,
        );
        state = AsyncValue.data(currentList);
        return false;
      }

      final result = await repo.toggleWishlist(courseId: courseId);
      
      // If server confirmed addition and returned an ID, update the local item's ID
      if (result.inWishlist) {
        if (result.id != null && result.id!.isNotEmpty && currentList.isNotEmpty) {
          final idx = currentList.indexWhere(
            (item) => item.targetId == courseId || item.id == courseId || item.slug == courseId,
          );
          if (idx >= 0) {
            final old = currentList[idx];
            currentList[idx] = ApiWishlistItem(
              id: result.id!,
              targetId: old.targetId.isNotEmpty ? old.targetId : courseId,
              type: old.type,
              title: old.title,
              slug: old.slug,
              thumbnail: old.thumbnail,
              cover: old.cover,
              price: old.price,
              category: old.category,
              rating: old.rating,
              addedAt: old.addedAt ?? DateTime.now(),
            );
            state = AsyncValue.data(currentList);
          }
        } else if (!isCurrentlyInWishlist && previewItem == null) {
          // Re-fetch from server to get full item details
          await loadWishlist();
        }
      } else {
        // Server says it's removed; ensure it's removed locally
        currentList.removeWhere(
          (item) => item.targetId == courseId || item.id == courseId || item.slug == courseId,
        );
        state = AsyncValue.data(currentList);
      }
      return result.inWishlist;
    } catch (e) {
      debugPrint('⚠️ [WishlistNotifier] toggleCourse error: $e');
      // Revert to server state on error
      await loadWishlist();
      rethrow;
    }
  }

  /// Toggle an e-book in the wishlist. Returns true if now in wishlist, false if removed.
  Future<bool> toggleEbook(String ebookId, {ApiWishlistItem? previewItem}) async {
    final currentList = List<ApiWishlistItem>.from(state.value ?? []);
    final existingIndex = currentList.indexWhere(
      (item) =>
          item.targetId == ebookId ||
          item.id == ebookId ||
          item.slug == ebookId ||
          (previewItem != null &&
              ((previewItem.targetId.isNotEmpty && item.targetId == previewItem.targetId) ||
                  (previewItem.slug.isNotEmpty && item.slug == previewItem.slug))),
    );

    final isCurrentlyInWishlist = existingIndex >= 0;
    final existingItem = isCurrentlyInWishlist ? currentList[existingIndex] : null;

    // Optimistic local update
    if (isCurrentlyInWishlist) {
      currentList.removeAt(existingIndex);
      state = AsyncValue.data(currentList);
    } else if (previewItem != null) {
      currentList.insert(0, previewItem);
      state = AsyncValue.data(currentList);
    }

    try {
      final repo = ref.read(wishlistRepositoryProvider);

      if (isCurrentlyInWishlist) {
        final removeKey = (existingItem?.id.isNotEmpty == true)
            ? existingItem!.id
            : (existingItem?.targetId.isNotEmpty == true ? existingItem!.targetId : ebookId);

        bool removed = false;
        try {
          removed = await repo.removeFromWishlist(removeKey);
        } catch (_) {}

        if (!removed && existingItem?.targetId.isNotEmpty == true && existingItem!.targetId != removeKey) {
          try {
            removed = await repo.removeFromWishlist(existingItem.targetId);
          } catch (_) {}
        }

        if (!removed) {
          final result = await repo.toggleWishlist(ebookId: ebookId);
          if (result.inWishlist) {
            await loadWishlist();
            return true;
          }
        }

        currentList.removeWhere(
          (item) => item.targetId == ebookId || item.id == ebookId || item.slug == ebookId,
        );
        state = AsyncValue.data(currentList);
        return false;
      }

      final result = await repo.toggleWishlist(ebookId: ebookId);

      if (result.inWishlist) {
        if (result.id != null && result.id!.isNotEmpty && currentList.isNotEmpty) {
          final idx = currentList.indexWhere(
            (item) => item.targetId == ebookId || item.id == ebookId || item.slug == ebookId,
          );
          if (idx >= 0) {
            final old = currentList[idx];
            currentList[idx] = ApiWishlistItem(
              id: result.id!,
              targetId: old.targetId.isNotEmpty ? old.targetId : ebookId,
              type: old.type,
              title: old.title,
              slug: old.slug,
              thumbnail: old.thumbnail,
              cover: old.cover,
              price: old.price,
              category: old.category,
              rating: old.rating,
              addedAt: old.addedAt ?? DateTime.now(),
            );
            state = AsyncValue.data(currentList);
          }
        } else if (!isCurrentlyInWishlist && previewItem == null) {
          await loadWishlist();
        }
      } else {
        currentList.removeWhere(
          (item) => item.targetId == ebookId || item.id == ebookId || item.slug == ebookId,
        );
        state = AsyncValue.data(currentList);
      }
      return result.inWishlist;
    } catch (e) {
      debugPrint('⚠️ [WishlistNotifier] toggleEbook error: $e');
      await loadWishlist();
      rethrow;
    }
  }

  /// Remove an item by its ID or target ID.
  Future<bool> removeItem(String idOrTargetId) async {
    final currentList = List<ApiWishlistItem>.from(state.value ?? []);
    currentList.removeWhere(
      (item) => item.id == idOrTargetId || item.targetId == idOrTargetId || item.slug == idOrTargetId,
    );
    state = AsyncValue.data(currentList);

    try {
      final repo = ref.read(wishlistRepositoryProvider);
      return await repo.removeFromWishlist(idOrTargetId);
    } catch (e) {
      debugPrint('⚠️ [WishlistNotifier] removeItem error: $e');
      await loadWishlist();
      return false;
    }
  }
}

/// Global provider for wishlist items.
final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, AsyncValue<List<ApiWishlistItem>>>((ref) {
  return WishlistNotifier(ref);
});

/// Family provider to check if a specific course or ebook ID is currently in the wishlist.
final isWishlistedProvider = Provider.family<bool, String>((ref, targetId) {
  final wishlistAsync = ref.watch(wishlistProvider);
  return wishlistAsync.maybeWhen(
    data: (items) => items.any(
      (item) => item.targetId == targetId || item.id == targetId || item.slug == targetId,
    ),
    orElse: () => false,
  );
});

/// Provider for total count of saved wishlist items.
final wishlistCountProvider = Provider<int>((ref) {
  final wishlistAsync = ref.watch(wishlistProvider);
  return wishlistAsync.maybeWhen(
    data: (items) => items.length,
    orElse: () => 0,
  );
});
