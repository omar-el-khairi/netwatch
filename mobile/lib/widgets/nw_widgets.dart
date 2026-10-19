import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supervision_mobile/core/theme.dart';

class NwBrandMark extends StatelessWidget {
  const NwBrandMark({super.key, this.height = 44, this.width = 14});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [NwColors.accent, NwColors.info],
        ),
        boxShadow: [
          BoxShadow(
            color: NwColors.accent.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.compact = false});

  final String status;
  final bool compact;

  IconData get _icon {
    switch (status) {
      case 'online':
        return Icons.check_circle_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'critical':
        return Icons.error_rounded;
      case 'down':
        return Icons.cloud_off_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: compact ? 12 : 14, color: color),
          const SizedBox(width: 5),
          Text(
            statusLabel(status),
            style: GoogleFonts.dmSans(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

class LiveIndicator extends StatelessWidget {
  const LiveIndicator({
    super.key,
    this.updatedAt,
    this.refreshing = false,
    this.live = true,
  });

  final DateTime? updatedAt;
  final bool refreshing;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final time = updatedAt == null
        ? '—'
        : TimeOfDay.fromDateTime(updatedAt!).format(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: NwColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: NwColors.accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (refreshing)
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: NwColors.accent,
                  ),
                )
              else
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: NwColors.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: NwColors.accent.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 6),
              Text(
                refreshing
                    ? 'Actualisation…'
                    : (live ? 'Temps réel' : 'Polling'),
                style: GoogleFonts.dmSans(
                  color: NwColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'MAJ $time',
          style: GoogleFonts.ibmPlexMono(color: NwColors.muted, fontSize: 11),
        ),
      ],
    );
  }
}

class MetricBar extends StatelessWidget {
  const MetricBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0, 100) / 100).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: NwColors.muted, fontSize: 12)),
            Text(
              '${value.toStringAsFixed(0)}%',
              style: GoogleFonts.ibmPlexMono(
                color: NwColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 7,
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            color: color,
          ),
        ),
      ],
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.color = NwColors.text,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: NwColors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NwColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: NwColors.muted, fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.ibmPlexMono(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: NwColors.panel,
                shape: BoxShape.circle,
                border: Border.all(color: NwColors.line),
              ),
              child: Icon(icon, size: 34, color: NwColors.muted),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: NwColors.muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? NwColors.accent.withValues(alpha: 0.16) : NwColors.panel,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? NwColors.accent.withValues(alpha: 0.5) : NwColors.line,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: selected ? NwColors.accent : NwColors.muted,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
