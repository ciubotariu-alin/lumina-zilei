import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../models/saint.dart';
import '../models/fasting_info.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentMonth;
  final DateTime _today = DateTime.now();

  static const List<String> _romanianMonths = [
    '',
    'Ianuarie', 'Februarie', 'Martie', 'Aprilie', 'Mai', 'Iunie',
    'Iulie', 'August', 'Septembrie', 'Octombrie', 'Noiembrie', 'Decembrie',
  ];

  static const List<String> _romanianDaysShort = [
    'Lun', 'Mar', 'Mie', 'Joi', 'Vin', 'Sâm', 'Dum',
  ];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(_today.year, _today.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  bool _isToday(DateTime date) {
    return date.year == _today.year &&
        date.month == _today.month &&
        date.day == _today.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Calendar Ortodox'),
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Icon(Icons.calendar_month, color: AppTheme.goldColor),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.goldColor),
            );
          }

          return Column(
            children: [
              // Month navigation header
              Container(
                color: AppTheme.surfaceColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: AppTheme.goldColor),
                      onPressed: _previousMonth,
                    ),
                    Column(
                      children: [
                        Text(
                          _romanianMonths[_currentMonth.month],
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(fontSize: 22),
                        ),
                        Text(
                          _currentMonth.year.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color:
                                    AppTheme.accentGoldLight.withOpacity(0.8),
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right,
                          color: AppTheme.goldColor),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),

              // Day headers
              Container(
                color: AppTheme.surfaceColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 8),
                child: Row(
                  children: _romanianDaysShort
                      .map(
                        (day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: day == 'Dum'
                                        ? AppTheme.deepRedColor
                                            .withOpacity(0.9)
                                        : AppTheme.accentGoldLight
                                            .withOpacity(0.7),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              Container(
                height: 1,
                color: AppTheme.dividerColor,
              ),

              // Calendar grid
              Expanded(
                child: _buildCalendarGrid(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, AppProvider provider) {
    final firstDay = _currentMonth;
    final daysInMonth = DateUtils.getDaysInMonth(
        _currentMonth.year, _currentMonth.month);

    // Weekday of first day (1=Mon, 7=Sun) -> 0-indexed for grid
    int startWeekday = firstDay.weekday - 1; // 0-indexed Monday

    final totalCells = startWeekday + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: rowCount,
      itemBuilder: (context, rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          child: Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNum = cellIndex - startWeekday + 1;

              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 70));
              }

              final date = DateTime(
                  _currentMonth.year, _currentMonth.month, dayNum);
              final dayInfo = provider.getDayInfo(date);
              final isToday = _isToday(date);
              final isSunday = colIndex == 6;
              final hasFeast = dayInfo?.hasFeast ?? false;

              return Expanded(
                child: _DayCell(
                  dayNumber: dayNum,
                  dayInfo: dayInfo,
                  isToday: isToday,
                  isSunday: isSunday,
                  hasFeast: hasFeast,
                  onTap: () => _showDayDetails(context, date, dayInfo),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  void _showDayDetails(
      BuildContext context, DateTime date, CalendarDay? dayInfo) {
    const months = [
      '', 'Ianuarie', 'Februarie', 'Martie', 'Aprilie', 'Mai', 'Iunie',
      'Iulie', 'August', 'Septembrie', 'Octombrie', 'Noiembrie', 'Decembrie',
    ];
    final dateStr = '${date.day} ${months[date.month]} ${date.year}';
    final fastingFuture =
        context.read<AppProvider>().getFastingInfo(date);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DayDetailSheet(
        dateString: dateStr,
        dayInfo: dayInfo,
        fastingFuture: fastingFuture,
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int dayNumber;
  final CalendarDay? dayInfo;
  final bool isToday;
  final bool isSunday;
  final bool hasFeast;
  final VoidCallback onTap;

  const _DayCell({
    required this.dayNumber,
    required this.dayInfo,
    required this.isToday,
    required this.isSunday,
    required this.hasFeast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppTheme.backgroundColor;
    Color dayNumberColor = AppTheme.creamColor;
    Color borderColor = Colors.transparent;
    double borderWidth = 0;

    if (isToday) {
      bgColor = AppTheme.goldColor.withOpacity(0.2);
      borderColor = AppTheme.goldColor;
      borderWidth = 1.5;
      dayNumberColor = AppTheme.goldColor;
    } else if (hasFeast) {
      bgColor = AppTheme.deepRedColor.withOpacity(0.1);
    }

    if (isSunday && !isToday) {
      dayNumberColor = AppTheme.deepRedColor.withOpacity(0.9);
    }

    final saintText = dayInfo?.shortDisplayText ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 68,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: isToday
                      ? const BoxDecoration(
                          color: AppTheme.goldColor,
                          shape: BoxShape.circle,
                        )
                      : null,
                  child: Center(
                    child: Text(
                      dayNumber.toString(),
                      style: TextStyle(
                        color: isToday ? AppTheme.backgroundColor : dayNumberColor,
                        fontSize: 12,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                if (hasFeast)
                  const Icon(
                    Icons.star,
                    color: AppTheme.goldColor,
                    size: 10,
                  ),
              ],
            ),
            if (saintText.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    saintText,
                    style: TextStyle(
                      color: hasFeast
                          ? AppTheme.goldColor
                          : AppTheme.creamColor.withOpacity(0.6),
                      fontSize: 8,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayDetailSheet extends StatelessWidget {
  final String dateString;
  final CalendarDay? dayInfo;
  final Future<FastingInfo?> fastingFuture;

  const _DayDetailSheet({
    required this.dateString,
    this.dayInfo,
    required this.fastingFuture,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date header
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: AppTheme.goldColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    dateString,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sărbătoare
              if (dayInfo != null && dayInfo!.sarbatoare.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.goldColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.goldColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star,
                          color: AppTheme.goldColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dayInfo!.sarbatoare,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: AppTheme.goldColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Sfinții zilei
              if (dayInfo != null && dayInfo!.sfinti.isNotEmpty) ...[
                Text(
                  'Sfinții zilei:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                ...dayInfo!.sfinti.map(
                  (saint) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6, right: 8),
                          child: Icon(
                            Icons.circle,
                            color: AppTheme.goldColor,
                            size: 6,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            saint,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Apostol
              if (dayInfo != null && dayInfo!.apostol.isNotEmpty) ...[
                _ReadingCard(
                  icon: Icons.menu_book,
                  label: 'Apostol',
                  text: dayInfo!.apostol,
                ),
                const SizedBox(height: 12),
              ],

              // Evanghelie
              if (dayInfo != null && dayInfo!.evanghelie.isNotEmpty) ...[
                _ReadingCard(
                  icon: Icons.auto_stories,
                  label: 'Evanghelie',
                  text: dayInfo!.evanghelie,
                ),
                const SizedBox(height: 12),
              ],

              // Post (OCMA-API) — afișat pentru TOATE zilele
              _FastingSection(fastingFuture: fastingFuture),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;

  const _ReadingCard({
    required this.icon,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppTheme.accentGoldLight.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accentGoldLight, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.accentGoldLight,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _FastingSection extends StatelessWidget {
  final Future<FastingInfo?> fastingFuture;

  const _FastingSection({required this.fastingFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FastingInfo?>(
      future: fastingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppTheme.goldColor,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }
        final fasting = snapshot.data;
        if (fasting == null) return const SizedBox.shrink();

        final Color levelColor;
        final IconData levelIcon;

        if (fasting.isTotalFast) {
          levelColor = const Color(0xFFB71C1C); // roșu închis
          levelIcon = Icons.block;
        } else if (fasting.isStrictFast) {
          levelColor = const Color(0xFFE53935); // roșu
          levelIcon = Icons.remove_circle_outline;
        } else if (fasting.isFasting) {
          levelColor = AppTheme.goldColor; // auriu
          levelIcon = Icons.no_food;
        } else {
          levelColor = const Color(0xFF388E3C); // verde
          levelIcon = Icons.check_circle_outline;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: levelColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: levelColor.withOpacity(0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(levelIcon, color: levelColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fasting.laymenLevel,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: levelColor),
                    ),
                  ),
                ],
              ),
              if (fasting.season.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  fasting.season,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.accentGoldLight.withOpacity(0.7),
                      ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
