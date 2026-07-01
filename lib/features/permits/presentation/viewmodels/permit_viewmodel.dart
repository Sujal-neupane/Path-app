import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/permit_info_model.dart';
import '../../data/repositories/permit_repository_impl.dart';

final allPermitsProvider = FutureProvider<List<PermitInfoModel>>((ref) async {
  final repo = ref.watch(permitRepositoryProvider);
  return repo.getAllPermits();
});

final regionPermitProvider = FutureProvider.family<PermitInfoModel, String>((
  ref,
  region,
) async {
  final repo = ref.watch(permitRepositoryProvider);
  return repo.getPermitByRegion(region);
});

class PermitCheckoutState {
  final bool isLoading;
  final String? errorMessage;
  final String? checkoutUrl;
  final String? sessionId;

  const PermitCheckoutState({
    this.isLoading = false,
    this.errorMessage,
    this.checkoutUrl,
    this.sessionId,
  });

  PermitCheckoutState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? checkoutUrl,
    String? sessionId,
  }) {
    return PermitCheckoutState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

class PermitCheckoutNotifier extends Notifier<PermitCheckoutState> {
  @override
  PermitCheckoutState build() {
    return const PermitCheckoutState();
  }

  Future<bool> bookPermit({
    required String regionKey,
    required int trekkerCount,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(permitRepositoryProvider);
      final sessionData = await repo.createCheckoutSession(
        regionKey: regionKey,
        trekkerCount: trekkerCount,
      );

      final url = sessionData['url'] as String?;
      final sessionId = sessionData['sessionId'] as String?;

      if (url == null || url.isEmpty) {
        throw Exception('Stripe checkout URL was not generated.');
      }

      state = state.copyWith(
        isLoading: false,
        checkoutUrl: url,
        sessionId: sessionId,
      );

      // Launch Stripe Checkout URL in the system browser
      final uri = Uri.parse(url);
      try {
        final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (success) return true;
        
        // If launch returns false (but doesn't throw)
        await Clipboard.setData(ClipboardData(text: url));
        state = state.copyWith(
          errorMessage: 'Checkout link copied to clipboard! Please paste it in Safari/Chrome.',
        );
        return true;
      } catch (e) {
        // Fallback for pigeon channel connection errors
        await Clipboard.setData(ClipboardData(text: url));
        state = state.copyWith(
          errorMessage: 'Payment page copied to clipboard! Please paste it in Safari/Chrome.',
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final permitCheckoutProvider =
    NotifierProvider<PermitCheckoutNotifier, PermitCheckoutState>(() {
  return PermitCheckoutNotifier();
});
