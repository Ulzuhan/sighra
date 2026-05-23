import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../providers/stats_provider.dart';
import '../widgets/glassmorphic_card.dart';
import 'package:respiro/l10n/app_localizations.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<StatsProvider>(context, listen: false).fetchStats();
      }
    });
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statsProv = Provider.of<StatsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    // Generate the last 30 calendar days for the habit map grid
    final List<DateTime> past30Days = List.generate(30, (index) {
      return DateTime.now().subtract(Duration(days: 29 - index));
    });

    // Build session duration map keyed by YYYY-MM-DD for visual calendar indexing
    final Map<String, int> dailyDurationSeconds = {};
    for (final log in statsProv.history) {
      final dateStr = _formatDate(log.timestamp);
      dailyDurationSeconds[dateStr] = (dailyDurationSeconds[dateStr] ?? 0) + log.durationSeconds;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.tabStats.toUpperCase(),
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isDark ? primaryColor : const Color(0xFF007A7A),
          ),
        ),
      ),
      body: SafeArea(
        child: statsProv.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                children: [
                  // KPI Scoreboard Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          l10n.statsMinutesBreathed,
                          "${statsProv.totalMinutes}",
                          Icons.timer,
                          primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          l10n.statsSessionsCount,
                          "${statsProv.totalSessions}",
                          Icons.done_all,
                          secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          l10n.statsActiveStreak,
                          "${statsProv.streak}",
                          Icons.local_fire_department,
                          Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Weekly Progress Bar Chart
                  Text(
                    "WEEKLY FOCUS PROGRESS",
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GlassmorphicCard(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                          child: Text(
                            "Calming minutes practiced this week:",
                            style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                        SizedBox(
                          height: 140,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: WeeklyBarChartPainter(
                              data: statsProv.weeklyCalmMinutes,
                              primaryColor: primaryColor,
                              secondaryColor: secondaryColor,
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 30-Day Habits Grid Calendar
                  Text(
                    "30-DAY HABIT CONSISTENCY",
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GlassmorphicCard(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 10,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          itemCount: 30,
                          itemBuilder: (context, index) {
                            final date = past30Days[index];
                            final dateStr = _formatDate(date);
                            final secs = dailyDurationSeconds[dateStr] ?? 0;
                            final double mins = secs / 60.0;

                            // Determine contribution shade based on practice intensity
                            Color boxColor;
                            double glowIntensity = 0.0;
                            if (mins == 0) {
                              boxColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.05);
                            } else if (mins < 3.0) {
                              boxColor = primaryColor.withValues(alpha: 0.25);
                            } else if (mins < 8.0) {
                              boxColor = primaryColor.withValues(alpha: 0.55);
                              glowIntensity = 0.2;
                            } else {
                              boxColor = primaryColor;
                              glowIntensity = 0.5;
                            }

                            return Tooltip(
                              message: "${DateFormat.MMMd().format(date)}: ${mins.toStringAsFixed(1)} mins",
                              preferBelow: false,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: boxColor,
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(
                                    color: mins > 0
                                        ? primaryColor.withValues(alpha: 0.5)
                                        : Colors.transparent,
                                    width: 0.5,
                                  ),
                                  boxShadow: glowIntensity > 0
                                      ? [
                                          BoxShadow(
                                            color: primaryColor.withValues(alpha: glowIntensity * 0.3),
                                            blurRadius: 4,
                                            spreadRadius: 0.5,
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Less",
                              style: GoogleFonts.montserrat(fontSize: 9, color: Colors.grey),
                            ),
                            const SizedBox(width: 4),
                            _buildLegendBox(isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.05)),
                            const SizedBox(width: 4),
                            _buildLegendBox(primaryColor.withValues(alpha: 0.25)),
                            const SizedBox(width: 4),
                            _buildLegendBox(primaryColor.withValues(alpha: 0.55)),
                            const SizedBox(width: 4),
                            _buildLegendBox(primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              "More",
                              style: GoogleFonts.montserrat(fontSize: 9, color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // History Title Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.statsHistoryTitle.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.grey,
                        ),
                      ),
                      if (statsProv.history.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                          onPressed: () {
                            _showWipeDialog(context, l10n, statsProv);
                          },
                        )
                    ],
                  ),
                  const Divider(color: Colors.grey, thickness: 0.3),
                  const SizedBox(height: 10),

                  if (statsProv.history.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.spa_outlined, size: 54, color: Colors.grey.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text(
                            l10n.statsEmptyHistory,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Colors.grey,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Recent calming log list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: statsProv.history.length,
                      itemBuilder: (context, index) {
                        final log = statsProv.history[index];
                        final dateStr = DateFormat.yMMMd().add_jm().format(log.timestamp);
                        final durationMin = (log.durationSeconds / 60).toStringAsFixed(1);
                        
                        String patternName = log.patternId;
                        if (log.patternId == 'box_breathing') {
                          patternName = l10n.exerciseBoxTitle.split(' (').first;
                        } else if (log.patternId == '478_technique') {
                          patternName = l10n.exercise478Title;
                        } else if (log.patternId == 'cardiac_coherence') {
                          patternName = l10n.exerciseCardioTitle.split(' (').first;
                        } else {
                          // Capitalize and format custom patterns cleanly
                          patternName = log.patternId.replaceAll('_', ' ').split(' ').map((word) => 
                            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}'
                          ).join(' ');
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: GlassmorphicCard(
                            padding: const EdgeInsets.all(10.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.air, color: primaryColor, size: 20),
                              ),
                              title: Text(
                                patternName,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                dateStr,
                                style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey),
                              ),
                              trailing: Text(
                                "${durationMin}m",
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ]
                ],
              ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      borderColor: color.withValues(alpha: 0.25),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(Color c) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }

  void _showWipeDialog(BuildContext context, AppLocalizations l10n, StatsProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        final navigator = Navigator.of(context);
        return AlertDialog(
          title: Text(l10n.btnConfirm, style: GoogleFonts.cinzel(color: Colors.redAccent)),
          content: Text(
            "Clear all of your micro-breathing statistical data and session history?",
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          actions: [
            TextButton(
              child: Text(l10n.btnCancel, style: GoogleFonts.montserrat(color: Colors.grey)),
              onPressed: () => navigator.pop(),
            ),
            TextButton(
              child: Text(l10n.btnDelete, style: GoogleFonts.montserrat(color: Colors.red)),
              onPressed: () async {
                await provider.wipeStats();
                navigator.pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class WeeklyBarChartPainter extends CustomPainter {
  final Map<int, double> data;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  WeeklyBarChartPainter({
    required this.data,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double padding = 15.0;
    final double chartWidth = size.width - 2 * padding;
    final double chartHeight = size.height - 35.0;

    final double barSpacing = chartWidth / 7;
    final double barWidth = 14.0;

    // Establish maximum vertical scale (baseline at least 10 minutes)
    double maxVal = 10.0;
    for (final val in data.values) {
      if (val > maxVal) maxVal = val;
    }

    final paintLine = Paint()
      ..color = isDark ? Colors.white10 : Colors.black12;
      
    // Draw divisions horizontal guides
    for (int i = 0; i <= 3; i++) {
      final double y = chartHeight - (i * chartHeight / 3) + 10.0;
      canvas.drawLine(Offset(padding, y), Offset(size.width - padding, y), paintLine);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    for (int i = 0; i < 7; i++) {
      final weekdayIndex = i + 1;
      final val = data[weekdayIndex] ?? 0.0;
      
      final double barHeight = (val / maxVal) * chartHeight;
      final double x = padding + (i * barSpacing) + (barSpacing - barWidth) / 2;
      final double y = chartHeight - barHeight + 10.0;

      if (val > 0.0) {
        final barRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(5),
        );
        final paintBar = Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [primaryColor, secondaryColor],
          ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));
        canvas.drawRRect(barRect, paintBar);
      } else {
        // Subtle inactive point
        final paintEmpty = Paint()
          ..color = isDark ? Colors.white12 : Colors.black12
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x + barWidth / 2, chartHeight + 10.0 - 4), 2.5, paintEmpty);
      }

      // Draw horizontal day labels
      textPainter.text = TextSpan(
        text: days[i],
        style: GoogleFonts.montserrat(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, chartHeight + 16.0),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WeeklyBarChartPainter oldDelegate) {
    return oldDelegate.data != data ||
           oldDelegate.primaryColor != primaryColor ||
           oldDelegate.secondaryColor != secondaryColor ||
           oldDelegate.isDark != isDark;
  }
}
