import 'package:path_app/features/treks/domain/entities/trek_summary.dart';

const List<TrekSummary> trekSeedData = [
  TrekSummary(
    id: 'everest-base-camp',
    name: 'Everest Base Camp Trek',
    region: 'Khumbu',
    difficulty: 'Challenging',
    durationDays: 12,
    distanceKm: 130,
    elevationGainM: 3200,
    maxAltitudeM: 5364,
    rating: 4.9,
    bestSeason: 'Mar-May • Sep-Nov',
    shortDescription: 'The iconic Himalayan trail to the base of Everest.',
    longDescription:
        'A high-altitude adventure through Sherpa villages, suspension bridges, and glacier valleys. Perfect for trekkers who want the classic Nepal experience.',
    highlights: [
      'Kala Patthar sunrise viewpoint',
      'Namche Bazaar acclimatization day',
      'Panoramic views of Everest and Lhotse',
    ],
    itinerary: [
      'Day 1-2: Lukla to Namche Bazaar',
      'Day 3-5: Acclimatization and ascent to Dingboche',
      'Day 6-8: Lobuche to Everest Base Camp',
      'Day 9-12: Return trek to Lukla',
    ],
  ),
  TrekSummary(
    id: 'annapurna-circuit',
    name: 'Annapurna Circuit',
    region: 'Annapurna',
    difficulty: 'Moderate',
    durationDays: 10,
    distanceKm: 160,
    elevationGainM: 2900,
    maxAltitudeM: 5416,
    rating: 4.8,
    bestSeason: 'Oct-Dec • Mar-Apr',
    shortDescription: 'A diverse circuit crossing Thorong La Pass.',
    longDescription:
        'Traverse lush valleys, alpine villages, and dramatic high mountain terrain on one of Nepal’s most rewarding multi-day routes.',
    highlights: [
      'Thorong La Pass crossing',
      'Muktinath temple visit',
      'Landscape shift from subtropical to alpine',
    ],
    itinerary: [
      'Day 1-3: Besisahar to Chame',
      'Day 4-6: Pisang to Manang acclimatization',
      'Day 7-8: Yak Kharka to Thorong Phedi',
      'Day 9-10: Thorong La to Muktinath and wrap',
    ],
  ),
  TrekSummary(
    id: 'langtang-valley',
    name: 'Langtang Valley Trek',
    region: 'Langtang',
    difficulty: 'Moderate',
    durationDays: 8,
    distanceKm: 78,
    elevationGainM: 1800,
    maxAltitudeM: 3870,
    rating: 4.6,
    bestSeason: 'Mar-May • Sep-Nov',
    shortDescription: 'Scenic valley trek close to Kathmandu.',
    longDescription:
        'A compact and beautiful route through forests, yak pastures, and Tamang settlements. Great for short but immersive Himalayan adventures.',
    highlights: [
      'Kyanjin Gompa exploration day',
      'Traditional Tamang villages',
      'Snow peaks from valley viewpoints',
    ],
    itinerary: [
      'Day 1-2: Syabrubesi to Lama Hotel',
      'Day 3-4: Langtang village to Kyanjin Gompa',
      'Day 5: Viewpoint hike and local exploration',
      'Day 6-8: Descend back to Syabrubesi',
    ],
  ),
  TrekSummary(
    id: 'poon-hill',
    name: 'Ghorepani Poon Hill Trek',
    region: 'Annapurna',
    difficulty: 'Easy',
    durationDays: 5,
    distanceKm: 45,
    elevationGainM: 1100,
    maxAltitudeM: 3210,
    rating: 4.5,
    bestSeason: 'All year (best in spring/autumn)',
    shortDescription: 'Short scenic trek with spectacular sunrise views.',
    longDescription:
        'Ideal for beginners and families, with comfortable tea houses, rhododendron forests, and classic mountain sunrise panoramas.',
    highlights: [
      'Poon Hill sunrise',
      'Rhododendron forests in bloom',
      'Comfortable tea-house experience',
    ],
    itinerary: [
      'Day 1: Nayapul to Ulleri',
      'Day 2: Ulleri to Ghorepani',
      'Day 3: Poon Hill sunrise and trek to Tadapani',
      'Day 4-5: Ghandruk and return',
    ],
  ),
];

TrekSummary? findTrekById(String id) {
  for (final trek in trekSeedData) {
    if (trek.id == id) return trek;
  }
  return null;
}
