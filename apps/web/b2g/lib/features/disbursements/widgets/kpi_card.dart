import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';

/// A single KPI card matching the dashboard mockup.
///
/// Supports optional progress bar and breakdown row.
class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final String? detail;
  final Color? detailColor;
  final String icon;
  final Color iconBgColor;

  /// If non-null, shows a progress bar.
  final double? progressPercent;
  final Color? progressColor;

  /// If non-null, shows a breakdown row below.
  final List<KpiBreakdownItem>? breakdown;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = AltruPetsTokens.textPrimary,
    this.detail,
    this.detailColor,
    required this.icon,
    required this.iconBgColor,
    this.progressPercent,
    this.progressColor,
    this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: valueColor,
                      ),
                    ),
                    if (detail != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          detail!,
                          style: TextStyle(
                            fontSize: 10,
                            color: detailColor ?? AltruPetsTokens.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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
          if (progressPercent != null) ...[
            const SizedBox(height: 8),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: AltruPetsTokens.surfaceBorder,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (progressPercent! / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: progressColor ?? AltruPetsTokens.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
          if (breakdown != null && breakdown!.isNotEmpty) ...[
            const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                children: [
                  for (int i = 0; i < breakdown!.length; i++) ...[
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
                            '${breakdown![i].count}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: breakdown![i].color,
                            ),
                          ),
                          Text(
                            breakdown![i].label,
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
            ),
          ],
        ],
      ),
    );
  }
}

/// A single item in the KPI breakdown row.
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
