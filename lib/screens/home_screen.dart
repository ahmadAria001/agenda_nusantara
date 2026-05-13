import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/home_controller.dart';
import 'add_important_task_screen.dart';
import 'add_normal_task_screen.dart';
import 'settings_screen.dart';
import 'task_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().fetchDashboardMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<HomeController>().fetchDashboardMetrics();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, User!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Card(
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        color: theme.colorScheme.onSurfaceVariant,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Summary Cards ──────────────────────────────────────────
                Consumer<HomeController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading && controller.completedCount == 0 && controller.pendingCount == 0) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Tugas Selesai',
                            count: controller.completedCount,
                            color: theme.colorScheme.tertiary,
                            icon: Icons.check_circle_outline_rounded,
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Belum Selesai',
                            count: controller.pendingCount,
                            color: theme.colorScheme.error,
                            icon: Icons.pending_actions_rounded,
                            theme: theme,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // ── Chart Section ──────────────────────────────────────────
                Text(
                  'Produktivitas Harian',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Container(
                    height: 220,
                    padding: const EdgeInsets.only(
                        right: 24, left: 16, top: 24, bottom: 12),
                    child: Consumer<HomeController>(
                      builder: (context, controller, child) {
                        if (controller.completedTasksPerDay.isEmpty) {
                          return Center(
                            child: Text(
                              'Belum ada data tugas selesai',
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          );
                        }
                        return _buildChart(controller.completedTasksPerDay, theme);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Navigation Grid ──────────────────────────────────────────
                Text(
                  'Menu Utama',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _NavButton(
                      title: 'Daftar Tugas',
                      icon: Icons.format_list_bulleted_rounded,
                      color: theme.colorScheme.primary,
                      theme: theme,
                      onTap: () {
                        final homeController = context.read<HomeController>();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const TaskListScreen()),
                        ).then((_) {
                          homeController.fetchDashboardMetrics();
                        });
                      },
                    ),
                    _NavButton(
                      title: 'Tambah Biasa',
                      icon: Icons.add_task_rounded,
                      color: theme.colorScheme.tertiary,
                      theme: theme,
                      onTap: () {
                        final homeController = context.read<HomeController>();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const AddNormalTaskScreen()),
                        ).then((_) {
                          homeController.fetchDashboardMetrics();
                        });
                      },
                    ),
                    _NavButton(
                      title: 'Tambah Penting',
                      icon: Icons.add_alert_rounded,
                      color: theme.colorScheme.error,
                      theme: theme,
                      onTap: () {
                        final homeController = context.read<HomeController>();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const AddImportantTaskScreen()),
                        ).then((_) {
                          homeController.fetchDashboardMetrics();
                        });
                      },
                    ),
                    _NavButton(
                      title: 'Pengaturan',
                      icon: Icons.settings_suggest_rounded,
                      color: theme.colorScheme.secondary,
                      theme: theme,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(Map<String, int> data, ThemeData theme) {
    final sortedKeys = data.keys.toList()..sort();
    final spots = <FlSpot>[];
    double maxX = 0;
    double maxY = 0;

    for (int i = 0; i < sortedKeys.length; i++) {
      final val = data[sortedKeys[i]]!.toDouble();
      spots.add(FlSpot(i.toDouble(), val));
      if (val > maxY) maxY = val;
      maxX = i.toDouble();
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outlineVariant,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sortedKeys.length) {
                  return const SizedBox();
                }
                final dateStr = sortedKeys[index];
                DateTime? date = DateTime.tryParse(dateStr);
                String text = date != null ? '${date.day}/${date.month}' : '';
                return SideTitleWidget(
                  meta: meta,
                  child: Text(text, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value == value.toInt().toDouble()) {
                  return Text(value.toInt().toString(), 
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10),
                    textAlign: TextAlign.right,
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: maxY + 1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: theme.colorScheme.surface,
                strokeWidth: 2,
                strokeColor: theme.colorScheme.primary,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final ThemeData theme;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              count.toString(),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final ThemeData theme;
  final VoidCallback onTap;

  const _NavButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
