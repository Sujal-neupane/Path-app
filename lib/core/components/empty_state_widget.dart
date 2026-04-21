import 'package:flutter/material.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/theme/light_colors.dart';

/// Consistent empty state display across all screens
class EmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;
  final String? customTitle;
  final String? customDescription;
  final IconData? customIcon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Color? accentColor;
  final bool showAnimation;

  const EmptyStateWidget({
    super.key,
    required this.type,
    this.customTitle,
    this.customDescription,
    this.customIcon,
    this.onAction,
    this.actionLabel,
    this.accentColor,
    this.showAnimation = true,
  });

  (String title, String description, IconData icon, Color color)
      get _typeConfig {
    final accent = accentColor ?? LightColors.forestPrimary;

    switch (type) {
      case EmptyStateType.noTreks:
        return (
          customTitle ?? 'No Treks Found',
          customDescription ?? 'Start exploring and discover amazing treks',
          customIcon ?? Icons.map_rounded,
          accent,
        );
      case EmptyStateType.noItineraries:
        return (
          customTitle ?? 'No Itineraries',
          customDescription ??
              'Create a custom itinerary from any trek',
          customIcon ?? Icons.edit_calendar_rounded,
          accent,
        );
      case EmptyStateType.noResults:
        return (
          customTitle ?? 'No Results',
          customDescription ??
              'Try adjusting your search or filters',
          customIcon ?? Icons.search_off_rounded,
          accent,
        );
      case EmptyStateType.offline:
        return (
          customTitle ?? 'You\'re Offline',
          customDescription ??
              'Check your internet connection',
          customIcon ?? Icons.cloud_off_rounded,
          Colors.grey,
        );
      case EmptyStateType.noFavorites:
        return (
          customTitle ?? 'No Favorites',
          customDescription ??
              'Save your favorite treks for quick access',
          customIcon ?? Icons.favorite_border_rounded,
          Colors.red.withValues(alpha: 0.6),
        );
      case EmptyStateType.noSaved:
        return (
          customTitle ?? 'Nothing Saved',
          customDescription ??
              'Bookmark treks to access them later',
          customIcon ?? Icons.bookmark_border_rounded,
          accent,
        );
      case EmptyStateType.error:
        return (
          customTitle ?? 'Something Went Wrong',
          customDescription ??
              'We encountered an error. Please try again',
          customIcon ?? Icons.error_outline_rounded,
          LightColors.sosRed,
        );
      case EmptyStateType.noConnection:
        return (
          customTitle ?? 'Connection Error',
          customDescription ??
              'Unable to reach the server. Check your connection',
          customIcon ?? Icons.wifi_off_rounded,
          LightColors.sosRed,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (title, description, icon, color) = _typeConfig;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 40,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: AppTextStyles.h2.copyWith(
                  color: LightColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: LightColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Action button
              if (onAction != null)
                FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    minimumSize: const Size(160, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    actionLabel ?? 'Try Again',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum EmptyStateType {
  noTreks,
  noItineraries,
  noResults,
  offline,
  noFavorites,
  noSaved,
  error,
  noConnection,
}

/// Compact empty state for use in cards or smaller spaces
class CompactEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onAction;
  final String? actionLabel;

  const CompactEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? LightColors.forestPrimary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: LightColors.forestPrimary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: color.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onAction != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                ),
                child: Text(
                  actionLabel ?? 'Action',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state builder for common patterns
class EmptyStateBuilder extends StatelessWidget {
  final bool isEmpty;
  final bool isLoading;
  final String? error;
  final Widget emptyWidget;
  final Widget child;
  final VoidCallback? onRetry;

  const EmptyStateBuilder({
    super.key,
    required this.isEmpty,
    required this.isLoading,
    this.error,
    required this.emptyWidget,
    required this.child,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: LightColors.forestPrimary,
        ),
      );
    }

    if (error != null) {
      return EmptyStateWidget(
        type: EmptyStateType.error,
        customDescription: error,
        onAction: onRetry,
        actionLabel: 'Retry',
      );
    }

    if (isEmpty) {
      return emptyWidget;
    }

    return child;
  }
}
