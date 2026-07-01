import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/components/editorial_atoms.dart';
import 'package:path_app/core/theme/app_colors.dart';
import 'package:path_app/core/theme/app_typography.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/journal/presentation/viewmodels/journal_viewmodel.dart';

const _moods = <String, (String, Color)>{
  'amazing': ('🤩', Color(0xFF2DBE60)),
  'good': ('🙂', Color(0xFF52B788)),
  'neutral': ('😐', Color(0xFFD4A017)),
  'tough': ('😓', Color(0xFFF59E0B)),
  'exhausted': ('🥵', Color(0xFFE63946)),
};

class JournalScreen extends ConsumerWidget {
  final String trekId;
  final String trekName;

  const JournalScreen({super.key, required this.trekId, this.trekName = 'Trek'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    final state = ref.watch(journalViewModelProvider(trekId));

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
          children: [
            Text('TREK JOURNAL',
                style: AppType.eyebrow.copyWith(color: LightColors.peakAmber)),
            const SizedBox(height: 2),
            Text(trekName,
                style: AppType.titleSm.copyWith(color: c.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: c.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _showComposer(context, ref, state.entries.length + 1),
        icon: const Icon(Icons.edit_rounded),
        label: Text('New entry', style: AppType.button.copyWith(fontSize: 14)),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: c.primary))
          : state.error != null && state.entries.isEmpty
              ? _Message(text: state.error!, icon: Icons.cloud_off_rounded)
              : state.entries.isEmpty
                  ? _Message(
                      text:
                          'No entries yet. Capture your first day on the trail.',
                      icon: Icons.menu_book_outlined,
                    )
                  : RefreshIndicator(
                      color: c.primary,
                      onRefresh: () => ref
                          .read(journalViewModelProvider(trekId).notifier)
                          .load(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                        itemCount: state.entries.length,
                        itemBuilder: (context, i) => _TimelineTile(
                          entry: state.entries[i],
                          isFirst: i == 0,
                          isLast: i == state.entries.length - 1,
                        ),
                      ),
                    ),
    );
  }

  void _showComposer(BuildContext context, WidgetRef ref, int nextDay) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    String mood = 'good';
    int day = nextDay;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final c = AppColors(isDark);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setSheet) {
              final saving =
                  ref.watch(journalViewModelProvider(trekId)).isSaving;
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: c.surfaceElevated,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('New journal entry',
                              style: AppType.title
                                  .copyWith(color: c.textPrimary)),
                        ),
                        _DayStepper(
                          day: day,
                          onChanged: (v) => setSheet(() => day = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleCtrl,
                      style: AppType.titleSm.copyWith(color: c.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Title — e.g. Reached Namche',
                        hintStyle: AppType.titleSm.copyWith(color: c.textTertiary),
                        filled: true,
                        fillColor: c.canvas,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyCtrl,
                      minLines: 3,
                      maxLines: 6,
                      style: AppType.body.copyWith(color: c.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'How did the day go? Conditions, feelings…',
                        hintStyle: AppType.body.copyWith(color: c.textTertiary),
                        filled: true,
                        fillColor: c.canvas,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('MOOD',
                        style: AppType.eyebrow.copyWith(color: c.textTertiary)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _moods.entries.map((e) {
                        final active = mood == e.key;
                        return GestureDetector(
                          onTap: () => setSheet(() => mood = e.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: active
                                  ? e.value.$2.withValues(alpha: 0.16)
                                  : c.canvas,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: active ? e.value.$2 : c.border,
                                width: active ? 2 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(e.value.$1,
                                style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: c.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: saving
                            ? null
                            : () async {
                                final title = titleCtrl.text.trim();
                                final body = bodyCtrl.text.trim();
                                if (title.isEmpty || body.isEmpty) return;
                                final ok = await ref
                                    .read(journalViewModelProvider(trekId)
                                        .notifier)
                                    .create(
                                      trekTitle: trekName,
                                      dayNumber: day,
                                      title: title,
                                      body: body,
                                      mood: mood,
                                    );
                                if (ok && context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                        child: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text('Save entry', style: AppType.button),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _DayStepper extends StatelessWidget {
  final int day;
  final ValueChanged<int> onChanged;
  const _DayStepper({required this.day, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    return Container(
      decoration: BoxDecoration(
        color: c.canvas,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.remove_rounded, size: 18, color: c.textSecondary),
            onPressed: day > 1 ? () => onChanged(day - 1) : null,
          ),
          Text('Day $day',
              style: AppType.caption.copyWith(
                  color: c.textPrimary, fontWeight: FontWeight.w700)),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.add_rounded, size: 18, color: c.textSecondary),
            onPressed: () => onChanged(day + 1),
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final JournalEntry entry;
  final bool isFirst;
  final bool isLast;

  const _TimelineTile({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    final moodMeta = _moods[entry.mood] ?? ('😐', c.primary);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail
          Column(
            children: [
              Container(width: 2, height: 6, color: isFirst ? Colors.transparent : c.border),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: moodMeta.$2.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: moodMeta.$2, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(moodMeta.$1, style: const TextStyle(fontSize: 16)),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : c.border,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        EyebrowLabel('Day ${entry.dayNumber}', color: c.primary),
                        const Spacer(),
                        Text(_fmtDate(entry.date),
                            style: AppType.caption.copyWith(color: c.textTertiary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(entry.title,
                        style: AppType.titleSm.copyWith(color: c.textPrimary)),
                    if (entry.body.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(entry.body,
                          style: AppType.bodySm.copyWith(color: c.textSecondary)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}

class _Message extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Message({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: c.textTertiary),
            const SizedBox(height: 14),
            Text(text,
                textAlign: TextAlign.center,
                style: AppType.body.copyWith(color: c.textSecondary)),
          ],
        ),
      ),
    );
  }
}
