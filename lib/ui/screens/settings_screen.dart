import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../features/pro/pro_provider.dart';
import '../../features/pro/user_prefs_service.dart';
import '../../features/timer/alarm_service.dart';
import '../../features/timer/nap_preset.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proStatusProvider).value ?? false;

    return Scaffold(
      backgroundColor: AppColors.kBgBase,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _SettingsHeader(isPro: isPro)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _SectionLabel('Alarm'),
                  _RingtoneSection(),
                  const SizedBox(height: 24),
                  _SectionLabel('Konto'),
                  _AccountSection(isPro: isPro),
                  const SizedBox(height: 24),
                  _SectionLabel('Informacje'),
                  _InfoSection(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nagłówek ─────────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.isPro});
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Ustawienia',
              style: GoogleFonts.syne(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.kTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (isPro)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.kAccentGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'PRO',
                style: GoogleFonts.syne(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBgDeep,
                  letterSpacing: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Etykieta sekcji ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.kTextMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Sekcja: Dzwonka ───────────────────────────────────────────────────────────

class _RingtoneSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_RingtoneSection> createState() => _RingtoneSectionState();
}

class _RingtoneSectionState extends ConsumerState<_RingtoneSection> {
  RingtoneType? _selected;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final prefs = await ref.read(userPrefsServiceProvider).getOrCreate();
    final id = prefs['selected_ringtone'] as String?;
    if (!mounted) return;
    setState(() {
      _selected = id != null
          ? RingtoneType.values.firstWhere(
              (r) => r.resourceId == id,
              orElse: () => RingtoneType.defaultRingtone,
            )
          : RingtoneType.defaultRingtone;
    });
  }

  Future<void> _select(RingtoneType ringtone) async {
    setState(() => _selected = ringtone);
    AlarmService.setRingtone(ringtone);
    await ref.read(userPrefsServiceProvider).setSelectedRingtone(ringtone);
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: RingtoneType.values.map((ringtone) {
          final isSelected = _selected == ringtone;
          final isLast = ringtone == RingtoneType.values.last;
          return Column(
            children: [
              _RingtoneTile(
                ringtone: ringtone,
                isSelected: isSelected,
                onTap: () => _select(ringtone),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  color: AppColors.kBorder,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _RingtoneTile extends StatelessWidget {
  const _RingtoneTile({
    required this.ringtone,
    required this.isSelected,
    required this.onTap,
  });

  final RingtoneType ringtone;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.kAccent : AppColors.kBorder,
                  width: isSelected ? 5 : 2,
                ),
                color: AppColors.kBgCard,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ringtone.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.kTextPrimary
                          : AppColors.kTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ringtone.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.music_note_outlined,
              size: 16,
              color:
                  isSelected ? AppColors.kAccent : AppColors.kTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sekcja: Konto ─────────────────────────────────────────────────────────────

class _AccountSection extends ConsumerWidget {
  const _AccountSection({required this.isPro});
  final bool isPro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Card(
      child: Column(
        children: [
          if (!isPro) ...[
            _SettingsTile(
              icon: Icons.star_outline_rounded,
              iconColor: AppColors.kWarning,
              title: 'Przejdź na Pro',
              subtitle: 'Full Cycle, nieograniczone sloty',
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.kAccentGlow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Kup',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.kAccent,
                  ),
                ),
              ),
              onTap: () => context.push('/paywall'),
            ),
            const Divider(height: 1, color: AppColors.kBorder),
            _SettingsTile(
              icon: Icons.restore_rounded,
              iconColor: AppColors.kTextMuted,
              title: 'Przywróć zakup',
              onTap: () => ref.read(proActionsProvider.notifier).restore(),
            ),
          ] else
            _SettingsTile(
              icon: Icons.verified_rounded,
              iconColor: AppColors.kAccent,
              title: 'NapStack Pro aktywny',
              subtitle: 'Wszystkie funkcje odblokowane',
              onTap: null,
            ),
        ],
      ),
    );
  }
}

// ── Sekcja: Informacje ────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.shield_outlined,
            iconColor: AppColors.kTextSecondary,
            title: 'Polityka prywatności',
            onTap: () => context.push('/legal/privacy'),
          ),
          const Divider(height: 1, color: AppColors.kBorder),
          _SettingsTile(
            icon: Icons.description_outlined,
            iconColor: AppColors.kTextSecondary,
            title: 'Regulamin',
            onTap: () => context.push('/legal/terms'),
          ),
          const Divider(height: 1, color: AppColors.kBorder),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.kTextSecondary,
            title: 'Informacje prawne',
            onTap: () => context.push('/legal'),
          ),
        ],
      ),
    );
  }
}

// ── Reużywalne elementy ───────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kBorder, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.kTextPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.kTextMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.kTextMuted,
                        size: 20,
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
