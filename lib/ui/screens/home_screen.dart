import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/appwrite/appwrite_client.dart';
import '../../core/theme/app_colors.dart';
import '../../features/pro/pro_provider.dart';
import '../../features/timer/nap_preset.dart';
import '../widgets/preset_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(proStatusProvider).value ?? false;

    return Scaffold(
      backgroundColor: AppColors.kBgBase,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _Header(isPro: isPro)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList.builder(
                itemCount: kPresets.length,
                itemBuilder: (context, i) {
                  final preset = kPresets[i];
                  final locked = preset.isPro && !isPro;
                  return PresetCard(
                    preset: preset,
                    isLocked: locked,
                    onTap: () => locked
                        ? context.push('/paywall')
                        : context.push('/timer/${preset.type.name}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isPro});
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Logo + brand
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.kAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.kAccent.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.nightlight_round,
                        color: AppColors.kAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NapStack',
                          style: GoogleFonts.syne(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.kTextPrimary,
                          ),
                        ),
                        Text(
                          'by Patryk AI',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: AppColors.kTextMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.kTextSecondary,
                  size: 22,
                ),
                tooltip: 'Ustawienia',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              IconButton(
                onPressed: () => context.push('/legal'),
                icon: const Icon(
                  Icons.policy_outlined,
                  color: AppColors.kTextSecondary,
                  size: 22,
                ),
                tooltip: 'Informacje prawne',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: 4),

              // Pro badge lub ikona zakupu
              if (isPro)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.kAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.kAccent.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: AppColors.kAccent, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'Pro',
                        style: GoogleFonts.syne(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.kAccent,
                        ),
                      ),
                    ],
                  ),
                )
              else
                GestureDetector(
                  onTap: () => context.push('/paywall'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.kBgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.kBorder, width: 1),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_outlined,
                      color: AppColors.kTextSecondary,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 28),

          // Greeting
          Text(
            _greeting(),
            style: GoogleFonts.syne(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.kTextPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Wybierz preset i naciśnij start.',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppColors.kTextSecondary,
            ),
          ),

          if (kDebugMode) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  try {
                    final response = await client.ping();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ping: $response')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ping failed: $e')),
                    );
                  }
                },
                child: Text(
                  'Send a ping',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 4),

          Text(
            'PRESETY',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.kTextMuted,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6)  return 'Dobranoc,\nśpiący kosmonauto.';
    if (hour < 12) return 'Dzień dobry.\nCzas na drzemkę?';
    if (hour < 17) return 'Popołudniowy\nreboot gotowy.';
    if (hour < 21) return 'Wieczorny\nreset układu.';
    return 'Nocna cisza\nna wyciągnięcie ręki.';
  }
}
