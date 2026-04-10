import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../features/nap_stack/nap_stack_notifier.dart';
import '../../features/pro/pro_provider.dart';
import '../../features/timer/nap_preset.dart';
import '../widgets/stack_item_tile.dart';

class NapStackScreen extends ConsumerWidget {
  const NapStackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stackState = ref.watch(napStackNotifierProvider);
    final isPro = ref.watch(proStatusProvider).value ?? false;
    final items = stackState.items;

    return Scaffold(
      backgroundColor: AppColors.kBgBase,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                count: items.length,
                isPro: isPro,
              ),
            ),

            if (stackState.isLoading && items.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.kAccent,
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (items.isEmpty)
              const SliverFillRemaining(child: _EmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) => StackItemTile(
                    item: items[i],
                    onDelete: () => ref
                        .read(napStackNotifierProvider.notifier)
                        .remove(items[i].id),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _AddFab(isPro: isPro, stackCount: items.length),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.isPro});
  final int count;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nap Stack',
                  style: GoogleFonts.syne(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kTextPrimary,
                  ),
                ),
              ),
              // Licznik wolnych slotów (free)
              if (!isPro) _SlotCounter(used: count, max: 3),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Zaplanuj kolejkę drzemek z alarmami.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.kTextSecondary,
            ),
          ),
          if (!isPro && count >= 2) ...[
            const SizedBox(height: 12),
            _FreeWarning(count: count),
          ],
          const SizedBox(height: 20),
          const Divider(),
        ],
      ),
    );
  }
}

class _SlotCounter extends StatelessWidget {
  const _SlotCounter({required this.used, required this.max});
  final int used;
  final int max;

  @override
  Widget build(BuildContext context) {
    final isFull = used >= max;
    final color = isFull ? AppColors.kError : AppColors.kTextMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          ...List.generate(max, (i) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < used ? color : color.withValues(alpha: 0.25),
            ),
          )),
          const SizedBox(width: 6),
          Text(
            '$used/$max',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeWarning extends StatelessWidget {
  const _FreeWarning({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final isFull = count >= 3;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kWarning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.kWarning.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            isFull ? Icons.lock_outline_rounded : Icons.info_outline_rounded,
            color: AppColors.kWarning,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isFull
                  ? 'Limit 3 drzemek w wersji darmowej. Kup Pro, by dodawać więcej.'
                  : 'Zostało ${3 - count} ${_slots(3 - count)} w wersji darmowej.',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.kWarning,
                height: 1.4,
              ),
            ),
          ),
          if (isFull) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push('/paywall'),
              child: Text(
                'Pro →',
                style: GoogleFonts.syne(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kAccent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _slots(int n) => n == 1 ? 'slot' : 'sloty';
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_outlined,
              color: AppColors.kTextMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            'Stos jest pusty',
            style: GoogleFonts.syne(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.kTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dodaj drzemkę, by zaplanować alarm.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.kTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────────

class _AddFab extends ConsumerWidget {
  const _AddFab({required this.isPro, required this.stackCount});
  final bool isPro;
  final int stackCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocked = !isPro && stackCount >= 3;

    return FloatingActionButton.extended(
      onPressed: () => isLocked
          ? context.push('/paywall')
          : _showAddSheet(context, ref, isPro),
      icon: Icon(isLocked ? Icons.lock_outline_rounded : Icons.add_rounded),
      label: Text(
        isLocked ? 'Odblokuj Pro' : 'Dodaj drzemkę',
        style: GoogleFonts.syne(
            fontSize: 14, fontWeight: FontWeight.w600),
      ),
      backgroundColor: isLocked ? AppColors.kBgElevated : AppColors.kAccent,
      foregroundColor: isLocked ? AppColors.kTextSecondary : AppColors.kBgDeep,
      elevation: 0,
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref, bool isPro) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddSheet(isPro: isPro),
    );
  }
}

// ── Add sheet ─────────────────────────────────────────────────────────────────

class _AddSheet extends ConsumerStatefulWidget {
  const _AddSheet({required this.isPro});
  final bool isPro;

  @override
  ConsumerState<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends ConsumerState<_AddSheet> {
  NapType _selectedType = NapType.powerNap;
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isTomorrow = false;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Nowa drzemka',
            style: GoogleFonts.syne(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.kTextPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Typ presetu
          Text(
            'PRESET',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.kTextMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          _PresetSelector(
            selected: _selectedType,
            isPro: widget.isPro,
            onChanged: (t) => setState(() => _selectedType = t),
          ),
          const SizedBox(height: 20),

          // Czas
          Text(
            'GODZINA',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.kTextMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          _TimeRow(
            time: _selectedTime,
            isTomorrow: _isTomorrow,
            onTimeTap: _pickTime,
            onTomorrowChanged: (v) => setState(() => _isTomorrow = v),
          ),
          const SizedBox(height: 28),

          // Dodaj
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Zaplanuj drzemkę'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.kAccent,
            onSurface: AppColors.kTextPrimary,
            surface: AppColors.kBgCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day + (_isTomorrow ? 1 : 0),
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Jeśli czas w przeszłości (dzisiaj) → automatycznie jutro
    if (scheduled.isBefore(now) && !_isTomorrow) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    Navigator.pop(context);

    final isPro = ref.read(proStatusProvider).value ?? false;
    await ref.read(napStackNotifierProvider.notifier).add(
          scheduledAt: scheduled,
          napType: _selectedType,
          isPro: isPro,
        );
  }
}

class _PresetSelector extends StatelessWidget {
  const _PresetSelector({
    required this.selected,
    required this.isPro,
    required this.onChanged,
  });

  final NapType selected;
  final bool isPro;
  final ValueChanged<NapType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: kPresets.map((p) {
        final isSelected = p.type == selected;
        final isLocked = p.isPro && !isPro;
        final color = switch (p.type) {
          NapType.powerNap  => AppColors.kPowerNapColor,
          NapType.coffeeNap => AppColors.kCoffeeNapColor,
          NapType.fullCycle => AppColors.kFullCycleColor,
        };

        return Expanded(
          child: GestureDetector(
            onTap: isLocked ? null : () => onChanged(p.type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : AppColors.kBgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.5)
                      : AppColors.kBorder,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isLocked ? Icons.lock_outline_rounded : switch (p.type) {
                      NapType.powerNap  => Icons.bolt_rounded,
                      NapType.coffeeNap => Icons.coffee_rounded,
                      NapType.fullCycle => Icons.nightlight_round,
                    },
                    color: isLocked
                        ? AppColors.kTextMuted
                        : isSelected
                            ? color
                            : AppColors.kTextSecondary,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isLocked
                          ? AppColors.kTextMuted
                          : isSelected
                              ? color
                              : AppColors.kTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.time,
    required this.isTomorrow,
    required this.onTimeTap,
    required this.onTomorrowChanged,
  });

  final TimeOfDay time;
  final bool isTomorrow;
  final VoidCallback onTimeTap;
  final ValueChanged<bool> onTomorrowChanged;

  @override
  Widget build(BuildContext context) {
    final label = time.format(context);

    return Row(
      children: [
        // Time picker button
        Expanded(
          child: GestureDetector(
            onTap: onTimeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.kBgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.kBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      color: AppColors.kAccent, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: GoogleFonts.syne(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Tomorrow toggle
        GestureDetector(
          onTap: () => onTomorrowChanged(!isTomorrow),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isTomorrow
                  ? AppColors.kAccent.withValues(alpha: 0.12)
                  : AppColors.kBgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isTomorrow
                    ? AppColors.kAccent.withValues(alpha: 0.4)
                    : AppColors.kBorder,
              ),
            ),
            child: Text(
              'Jutro',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isTomorrow
                    ? AppColors.kAccent
                    : AppColors.kTextSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
