import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../features/nap_stack/nap_stack_item_model.dart';
import '../../features/timer/nap_preset.dart';

/// Wiersz pojedynczej zaplanowanej drzemki w Nap Stack.
class StackItemTile extends StatelessWidget {
  const StackItemTile({
    required this.item,
    required this.onDelete,
    super.key,
  });

  final NapStackItem item;
  final VoidCallback onDelete;

  Color get _accentColor => switch (item.napType) {
    NapType.powerNap   => AppColors.kPowerNapColor,
    NapType.coffeeNap  => AppColors.kCoffeeNapColor,
    NapType.fullCycle  => AppColors.kFullCycleColor,
  };

  IconData get _icon => switch (item.napType) {
    NapType.powerNap   => Icons.bolt_rounded,
    NapType.coffeeNap  => Icons.coffee_rounded,
    NapType.fullCycle  => Icons.nightlight_round,
  };

  String get _presetLabel => presetByType(item.napType).label;

  String get _timeLabel {
    final now = DateTime.now();
    final date = item.scheduledAt;

    final timeStr = DateFormat('HH:mm').format(date);

    if (DateUtils.isSameDay(date, now)) return 'Dzisiaj, $timeStr';
    if (DateUtils.isSameDay(date, now.add(const Duration(days: 1)))) {
      return 'Jutro, $timeStr';
    }
    return DateFormat('d MMM, HH:mm', 'pl').format(date);
  }

  bool get _isSoon {
    final diff = item.scheduledAt.difference(DateTime.now());
    return diff.inMinutes <= 30 && diff.inMinutes > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: _DismissBackground(),
      confirmDismiss: (_) async => await _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.kBgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isSoon ? _accentColor.withValues(alpha: 0.4) : AppColors.kBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Ikona
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _accentColor, size: 20),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _presetLabel,
                        style: GoogleFonts.syne(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.kTextPrimary,
                        ),
                      ),
                      if (_isSoon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.kWarning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Wkrótce',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              color: AppColors.kWarning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _timeLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.kTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Usuń
            GestureDetector(
              onTap: () async {
                if (await _confirmDelete(context)) onDelete();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.kError.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.kError.withValues(alpha: 0.7),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Usuń drzemkę?'),
        content: Text('Alarm dla $_presetLabel o $_timeLabel zostanie anulowany.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.kError),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.kError.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      child: const Icon(Icons.delete_outline_rounded,
          color: AppColors.kError, size: 22),
    );
  }
}
