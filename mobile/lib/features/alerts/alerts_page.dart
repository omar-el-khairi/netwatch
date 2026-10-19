import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supervision_mobile/core/theme.dart';
import 'package:supervision_mobile/features/alerts/alerts_cubit.dart';
import 'package:supervision_mobile/widgets/nw_widgets.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  String _fmtDate(dynamic iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso.toString())?.toLocal();
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsCubit, AlertsState>(
      builder: (context, state) {
        if (state.loading && state.alerts.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: NwColors.accent));
        }

        final items = state.filtered;

        return RefreshIndicator(
          color: NwColors.accent,
          displacement: 48,
          onRefresh: () => context.read<AlertsCubit>().load(),
          child: ListView(
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
                  FilterChipButton(
                    label: 'Toutes',
                    selected: state.filter == AlertFilter.all,
                    onTap: () => context.read<AlertsCubit>().setFilter(AlertFilter.all),
                  ),
                  const SizedBox(width: 8),
                  FilterChipButton(
                    label: 'Ouvertes',
                    selected: state.filter == AlertFilter.open,
                    onTap: () => context.read<AlertsCubit>().setFilter(AlertFilter.open),
                  ),
                  const SizedBox(width: 8),
                  FilterChipButton(
                    label: 'Critiques',
                    selected: state.filter == AlertFilter.critical,
                    onTap: () => context.read<AlertsCubit>().setFilter(AlertFilter.critical),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: EmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'Aucune alerte',
                    subtitle: 'Tout est calme pour ce filtre.\nTirez pour actualiser.',
                  ),
                )
              else
                ...items.map((raw) {
                  final a = raw as Map<String, dynamic>;
                  final server = a['server'] as Map<String, dynamic>?;
                  final critical = a['severity'] == 'critical';
                  final color = critical ? NwColors.crit : NwColors.warn;
                  final ack = a['acknowledged'] == true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: NwColors.panel,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: color.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            critical ? Icons.error_rounded : Icons.warning_amber_rounded,
                            color: color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${a['type']} · ${server?['name'] ?? 'Serveur'}',
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                a['message']?.toString() ?? '',
                                style: const TextStyle(
                                  color: NwColors.muted,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _fmtDate(a['createdAt']),
                                style: GoogleFonts.ibmPlexMono(
                                  color: NwColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (ack)
                          const Icon(Icons.check_circle_rounded, color: NwColors.ok, size: 22)
                        else
                          IconButton(
                            tooltip: 'Acquitter',
                            onPressed: () => context
                                .read<AlertsCubit>()
                                .acknowledge(a['id'].toString()),
                            icon: const Icon(Icons.done_all_rounded, color: NwColors.accent),
                          ),
                      ],
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
