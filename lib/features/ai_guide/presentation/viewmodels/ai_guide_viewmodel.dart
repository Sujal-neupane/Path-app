import 'package:flutter_riverpod/legacy.dart';
import 'package:path_app/features/ai_guide/data/datasources/ai_guide_remote_data_source.dart';

/// A single chat message in the AI Guide conversation.
class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;

  const ChatMessage({required this.role, required this.content});

  bool get isUser => role == 'user';

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: (json['role'] as String?) ?? 'assistant',
    content: (json['content'] as String?) ?? '',
  );
}

class AiGuideState {
  final List<ChatMessage> messages;
  final bool isSending;
  final bool isLoadingHistory;
  final String? error;

  const AiGuideState({
    this.messages = const [],
    this.isSending = false,
    this.isLoadingHistory = false,
    this.error,
  });

  AiGuideState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    bool? isLoadingHistory,
    String? error,
  }) {
    return AiGuideState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      error: error,
    );
  }
}

class AiGuideViewModel extends StateNotifier<AiGuideState> {
  final AiGuideRemoteDataSource _dataSource;

  AiGuideViewModel(this._dataSource) : super(const AiGuideState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoadingHistory: true, error: null);
    try {
      final res = await _dataSource.fetchChatHistory();
      final data = res['data'];
      final list = (data is List ? data : <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(ChatMessage.fromJson)
          .toList();
      state = state.copyWith(messages: list, isLoadingHistory: false);
    } catch (_) {
      // History is best-effort; start with an empty conversation.
      state = state.copyWith(isLoadingHistory: false);
    }
  }

  Future<void> send(String text, {String? region, double? altitude}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final optimistic = [
      ...state.messages,
      ChatMessage(role: 'user', content: trimmed),
    ];
    state = state.copyWith(messages: optimistic, isSending: true, error: null);

    try {
      final res = await _dataSource.sendMessage(
        message: trimmed,
        region: region,
        altitude: altitude,
      );
      final data = res['data'] as Map<String, dynamic>?;
      final reply = (data?['reply'] as String?)?.trim();
      if (reply != null && reply.isNotEmpty) {
        state = state.copyWith(
          messages: [
            ...state.messages,
            ChatMessage(role: 'assistant', content: reply),
          ],
          isSending: false,
        );
      } else {
        state = state.copyWith(isSending: false);
      }
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: 'Could not reach the guide. Check your connection.',
      );
    }
  }
}

final aiGuideViewModelProvider =
    StateNotifierProvider<AiGuideViewModel, AiGuideState>((ref) {
  return AiGuideViewModel(ref.read(aiGuideRemoteDataSourceProvider));
});
