import 'package:json_annotation/json_annotation.dart';

part 'paginated_response.g.dart';

/// Generic paginated response model
/// Supports pagination for any data type
/// 
/// Features:
/// - Type-safe pagination
/// - Cursor-based or offset-based pagination
/// - Metadata about total count and has more
/// - Ready for backend implementation
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  /// Items in current page
  final List<T> items;

  /// Total number of items available
  final int total;

  /// Whether there are more items to fetch
  final bool hasMore;

  /// Current page number (for offset pagination)
  @JsonKey(name: 'page')
  final int? currentPage;

  /// Item limit per page
  @JsonKey(name: 'limit')
  final int? pageSize;

  /// Total number of pages
  final int? totalPages;

  /// Cursor token for next page (for cursor pagination)
  /// Use this instead of page number for better performance at scale
  @JsonKey(name: 'nextCursor')
  final String? nextPageCursor;

  /// Server timestamp when response was generated
  final DateTime? generatedAt;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.hasMore,
    this.currentPage,
    this.pageSize,
    this.totalPages,
    this.nextPageCursor,
    this.generatedAt,
  });

  /// Get number of items in current page
  int get itemsInPage => items.length;

  /// Check if this is the first page
  bool get isFirstPage => currentPage == null || currentPage == 1;

  /// Check if this is the last page
  bool get isLastPage => !hasMore;

  /// Calculate next offset for pagination
  int? get nextOffset {
    if (currentPage == null || pageSize == null) return null;
    return currentPage! * pageSize!;
  }

  /// Calculate previous offset
  int? get previousOffset {
    if (currentPage == null || pageSize == null) return null;
    if (currentPage! <= 1) return null;
    return (currentPage! - 1) * pageSize!;
  }

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}
