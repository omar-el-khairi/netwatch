import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supervision_mobile/core/api_client.dart';
import 'package:supervision_mobile/core/theme.dart';
import 'package:supervision_mobile/features/servers/server_detail_cubit.dart';
import 'package:supervision_mobile/widgets/nw_widgets.dart';

class ServerDetailPage extends StatelessWidget {
  const ServerDetailPage({super.key, required this.serverId, required this.serverName});

  final String serverId;
  final String serverName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ServerDetailCubit(context.read<ApiClient>(), serverId)..startAutoRefresh(),
      child: _ServerDetailView(serverName: serverName),
    );
  }
}

class _ServerDetailView extends StatelessWidget {
  const _ServerDetailView({required this.serverName});

  final String serverName;

  double _n(dynamic v) => v is num ? v.toDouble() : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NwColors.bg,
      appBar: AppBar(
        title: Text(serverName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<ServerDetailCubit>().load(),
          ),
        ],
      ),
      body: BlocBuilder<ServerDetailCubit, ServerDetailState>(
        builder: (context, state) {
          if (state.loading && state.server == null) {
            return const Center(child: CircularProgressIndicator(color: NwColors.accent));
          }
          if (state.error != null && state.server == null) {
            return Center(child: Text(state.error!, style: const TextStyle(color: NwColors.crit)));
          }

          final server = state.server!;
          final status = server['status']?.toString() ?? 'pending';
          final metric = server['latestMetric'] as Map<String, dynamic>?;
          final spotsCpu = <FlSpot>[];
          final spotsRam = <FlSpot>[];
          final spotsDisk = <FlSpot>[];
          for (var i = 0; i < state.metrics.length; i++) {
            final m = state.metrics[i] as Map<String, dynamic>;
            spotsCpu.add(FlSpot(i.toDouble(), _n(m['cpuPercent'])));
            spotsRam.add(FlSpot(i.toDouble(), _n(m['ramPercent'])));
            spotsDisk.add(FlSpot(i.toDouble(), _n(m['diskPercent'])));
          }

          return RefreshIndicator(
            color: NwColors.accent,
            onRefresh: () => context.read<ServerDetailCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                LiveIndicator(updatedAt: state.updatedAt, refreshing: state.refreshing),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: NwColors.panel,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: NwColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              server['name']?.toString() ?? serverName,
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          StatusChip(status: status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${server['hostname']} · ${server['ipAddress']} · ${server['osType']}',
                        style: const TextStyle(color: NwColors.muted, fontSize: 13),
                      ),
                      if (metric != null) ...[
                        const SizedBox(height: 16),
                        MetricBar(label: 'CPU', value: _n(metric['cpuPercent']), color: NwColors.accent),
                        const SizedBox(height: 10),
                        MetricBar(label: 'RAM', value: _n(metric['ramPercent']), color: NwColors.warn),
                        const SizedBox(height: 10),
                        MetricBar(label: 'Disque', value: _n(metric['diskPercent']), color: NwColors.info),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Historiques (60 min)',
                  style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 260,
                  padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                  decoration: BoxDecoration(
                    color: NwColors.panel,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: NwColors.line),
                  ),
                  child: spotsCpu.isEmpty
                      ? const Center(
                          child: Text(
                            'Pas encore de données',
                            style: TextStyle(color: NwColors.muted),
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: 100,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (v) => FlLine(
                                color: Colors.white.withValues(alpha: 0.06),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: 25,
                                  getTitlesWidget: (v, _) => Text(
                                    '${v.toInt()}',
                                    style: const TextStyle(color: NwColors.muted, fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              _line(spotsCpu, NwColors.accent),
                              _line(spotsRam, NwColors.warn),
                              _line(spotsDisk, NwColors.info),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  children: const [
                    _Legend(color: NwColors.accent, label: 'CPU'),
                    _Legend(color: NwColors.warn, label: 'RAM'),
                    _Legend(color: NwColors.info, label: 'Disque'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.08)),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: NwColors.muted, fontSize: 12)),
      ],
    );
  }
}
