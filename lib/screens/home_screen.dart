import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/feature_flags.dart';
import '../models/saint.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';
import 'acatist_request_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int index) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  String _formatDateRomanian(DateTime date) {
    const days = [
      'Luni', 'Marți', 'Miercuri', 'Joi', 'Vineri', 'Sâmbătă', 'Duminică'
    ];
    const months = [
      '', 'Ianuarie', 'Februarie', 'Martie', 'Aprilie', 'Mai', 'Iunie',
      'Iulie', 'August', 'Septembrie', 'Octombrie', 'Noiembrie', 'Decembrie'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.goldColor),
              );
            }
            if (provider.error != null) {
              return Center(
                child: Text(
                  'Eroare: ${provider.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final today = DateTime.now();
            final todayInfo = provider.todayInfo;
            final dailyAcatist = provider.dailyAcatist;
            final dailyRugaciune = provider.dailyRugaciune;

            return CustomScrollView(
              slivers: [
                // ── 1. App bar ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.surfaceColor,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x15000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 10, 8, 14),
                    child: Column(
                      children: [
                        // Rând 1: cruce + titlu + setări
                        Row(
                          children: [
                            Image.asset(
                              'assets/pictures/Cross.png',
                              width: 28,
                              height: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'LUMINA ZILEI',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(letterSpacing: 3),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.settings,
                                color: AppTheme.goldColor,
                                size: 22,
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              ),
                              tooltip: 'Setări',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Rând 2: data
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _formatDateRomanian(today),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.accentGoldLight,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── 2. Hero card ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: _HeroCard(
                      todayInfo: todayInfo,
                      onShowToday: () => CalendarScreen.showDayDetails(
                        context,
                        today,
                        todayInfo,
                      ),
                    ),
                  ),
                ),

                // ── 3. CTA dominant — Rugăciunea Zilei ──────────────────
                if (dailyRugaciune != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: _CtaCard(
                        icon: Icons.auto_stories,
                        label: 'Rugăciunea Zilei',
                        title: dailyRugaciune.titlu,
                        onTap: () => _showFullText(
                          context,
                          dailyRugaciune.titlu,
                          dailyRugaciune.text,
                        ),
                      ),
                    ),
                  ),

                // ── 4. Acatistul Zilei ───────────────────────────────────
                if (dailyAcatist != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: _SecondaryCard(
                        icon: Icons.menu_book,
                        label: 'Acatistul Zilei',
                        title: dailyAcatist.titlu,
                        onTap: () => _showFullText(
                          context,
                          dailyAcatist.titlu,
                          dailyAcatist.text,
                        ),
                      ),
                    ),
                  ),

                // ── 5. Acces rapid ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.touch_app,
                                color: AppTheme.goldColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Acces rapid',
                              style:
                                  Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.menu_book,
                                label: 'Rugăciuni',
                                subtitle: 'Rugăciunile zilei',
                                onTap: () => onNavigate(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.calendar_month,
                                label: 'Calendar',
                                subtitle: 'Sfinții lunii',
                                onTap: () => onNavigate(1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── 6. Cerere acatist la parohie ────────────────────────
                if (FeatureFlags.acatistRequestEnabled)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AcatistRequestScreen(),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.goldColor.withOpacity(0.35),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      AppTheme.goldColor.withOpacity(0.1),
                                ),
                                child: const Icon(Icons.church,
                                    color: AppTheme.goldColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cerere acatist la parohie',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Trimite o cerere de rugăciune către parohia ta',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppTheme.goldColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── 7. Donație (ascunsă) ─────────────────────────────────
                if (FeatureFlags.donationsEnabled)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      child: InkWell(
                        onTap: () => onNavigate(4),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.goldColor.withOpacity(0.25),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.volunteer_activism,
                                  color: AppTheme.goldColor, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Această aplicație este gratuită',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Susține-ne cu o donație mică 🙏',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppTheme.goldColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showFullText(BuildContext context, String title, String text) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: AppTheme.goldColor),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(color: AppTheme.dividerColor),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final CalendarDay? todayInfo;
  final VoidCallback onShowToday;

  const _HeroCard({
    required this.todayInfo,
    required this.onShowToday,
  });

  String get _principalText {
    final info = todayInfo;
    if (info == null) return 'Zi fără sărbătoare mare';
    if (info.sarbatoare.isNotEmpty) return info.sarbatoare;
    if (info.sfinti.isNotEmpty) return info.sfinti.first;
    return 'Zi fără sărbătoare mare';
  }

  // Sfinții afișați sub "Astăzi sunt pomeniți și:"
  List<String> get _additionalSaints {
    final info = todayInfo;
    if (info == null) return [];
    if (info.sarbatoare.isNotEmpty) return info.sfinti;
    if (info.sfinti.length > 1) return info.sfinti.sublist(1);
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final saints = _additionalSaints;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0E6D3), Color(0xFFFAF6F0)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.goldColor, width: 1.5),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            'ASTĂZI',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.goldColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 8),
          // Sărbătoarea principală
          Text(
            _principalText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textBrownColor,
                  fontWeight: FontWeight.bold,
                  height: 1.35,
                ),
          ),
          // Sfinții suplimentari — primul truncat
          if (saints.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Astăzi sunt pomeniți și:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentGoldLight,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppTheme.goldColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    saints.length == 1
                        ? saints.first
                        : '${saints.first}${saints.length > 1 ? ' și alții' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textBrownColor,
                          height: 1.4,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // CTA
          GestureDetector(
            onTap: onShowToday,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.goldColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.goldColor.withOpacity(0.4),
                ),
              ),
              child: Text(
                'Vezi ziua de astăzi',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.goldColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CTA dominant card (Rugăciunea Zilei) ─────────────────────────────────────

class _CtaCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final VoidCallback onTap;

  const _CtaCard({
    required this.icon,
    required this.label,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8C97A), Color(0xFFF5E4AA)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.goldColor.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.35),
              ),
              child: Icon(icon, color: const Color(0xFF5A3E00), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF7A5200),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          fontSize: 11,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF3A2600),
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Citește tot',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF5A3E00),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Secondary card (Acatistul Zilei) ─────────────────────────────────────────

class _SecondaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final VoidCallback onTap;

  const _SecondaryCard({
    required this.icon,
    required this.label,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5EDE0), Color(0xFFFAF6F0)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.goldColor.withOpacity(0.4)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.goldColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.goldColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          fontSize: 11,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textBrownColor,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Citește tot',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.goldColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick action button ───────────────────────────────────────────────────────

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.goldColor.withOpacity(0.4)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.goldColor, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
