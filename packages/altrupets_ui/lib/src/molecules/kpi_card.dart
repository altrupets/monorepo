import 'package:flutter/material.dart';
import '../atoms/app_card.dart';
import '../theme/altrupets_tokens.dart';

/// Performance status used for automatic semaforo color-coding.
enum KpiStatus {
  /// Cumple o supera la meta (green).
  onTarget,

  /// 80-100% de la meta (yellow/warning).
  warning,

  /// < 80% de la meta (red/critical).
  critical,
}

/// A single KPI card with target/goal, trend, progress bar, and
/// semaforo color-coding.
///
/// Designed for the B2G dashboard KPI bars across all operation panels.
class KpiCard extends StatelessWidget {
  /// Short uppercase label, e.g. "Tiempo promedio respuesta".
  final String label;

  /// Primary value displayed large, e.g. "4.2h" or "127".
  final String value;

  /// Color for the main value text.  When [status] is set this is
  /// auto-computed; an explicit value overrides the status color.
  final Color? valueColor;

  /// Target line, e.g. "Meta: <2h". Null hides the line.
  final String? target;

  /// Trend line, e.g. "^$\downarrow$ 2h vs mes anterior". Null hides it.
  final String? trend;

  /// Color for the trend text (green = improvement, red = regression).
  final Color? trendColor;

  /// 0.0-1.0 progress towards target. Null hides the bar.
  final double? progress;

  /// Fill color for the progress bar.
  final Color? progressColor;

  /// Emoji or icon string shown in a colored circle.
  final String icon;

  /// Background color for the icon circle.
  final Color iconBgColor;

  /// Extra context line below value (shown when no target/trend set).
  final String? subtitle;

  /// Custom widget for breakdown rows (e.g. auto/manual/rechazado).
  final Widget? breakdown;

  /// Semaforo status — auto-colors [value] and progress bar when set.
  final KpiStatus? status;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.target,
    this.trend,
    this.trendColor,
    this.progress,
    this.progressColor,
    required this.icon,
    required this.iconBgColor,
    this.subtitle,
    this.breakdown,
    this.status,
  });

  /// Resolves the display color for the main value based on [status].
  Color get _resolvedValueColor {
    if (valueColor != null) return valueColor!;
    return _statusColor ?? AltruPetsTokens.textPrimary;
  }

  /// Resolves the display color for the progress bar based on [status].
  Color get _resolvedProgressColor {
    if (progressColor != null) return progressColor!;
    return _statusColor ?? AltruPetsTokens.primary;
  }

  Color? get _statusColor {
    switch (status) {
      case KpiStatus.onTarget:
        return AltruPetsTokens.success;
      case KpiStatus.warning:
        return AltruPetsTokens.warning;
      case KpiStatus.critical:
        return AltruPetsTokens.error;
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top row: label + icon ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        color: AltruPetsTokens.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // ── Main value ──
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _resolvedValueColor,
                      ),
                    ),

                    // ── Target line ──
                    if (target != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          target!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AltruPetsTokens.textSecondary,
                          ),
                        ),
                      ),

                    // ── Trend line ──
                    if (trend != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          trend!,
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                trendColor ?? AltruPetsTokens.textSecondary,
                          ),
                        ),
                      ),

                    // ── Subtitle (legacy detail) ──
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AltruPetsTokens.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Icon badge ──
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 15)),
              ),
            ],
          ),

          // ── Progress bar ──
          if (progress != null) ...[
            const SizedBox(height: 8),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: AltruPetsTokens.surfaceBorder,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress!.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _resolvedProgressColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],

          // ── Breakdown ──
          if (breakdown != null) ...[
            const SizedBox(height: 8),
            breakdown!,
          ],
        ],
      ),
    );
  }
}

/// A single item in a KPI breakdown row.
class KpiBreakdownItem {
  final int count;
  final String label;
  final Color color;

  const KpiBreakdownItem({
    required this.count,
    required this.label,
    required this.color,
  });
}

/// A ready-made breakdown row widget built from [KpiBreakdownItem]s.
///
/// Use this as the [KpiCard.breakdown] parameter for the standard
/// count-based breakdown layout matching the mockup.
class KpiBreakdownRow extends StatelessWidget {
  final List<KpiBreakdownItem> items;

  const KpiBreakdownRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                color: AltruPetsTokens.surfaceBorder,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${items[i].count}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: items[i].color,
                    ),
                  ),
                  Text(
                    items[i].label,
                    style: const TextStyle(
                      fontSize: 8,
                      color: AltruPetsTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
