import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/components/editorial_atoms.dart';
import 'package:path_app/core/theme/app_colors.dart';
import 'package:path_app/core/theme/app_typography.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/gear/presentation/viewmodels/gear_viewmodel.dart';

class GearScreen extends ConsumerWidget {
  final String trekId;
  final String trekName;

  const GearScreen({super.key, required this.trekId, this.trekName = 'Trek'});

  static const _categoryMeta = <String, (String, IconData)>{
    'clothing': ('Clothing & Layers', Icons.checkroom_rounded),
    'navigation': ('Navigation', Icons.explore_rounded),
    'electronics': ('Electronics', Icons.devices_rounded),
    'medical': ('Health & Safety', Icons.medical_services_rounded),
    'food_water': ('Food & Water', Icons.restaurant_rounded),
    'other': ('Other', Icons.category_rounded),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    final state = ref.watch(gearViewModelProvider(trekId));

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
            Text('PACKING LIST',
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: c.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _showAddItemSheet(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: c.primary))
          : state.error != null
              ? _Message(text: state.error!, icon: Icons.cloud_off_rounded)
              : state.items.isEmpty
                  ? _Message(
                      text: 'No gear yet. Tap ＋ to start your checklist.',
                      icon: Icons.backpack_outlined,
                    )
                  : RefreshIndicator(
                      color: c.primary,
                      onRefresh: () =>
                          ref.read(gearViewModelProvider(trekId).notifier).load(),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                        children: [
                          _ProgressCard(state: state),
                          const SizedBox(height: 24),
                          ...state.byCategory.entries.map((entry) {
                            final meta = _categoryMeta[entry.key] ??
                                ('Other', Icons.category_rounded);
                            return _CategorySection(
                              title: meta.$1,
                              icon: meta.$2,
                              items: entry.value,
                              onToggle: (item) => ref
                                  .read(gearViewModelProvider(trekId).notifier)
                                  .toggle(item),
                            );
                          }),
                        ],
                      ),
                    ),
    );
  }

  void _showAddItemSheet(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    String category = 'other';
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
            builder: (context, setSheet) => Container(
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
                  Text('Add gear item',
                      style: AppType.title.copyWith(color: c.textPrimary)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: AppType.body.copyWith(color: c.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g. Down sleeping bag',
                      hintStyle: AppType.body.copyWith(color: c.textTertiary),
                      filled: true,
                      fillColor: c.canvas,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categoryMeta.entries.map((e) {
                      final active = category == e.key;
                      return GestureDetector(
                        onTap: () => setSheet(() => category = e.key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? c.primary : c.canvas,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(
                                color: active ? c.primary : c.border),
                          ),
                          child: Text(
                            e.value.$1,
                            style: AppType.caption.copyWith(
                              color: active ? Colors.white : c.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
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
                      onPressed: () {
                        final name = controller.text.trim();
                        if (name.isEmpty) return;
                        ref
                            .read(gearViewModelProvider(trekId).notifier)
                            .addItem(name, category, 1);
                        Navigator.of(context).pop();
                      },
                      child: Text('Add to list', style: AppType.button),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final GearState state;
  const _ProgressCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);
    final pct = (state.progress * 100).round();
    final done = pct == 100;

    return Container(
      padding: const EdgeInsets.all(20),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EyebrowLabel(done ? 'Ready to go' : 'Packing progress',
                        color: done ? LightColors.successGreen : c.primary),
                    const SizedBox(height: 6),
                    Text('${state.packedCount} of ${state.items.length} packed',
                        style: AppType.title.copyWith(color: c.textPrimary)),
                  ],
                ),
              ),
              Text('$pct%',
                  style: AppType.displayXL.copyWith(
                      color: done ? LightColors.successGreen : c.primary,
                      fontSize: 34)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 8,
              backgroundColor: c.border,
              valueColor: AlwaysStoppedAnimation(
                  done ? LightColors.successGreen : c.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<GearItem> items;
  final ValueChanged<GearItem> onToggle;

  const _CategorySection({
    required this.title,
    required this.icon,
    required this.items,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: c.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: AppType.titleSm.copyWith(color: c.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: c.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, color: c.border, indent: 56),
                  _GearRow(item: items[i], onToggle: () => onToggle(items[i])),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GearRow extends StatelessWidget {
  final GearItem item;
  final VoidCallback onToggle;

  const _GearRow({required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = AppColors(isDark);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onToggle();
      },
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.isPacked
                    ? LightColors.successGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: item.isPacked ? LightColors.successGreen : c.textTertiary,
                  width: 2,
                ),
              ),
              child: item.isPacked
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.name,
                style: AppType.bodySm.copyWith(
                  color: item.isPacked ? c.textTertiary : c.textPrimary,
                  fontWeight: FontWeight.w600,
                  decoration:
                      item.isPacked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (item.isEssential)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: LightColors.redLight,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text('ESSENTIAL',
                    style: AppType.caption.copyWith(
                      color: LightColors.sosRed,
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                    )),
              ),
            if (item.quantity > 1)
              Text('×${item.quantity}',
                  style: AppType.caption.copyWith(color: c.textTertiary)),
          ],
        ),
      ),
    );
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
