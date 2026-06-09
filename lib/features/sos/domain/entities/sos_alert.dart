class SosAlert {
  final String? id;
  final String userId;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? batteryLevel;
  final String status;
  final String? message;
  final DateTime createdAt;
  final bool isSynced;

  const SosAlert({
    this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.batteryLevel,
    required this.status,
    this.message,
    required this.createdAt,
    this.isSynced = true,
  });

  SosAlert copyWith({
    String? id,
    String? userId,
    double? latitude,
    double? longitude,
    double? altitude,
    double? batteryLevel,
    String? status,
    String? message,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return SosAlert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
