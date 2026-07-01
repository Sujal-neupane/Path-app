import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/features/profile/data/datasources/profile_remote_data_source.dart';

/// XP thresholds mirror the backend `LEVEL_THRESHOLDS`.
const _levelThresholds = <String, int>{
  'rookie': 0,
  'trail_walker': 500,
  'explorer': 1500,
  'adventurer': 4000,
  'summit_seeker': 10000,
  'summit_master': 25000,
  'legend': 60000,
};

const _levelOrder = [
  'rookie',
  'trail_walker',
  'explorer',
  'adventurer',
  'summit_seeker',
  'summit_master',
  'legend',
];

class ProfileStats {
  final int xp;
  final String level;
  final double distanceKm;
  final int elevationM;
  final int treksCompleted;
  final int checkpointsReached;
  final int badgeCount;
  final String? avatarUrl;
  final String? bio;

  const ProfileStats({
    required this.xp,
    required this.level,
    required this.distanceKm,
    required this.elevationM,
    required this.treksCompleted,
    required this.checkpointsReached,
    required this.badgeCount,
    this.avatarUrl,
    this.bio,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) => ProfileStats(
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        level: (json['level'] as String?) ?? 'rookie',
        distanceKm: (json['total_distance_km'] as num?)?.toDouble() ?? 0,
        elevationM: (json['total_elevation_m'] as num?)?.toInt() ?? 0,
        treksCompleted: (json['total_treks_completed'] as num?)?.toInt() ?? 0,
        checkpointsReached:
            (json['total_checkpoints_reached'] as num?)?.toInt() ?? 0,
        badgeCount: (json['earned_badges'] as List<dynamic>?)?.length ?? 0,
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
      );

  /// Human-readable level, e.g. "Summit Seeker".
  String get levelLabel => level
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  int get _currentThreshold => _levelThresholds[level] ?? 0;

  String? get _nextLevel {
    final idx = _levelOrder.indexOf(level);
    if (idx < 0 || idx >= _levelOrder.length - 1) return null;
    return _levelOrder[idx + 1];
  }

  int? get nextLevelXp =>
      _nextLevel == null ? null : _levelThresholds[_nextLevel];

  String? get nextLevelLabel => _nextLevel
      ?.split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  /// 0..1 progress toward the next level.
  double get levelProgress {
    final next = nextLevelXp;
    if (next == null) return 1.0;
    final span = next - _currentThreshold;
    if (span <= 0) return 1.0;
    return ((xp - _currentThreshold) / span).clamp(0.0, 1.0);
  }
}

final profileStatsProvider = FutureProvider.autoDispose<ProfileStats>((ref) async {
  final res = await ref.read(profileRemoteDataSourceProvider).fetchProfile();
  final data = res['data'];
  if (data is Map<String, dynamic>) return ProfileStats.fromJson(data);
  throw Exception('Invalid profile response');
});
