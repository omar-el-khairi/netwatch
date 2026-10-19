import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supervision_mobile/core/theme.dart';
import 'package:supervision_mobile/features/servers/server_detail_page.dart';
import 'package:supervision_mobile/features/servers/servers_cubit.dart';
import 'package:supervision_mobile/widgets/nw_widgets.dart';

class ServersPage extends StatelessWidget {
  const ServersPage({super.key});

  double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServersCubit, ServersState>(
      builder: (context, state) {
        if (state.loading && state.servers.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: NwColors.accent));
        }
        if (state.error != null && state.servers.isEmpty) {
          return EmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'Connexion impossible',
            subtitle: state.error!,
          );
        }

        final servers = state.servers;
        final online = servers.where((s) => (s as Map)['status'] == 'online').length;
        final warn = servers.where((s) => (s as Map)['status'] == 'warning').length;
        final bad = servers.where((s) {
          final st = (s as Map)['status'];
          return st == 'critical' || st == 'down';
        }).length;

        return RefreshIndicator(
          color: NwColors.accent,
          displacement: 48,
          onRefresh: () => context.read<ServersCubit>().load(),
          child: servers.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 80),
                    EmptyState(
                      icon: Icons.dns_outlined,
                      title: 'Aucun serveur',
                      subtitle: 'Ajoutez un serveur depuis le dashboard web,\npuis lancez l’agent.',
                    ),
                  ],
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    LiveIndicator(
                      updatedAt: state.updatedAt,
                      refreshing: state.refreshing,
                      live: state.live,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        StatTile(label: 'Total', value: '${servers.length}'),
                        const SizedBox(width: 8),
                        StatTile(label: 'OK', value: '$online', color: NwColors.ok),
                        const SizedBox(width: 8),
                        StatTile(label: 'Warn', value: '$warn', color: NwColors.warn),
                        const SizedBox(width: 8),
                        StatTile(label: 'Crit.', value: '$bad', color: NwColors.crit),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...servers.map((raw) {
                      final s = raw as Map<String, dynamic>;
                      final metric = s['latestMetric'] as Map<String, dynamic>?;
                      final status = s['status']?.toString() ?? 'pending';
                      final color = statusColor(status);
                      final id = s['id']?.toString() ?? '';
                      final name = s['name']?.toString() ?? 'Serveur';

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ServerDetailPage(
                                  serverId: id,
                                  serverName: name,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: NwColors.panel,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: NwColors.line),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    width: 5,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: const BorderRadius.horizontal(
                                        left: Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  name,
                                                  style: GoogleFonts.dmSans(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              StatusChip(status: status),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.chevron_right_rounded,
                                                color: NwColors.muted,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${s['hostname']} · ${s['ipAddress']} · ${s['osType']}',
                                            style: const TextStyle(
                                              color: NwColors.muted,
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (metric != null) ...[
                                            const SizedBox(height: 14),
                                            MetricBar(
                                              label: 'CPU',
                                              value: _num(metric['cpuPercent']),
                                              color: NwColors.accent,
                                            ),
                                            const SizedBox(height: 10),
                                            MetricBar(
                                              label: 'RAM',
                                              value: _num(metric['ramPercent']),
                                              color: NwColors.warn,
                                            ),
                                            const SizedBox(height: 10),
                                            MetricBar(
                                              label: 'Disque',
                                              value: _num(metric['diskPercent']),
                                              color: NwColors.info,
                                            ),
                                          ] else ...[
                                            const SizedBox(height: 12),
                                            Text(
                                              'En attente de la première métrique…',
                                              style: GoogleFonts.dmSans(
                                                color: NwColors.muted,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }
}
