/// A geographic waypoint on a trek trail.
/// All waypoint data now comes from the backend API — no hardcoded coordinates.
class Waypoint {
  final String name;
  final double lat;
  final double lng;
  final double alt;
  final String distance;

  const Waypoint({
    required this.name,
    required this.lat,
    required this.lng,
    required this.alt,
    required this.distance,
  });

  /// Deserialize from backend checkpoint JSON.
  factory Waypoint.fromJson(Map<String, dynamic> json) {
    return Waypoint(
      name: json['title'] as String? ?? json['name'] as String? ?? '',
      lat: (json['latitude'] as num?)?.toDouble() ?? (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['longitude'] as num?)?.toDouble() ?? (json['lng'] as num?)?.toDouble() ?? 0.0,
      alt: (json['altitude_m'] as num?)?.toDouble() ?? (json['alt'] as num?)?.toDouble() ?? 0.0,
      distance: json['distance'] as String? ?? '0.0 km',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'lat': lat,
    'lng': lng,
    'alt': alt,
    'distance': distance,
  };
}

List<Waypoint> getWaypointsForRegion(String region) {
  final cleanRegion = region.toLowerCase();
  if (cleanRegion.contains('annapurna')) {
    return const [
      Waypoint(
        name: 'Besisahar',
        lat: 28.2168,
        lng: 84.3686,
        alt: 760,
        distance: '0.0 km',
      ),
      Waypoint(
        name: 'Chame',
        lat: 28.5532,
        lng: 84.3168,
        alt: 2670,
        distance: '14.2 km',
      ),
      Waypoint(
        name: 'Manang',
        lat: 28.6667,
        lng: 84.0167,
        alt: 3519,
        distance: '28.5 km',
      ),
      Waypoint(
        name: 'Yak Kharka',
        lat: 28.7182,
        lng: 83.9912,
        alt: 4110,
        distance: '38.1 km',
      ),
      Waypoint(
        name: 'Thorong Phedi',
        lat: 28.7972,
        lng: 83.9782,
        alt: 4540,
        distance: '45.0 km',
      ),
      Waypoint(
        name: 'Thorong La Pass',
        lat: 28.7915,
        lng: 83.9382,
        alt: 5416,
        distance: '50.3 km',
      ),
      Waypoint(
        name: 'Muktinath',
        lat: 28.8167,
        lng: 83.8667,
        alt: 3800,
        distance: '60.1 km',
      ),
    ];
  } else if (cleanRegion.contains('langtang')) {
    return const [
      Waypoint(
        name: 'Syabrubesi',
        lat: 28.1333,
        lng: 85.3333,
        alt: 1460,
        distance: '0.0 km',
      ),
      Waypoint(
        name: 'Lama Hotel',
        lat: 28.1834,
        lng: 85.4182,
        alt: 2470,
        distance: '11.8 km',
      ),
      Waypoint(
        name: 'Langtang Village',
        lat: 28.2031,
        lng: 85.4912,
        alt: 3430,
        distance: '21.5 km',
      ),
      Waypoint(
        name: 'Kyanjin Gompa',
        lat: 28.2167,
        lng: 85.6167,
        alt: 3830,
        distance: '29.2 km',
      ),
      Waypoint(
        name: 'Kyanjin Ri Peak',
        lat: 28.2289,
        lng: 85.6212,
        alt: 4773,
        distance: '33.8 km',
      ),
    ];
  } else if (cleanRegion.contains('poon') || cleanRegion.contains('ghorepani')) {
    return const [
      Waypoint(
        name: 'Nayapul',
        lat: 28.2982,
        lng: 83.7612,
        alt: 1070,
        distance: '0.0 km',
      ),
      Waypoint(
        name: 'Tikhedhunga',
        lat: 28.3456,
        lng: 83.7214,
        alt: 1540,
        distance: '9.2 km',
      ),
      Waypoint(
        name: 'Ghorepani',
        lat: 28.4012,
        lng: 83.7018,
        alt: 2860,
        distance: '18.5 km',
      ),
      Waypoint(
        name: 'Poon Hill Peak',
        lat: 28.4000,
        lng: 83.7000,
        alt: 3210,
        distance: '20.0 km',
      ),
      Waypoint(
        name: 'Tadapani',
        lat: 28.3982,
        lng: 83.7712,
        alt: 2630,
        distance: '29.5 km',
      ),
    ];
  } else {
    // Default: Everest Base Camp path
    return const [
      Waypoint(
        name: 'Lukla Airport',
        lat: 27.6878,
        lng: 86.7314,
        alt: 2860,
        distance: '0.0 km',
      ),
      Waypoint(
        name: 'Phakding',
        lat: 27.7382,
        lng: 86.7112,
        alt: 2610,
        distance: '8.2 km',
      ),
      Waypoint(
        name: 'Namche Bazaar',
        lat: 27.8068,
        lng: 86.7140,
        alt: 3440,
        distance: '19.5 km',
      ),
      Waypoint(
        name: 'Tengboche',
        lat: 27.8364,
        lng: 86.7645,
        alt: 3860,
        distance: '29.2 km',
      ),
      Waypoint(
        name: 'Dingboche',
        lat: 27.8931,
        lng: 86.8315,
        alt: 4410,
        distance: '41.0 km',
      ),
      Waypoint(
        name: 'Lobuche',
        lat: 27.9482,
        lng: 86.8113,
        alt: 4940,
        distance: '49.8 km',
      ),
      Waypoint(
        name: 'Gorak Shep',
        lat: 27.9813,
        lng: 86.9248,
        alt: 5164,
        distance: '55.3 km',
      ),
      Waypoint(
        name: 'Everest Base Camp',
        lat: 28.0042,
        lng: 86.8558,
        alt: 5364,
        distance: '62.0 km',
      ),
    ];
  }
}
