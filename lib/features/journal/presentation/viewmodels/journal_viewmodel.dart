import 'package:flutter_riverpod/legacy.dart';
import 'package:path_app/features/journal/data/datasources/journal_remote_data_source.dart';

class JournalEntry {
  final String id;
  final int dayNumber;
  final DateTime date;
  final String title;
  final String body;
  final String mood;
  final List<String> photoUrls;

  const JournalEntry({
    required this.id,
    required this.dayNumber,
    required this.date,
    required this.title,
    required this.body,
    required this.mood,
    required this.photoUrls,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    dayNumber: (json['day_number'] as num?)?.toInt() ?? 1,
    date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    title: (json['title'] as String?) ?? '',
    body: (json['body'] as String?) ?? '',
    mood: (json['mood'] as String?) ?? 'neutral',
    photoUrls: (json['photo_urls'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
  );
}

class JournalState {
  final List<JournalEntry> entries;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const JournalState({
    this.entries = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  JournalState copyWith({
    List<JournalEntry>? entries,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

class JournalViewModel extends StateNotifier<JournalState> {
  final JournalRemoteDataSource _dataSource;
  final String trekId;

  JournalViewModel(this._dataSource, this.trekId)
      : super(const JournalState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _dataSource.fetchJournalEntries(trekId);
      final data = res['data'];
      final list = (data is List ? data : <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(JournalEntry.fromJson)
          .toList()
        ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
      state = state.copyWith(entries: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load your journal.',
      );
    }
  }

  Future<bool> create({
    required String trekTitle,
    required int dayNumber,
    required String title,
    required String body,
    required String mood,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      await _dataSource.createJournalEntry(trekId, {
        'trekTitle': trekTitle,
        'dayNumber': dayNumber,
        'date': DateTime.now().toIso8601String(),
        'title': title,
        'body': body,
        'mood': mood,
      });
      await load();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: 'Could not save entry.');
      return false;
    }
  }
}

final journalViewModelProvider = StateNotifierProvider.family<JournalViewModel,
    JournalState, String>((ref, trekId) {
  return JournalViewModel(ref.read(journalRemoteDataSourceProvider), trekId);
});
