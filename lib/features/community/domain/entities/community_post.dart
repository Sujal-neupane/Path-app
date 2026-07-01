class CommunityPost {
  final String id;
  final String userName;
  final String? userAvatar;
  final String? userLevel;
  final String caption;
  final List<String> imageUrls;
  final int likeCount;
  final int commentCount;
  final List<String> likes; // List of user IDs who liked this post
  final String? region;
  final DateTime createdAt;
  final bool isLikedByMe;

  CommunityPost({
    required this.id,
    required this.userName,
    this.userAvatar,
    this.userLevel,
    required this.caption,
    required this.imageUrls,
    required this.likeCount,
    required this.commentCount,
    required this.likes,
    this.region,
    required this.createdAt,
    this.isLikedByMe = false,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json, String currentUserId) {
    final likesList = (json['likes'] as List?)?.map((e) => e.toString()).toList() ?? [];
    return CommunityPost(
      id: json['id'] ?? json['_id'] ?? '',
      userName: json['user_name'] ?? '',
      userAvatar: json['user_avatar'],
      userLevel: json['user_level'],
      caption: json['caption'] ?? '',
      imageUrls: (json['image_urls'] as List?)?.map((e) => e.toString()).toList() ?? [],
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      likes: likesList,
      region: json['region'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isLikedByMe: likesList.contains(currentUserId),
    );
  }

  CommunityPost copyWith({
    String? id,
    String? userName,
    String? userAvatar,
    String? userLevel,
    String? caption,
    List<String>? imageUrls,
    int? likeCount,
    int? commentCount,
    List<String>? likes,
    String? region,
    DateTime? createdAt,
    bool? isLikedByMe,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      userLevel: userLevel ?? this.userLevel,
      caption: caption ?? this.caption,
      imageUrls: imageUrls ?? this.imageUrls,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      likes: likes ?? this.likes,
      region: region ?? this.region,
      createdAt: createdAt ?? this.createdAt,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}
