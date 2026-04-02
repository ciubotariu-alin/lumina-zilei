import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/feature_flags.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

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
            final dailyQuote = provider.dailyQuote;

            return CustomScrollView(
              slivers: [
                // App Bar with cross icon
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.surfaceColor,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x15000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Column(
                      children: [
                        // Orthodox cross
                        const Icon(
                          Icons.add,
                          size: 48,
                          color: AppTheme.goldColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'LUMINA ZILEI',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(letterSpacing: 3),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 1,
                          width: 120,
                          color: AppTheme.goldColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _formatDateRomanian(today),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.accentGoldLight,
                                    fontStyle: FontStyle.italic,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Saints of the day section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.church,
                                color: AppTheme.goldColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Astăzi prăznuim:',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (todayInfo != null) ...[
                          if (todayInfo.sarbatoare.isNotEmpty)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF5EDE0),
                                    Color(0xFFFAF6F0),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.goldColor,
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppTheme.goldColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      todayInfo.sarbatoare,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppTheme.goldColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (todayInfo.sarbatoare.isNotEmpty &&
                              todayInfo.sfinti.isNotEmpty)
                            const SizedBox(height: 8),
                          ...todayInfo.sfinti.map(
                            (saint) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppTheme.cardColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.dividerColor,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.goldColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        saint,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ] else
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Nu există informații pentru această zi',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Verse of the day
                if (dailyQuote != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_stories,
                                  color: AppTheme.goldColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Versetul zilei',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFF5EDE0),
                                  Color(0xFFFAF6F0),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.goldColor.withOpacity(0.4),
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '"${dailyQuote.text}"',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: AppTheme.creamColor,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    dailyQuote.reference,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Quick action buttons
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

                // Donation card
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
                            const Icon(
                              Icons.volunteer_activism,
                              color: AppTheme.goldColor,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                            const Icon(
                              Icons.chevron_right,
                              color: AppTheme.goldColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

}

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
          border: Border.all(
            color: AppTheme.goldColor.withOpacity(0.4),
          ),
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
