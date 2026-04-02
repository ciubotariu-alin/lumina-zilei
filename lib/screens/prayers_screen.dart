import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../models/prayer.dart';
import '../theme/app_theme.dart';
import 'prayer_detail_screen.dart';

class PrayersScreen extends StatelessWidget {
  const PrayersScreen({super.key});

  IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'nightlight_round':
        return Icons.nightlight_round;
      case 'star':
        return Icons.star;
      case 'menu_book':
        return Icons.menu_book;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Rugăciuni'),
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Icon(Icons.menu_book, color: AppTheme.goldColor),
        ),
      ),
      body: Consumer<AppProvider>(
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

          final categories = provider.allPrayers;

          if (categories.isEmpty) {
            return const Center(
              child: Text(
                'Nu s-au găsit rugăciuni.',
                style: TextStyle(color: AppTheme.creamColor),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryExpansionTile(
                category: category,
                iconData: _iconFromString(category.icon),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryExpansionTile extends StatefulWidget {
  final PrayerCategory category;
  final IconData iconData;

  const _CategoryExpansionTile({
    required this.category,
    required this.iconData,
  });

  @override
  State<_CategoryExpansionTile> createState() => _CategoryExpansionTileState();
}

class _CategoryExpansionTileState extends State<_CategoryExpansionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _expanded
              ? AppTheme.goldColor.withOpacity(0.6)
              : AppTheme.dividerColor,
          width: _expanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Category header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.goldColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.iconData,
                      color: AppTheme.goldColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.nume,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.category.rugaciuni.length} rugăciuni',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.goldColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Prayer list
          if (_expanded)
            Column(
              children: [
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: AppTheme.dividerColor,
                ),
                ...widget.category.rugaciuni.map(
                  (prayer) => _PrayerListTile(
                    prayer: prayer,
                    isLast: prayer == widget.category.rugaciuni.last,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PrayerListTile extends StatelessWidget {
  final Prayer prayer;
  final bool isLast;

  const _PrayerListTile({required this.prayer, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrayerDetailScreen(prayer: prayer),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(right: 12, left: 4),
                  decoration: const BoxDecoration(
                    color: AppTheme.goldColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    prayer.titlu,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.creamColor,
                        ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.goldColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppTheme.dividerColor.withOpacity(0.5),
          ),
      ],
    );
  }
}
