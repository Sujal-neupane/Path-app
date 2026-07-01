import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/components/glass_panel.dart';
import 'package:path_app/core/theme/app_colors.dart';
import 'package:path_app/core/theme/app_typography.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/ai_guide/presentation/viewmodels/ai_guide_viewmodel.dart';
import 'package:path_app/features/treks/presentation/viewmodels/trek_viewmodel.dart';

class AiGuideScreen extends ConsumerStatefulWidget {
  const AiGuideScreen({super.key});

  @override
  ConsumerState<AiGuideScreen> createState() => _AiGuideScreenState();
}

class _AiGuideScreenState extends ConsumerState<AiGuideScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  static const _suggestions = <_Suggestion>[
    _Suggestion('🩺', 'Altitude sickness signs?'),
    _Suggestion('🎒', 'What gear do I need?'),
    _Suggestion('📋', 'Which permits are required?'),
    _Suggestion('🌤️', 'Best season to trek?'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String text) {
    final active = ref.read(activeTrekProvider);
    ref.read(aiGuideViewModelProvider.notifier).send(
          text,
          region: active.region,
          altitude: active.currentAltitude,
        );
    _controller.clear();
    FocusScope.of(context).unfocus();
    _scrollToBottomSoon();
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    final state = ref.watch(aiGuideViewModelProvider);

    ref.listen(aiGuideViewModelProvider, (prev, next) => _scrollToBottomSoon());

    final isEmpty = state.messages.isEmpty;

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: AppBar(
        backgroundColor: c.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'PATHGUIDE',
              style: AppType.eyebrow.copyWith(color: LightColors.peakAmber),
            ),
            const SizedBox(height: 2),
            Text(
              'AI Trek Guide',
              style: AppType.titleSm.copyWith(color: c.textPrimary),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: isEmpty
                ? _EmptyState(
                    suggestions: _suggestions,
                    onTap: _send,
                    loading: state.isLoadingHistory,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    itemCount: state.messages.length + (state.isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.messages.length) {
                        return const _TypingBubble();
                      }
                      return _MessageBubble(message: state.messages[index]);
                    },
                  ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                state.error!,
                style: AppType.caption.copyWith(color: c.error),
              ),
            ),
          _InputBar(
            controller: _controller,
            sending: state.isSending,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _Suggestion {
  final String emoji;
  final String text;
  const _Suggestion(this.emoji, this.text);
}

class _EmptyState extends StatelessWidget {
  final List<_Suggestion> suggestions;
  final ValueChanged<String> onTap;
  final bool loading;

  const _EmptyState({
    required this.suggestions,
    required this.onTap,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    if (loading) {
      return Center(
        child: CircularProgressIndicator(color: c.primary, strokeWidth: 3),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LightColors.peakAmber, Color(0xFFE8B84B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: LightColors.peakAmber.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(height: 20),
          Text(
            'Your Himalayan\nexpedition expert.',
            style: AppType.displayXL.copyWith(color: c.textPrimary, fontSize: 32),
          ),
          const SizedBox(height: 10),
          Text(
            'Ask about altitude safety, gear, permits, weather windows, or anything on the trail. Context-aware of your active trek.',
            style: AppType.body.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: 28),
          Text(
            'TRY ASKING',
            style: AppType.eyebrow.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: 12),
          ...suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onTap(s.text),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: c.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Text(s.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          s.text,
                          style: AppType.bodySm.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_outward_rounded,
                          size: 18, color: c.textTertiary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _GuideAvatar(),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? LightColors.forestPrimary : c.surfaceElevated,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser ? null : Border.all(color: c.border),
              ),
              child: Text(
                message.content,
                style: AppType.body.copyWith(
                  color: isUser ? Colors.white : c.textPrimary,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [LightColors.peakAmber, Color(0xFFE8B84B)],
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(Icons.auto_awesome_rounded,
          color: Colors.white, size: 16),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuideAvatar(),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: c.surfaceElevated,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.border),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
        ..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_ctrl.value * 3 - i).clamp(0.0, 1.0);
            final scale = 0.6 + (0.4 * (1 - (t - 0.5).abs() * 2)).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: LightColors.peakAmber,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _InputBar extends StatefulWidget {
  final TextEditingController controller;
  final bool sending;
  final ValueChanged<String> onSend;

  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return GlassPanel(
      borderRadius: 0,
      blur: 24,
      opacity: 0.7,
      border: false,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: c.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: c.border),
              ),
              child: TextField(
                controller: widget.controller,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: AppType.body.copyWith(color: c.textPrimary),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Ask your guide…',
                  hintStyle: AppType.body.copyWith(color: c.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                onSubmitted: widget.sending ? null : widget.onSend,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _SendButton(
            enabled: widget.controller.text.trim().isNotEmpty && !widget.sending,
            sending: widget.sending,
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onSend(widget.controller.text);
            },
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final bool sending;
  final VoidCallback onTap;

  const _SendButton({
    required this.enabled,
    required this.sending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled
              ? LightColors.forestPrimary
              : LightColors.forestPrimary.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: sending
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Icon(Icons.arrow_upward_rounded, color: Colors.white),
      ),
    );
  }
}
