import 'package:flutter/material.dart';

import '../models/prayer.dart';
import '../theme/app_theme.dart';

class PrayerDetailScreen extends StatefulWidget {
  final Prayer prayer;

  const PrayerDetailScreen({super.key, required this.prayer});

  @override
  State<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends State<PrayerDetailScreen> {
  double _fontSize = 16.0;
  static const double _minFontSize = 12.0;
  static const double _maxFontSize = 26.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.prayer.titlu,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Font size controls
          IconButton(
            icon: const Icon(Icons.text_decrease),
            tooltip: 'Micșorează textul',
            onPressed: _fontSize > _minFontSize
                ? () => setState(() => _fontSize -= 2)
                : null,
            color: _fontSize > _minFontSize
                ? AppTheme.goldColor
                : AppTheme.goldColor.withOpacity(0.3),
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            tooltip: 'Mărește textul',
            onPressed: _fontSize < _maxFontSize
                ? () => setState(() => _fontSize += 2)
                : null,
            color: _fontSize < _maxFontSize
                ? AppTheme.goldColor
                : AppTheme.goldColor.withOpacity(0.3),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Prayer title banner
          Container(
            width: double.infinity,
            color: AppTheme.surfaceColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book,
                  color: AppTheme.goldColor,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.prayer.titlu,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),

          // Decorative divider
          Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.goldColor,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Prayer text
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ornamental cross at top
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Icon(
                        Icons.add,
                        color: AppTheme.goldColor,
                        size: 28,
                      ),
                    ),
                  ),

                  // Prayer text
                  Text(
                    widget.prayer.text,
                    style: TextStyle(
                      color: AppTheme.creamColor,
                      fontSize: _fontSize,
                      height: 1.8,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  // Bottom ornament
                  const SizedBox(height: 32),
                  const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 40,
                          child: Divider(color: AppTheme.goldColor, thickness: 1),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.add,
                            color: AppTheme.goldColor,
                            size: 16,
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Divider(color: AppTheme.goldColor, thickness: 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
