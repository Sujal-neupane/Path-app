import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/app_theme.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/dark_colors.dart';
import 'package:path_app/features/community/domain/entities/community_post.dart';
import 'package:path_app/features/community/presentation/viewmodels/community_viewmodel.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final colors = theme.colors;

    final feedAsync = ref.watch(communityViewModelProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.primary,
          backgroundColor: colors.surface,
          onRefresh: () =>
              ref.read(communityViewModelProvider.notifier).loadFeed(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Community',
                              style: AppTextStyles.h1.copyWith(
                                color: colors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'SpaceGrotesk',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stories and checkpoints from the trail',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Compose — consistent, discoverable location (Jakob's Law)
                      GestureDetector(
                        onTap: () => _showCreatePostDialog(context),
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'Share',
                                style: AppTextStyles.button.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Feed list
              feedAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: colors.error,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Failed to load feed',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref
                              .read(communityViewModelProvider.notifier)
                              .loadFeed(),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (posts) {
                  if (posts.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No stories shared yet. Be the first!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _PostCard(post: post),
                        );
                      },
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final theme = ref.read(appThemeProvider);
    final colors = theme.colors;
    final isDark = theme.isDark;

    final captionController = TextEditingController();
    String? selectedImageUrl;
    String? selectedRegion;
    bool isPublishing = false;

    final presetImages = [
      {
        'title': 'Everest',
        'url':
            'https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=600',
      },
      {
        'title': 'Annapurna',
        'url':
            'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=600',
      },
      {
        'title': 'Langtang',
        'url':
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=600',
      },
      {
        'title': 'Poon Hill',
        'url':
            'https://images.unsplash.com/photo-1454496522488-7a8e488e8606?q=80&w=600',
      },
    ];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 440,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.8,
                ),
                child: ClayContainer(
                  borderRadius: 24,
                  depth: 8,
                  spread: 4,
                  color: colors.surface,
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                      'Share Your Adventure',
                      style: AppTextStyles.h3.copyWith(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: captionController,
                      maxLines: 4,
                      maxLength: 500,
                      style: TextStyle(color: colors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText:
                            "What's the status on the trail? Share altitude, trail conditions, or advice...",
                        hintStyle: TextStyle(
                          color: colors.textSecondary.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? DarkColors.undergrowth
                            : LightColors.surface95,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Attach a Trail Photo',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: presetImages.length,
                        itemBuilder: (context, idx) {
                          final item = presetImages[idx];
                          final isSelected = selectedImageUrl == item['url'];
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedImageUrl = isSelected
                                    ? null
                                    : item['url'];
                              });
                            },
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? colors.primary
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(item['url']!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tag Region',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: ['Everest', 'Annapurna', 'Langtang'].map((r) {
                        final isSelected = selectedRegion == r;
                        return Padding(
                          padding: EdgeInsets.zero,
                          child: ChoiceChip(
                            label: Text(
                              r,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? Colors.white
                                    : colors.textPrimary,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: colors.primary,
                            backgroundColor: isDark
                                ? DarkColors.undergrowth
                                : LightColors.surface95,
                            checkmarkColor: Colors.white,
                            onSelected: (selected) {
                              setDialogState(() {
                                selectedRegion = selected ? r : null;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isPublishing
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: colors.textSecondary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                          onPressed: isPublishing
                              ? null
                              : () async {
                                  final caption = captionController.text.trim();
                                  if (caption.isEmpty) return;

                                  setDialogState(() {
                                    isPublishing = true;
                                  });

                                  try {
                                    await ref
                                        .read(
                                          communityViewModelProvider.notifier,
                                        )
                                        .createPost(
                                          caption,
                                          imageUrls: selectedImageUrl != null
                                              ? [selectedImageUrl!]
                                              : null,
                                        );
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Story published successfully!',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setDialogState(() {
                                      isPublishing = false;
                                    });
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to publish story: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isPublishing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Publish'),
                          ),
                        ),
                      ],
                    ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PostCard extends ConsumerWidget {
  final CommunityPost post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final colors = theme.colors;
    final isDark = theme.isDark;

    final timeString = _formatTimeAgo(post.createdAt);

    return ClayContainer(
      borderRadius: 20,
      depth: 4,
      spread: 1.5,
      color: isDark ? colors.surface : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? DarkColors.undergrowth
                      : LightColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    post.userName
                        .substring(0, post.userName.length > 1 ? 2 : 1)
                        .toUpperCase(),
                    style: TextStyle(
                      color: isDark
                          ? colors.primary
                          : LightColors.forestPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      fontFamily: 'SpaceGrotesk',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: 'SpaceGrotesk',
                        color: colors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            post.region ?? 'Trail Wilderness',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                timeString,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Caption
          Text(
            post.caption,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Image if present
          if (post.imageUrls.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.network(
                  post.imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: isDark
                        ? DarkColors.undergrowth
                        : LightColors.surface90,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Action row
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(communityViewModelProvider.notifier)
                      .toggleLike(post.id);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: post.isLikedByMe
                        ? colors.error.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        post.isLikedByMe
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        size: 18,
                        color: post.isLikedByMe
                            ? colors.error
                            : colors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${post.likeCount}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: post.isLikedByMe
                              ? colors.error
                              : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${post.commentCount}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
