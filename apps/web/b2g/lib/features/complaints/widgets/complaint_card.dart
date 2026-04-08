import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';
import '../models/abuse_report_model.dart';

/// A card displaying a single abuse report in the complaints dashboard list.
class ComplaintCard extends StatelessWidget {
  final AbuseReportModel report;
  final VoidCallback? onClassify;
  final VoidCallback? onTap;

  const ComplaintCard({
    super.key,
    required this.report,
    this.onClassify,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          // Priority icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _priorityBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(_priorityEmoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title: abuse type summary + location
                Text(
                  '${report.abuseTypes.first.label} \u2014 ${report.shortLocation}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AltruPetsTokens.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                // Meta line
                Text(
                  _buildMetaLine(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AltruPetsTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          AppChip(
            label: report.statusLabel,
            backgroundColor: _statusBgColor,
            textColor: _statusTextColor,
          ),

          // Action button for FILED reports
          if (report.status == AbuseReportStatus.filed) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClassify,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: _statusBgColor,
                  border: Border.all(color: _statusTextColor),
                ),
                child: Text(
                  'Clasificar \u2192',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _statusTextColor,
                  ),
                ),
              ),
            ),
          ],

          // Assigned inspector for investigation reports
          if (report.status == AbuseReportStatus.underInvestigation &&
              report.assignedToName != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AltruPetsTokens.infoBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                report.assignedToName!,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AltruPetsTokens.info,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buildMetaLine() {
    final parts = <String>[];

    if (report.reporterInitials != null) {
      parts.add('Reportado por ${report.reporterInitials}');
    } else {
      parts.add('Reporte anonimo');
    }

    parts.add(report.timeAgo);

    if (report.hasGps) parts.add('GPS adjunto');
    if (report.evidenceCount > 0) {
      parts.add('${report.evidenceCount} foto${report.evidenceCount > 1 ? 's' : ''}');
    }

    return parts.join(' \u00B7 ');
  }

  String get _priorityEmoji {
    switch (report.priority) {
      case AbuseReportPriority.critical:
        return '\uD83D\uDEA8'; // rotating light
      case AbuseReportPriority.high:
        return '\u26A0\uFE0F'; // warning
      case AbuseReportPriority.medium:
        return '\u26A0\uFE0F'; // warning
      case AbuseReportPriority.low:
        return '\u2139\uFE0F'; // info
    }
  }

  Color get _priorityBgColor {
    switch (report.priority) {
      case AbuseReportPriority.critical:
        return AltruPetsTokens.errorBg;
      case AbuseReportPriority.high:
        return AltruPetsTokens.errorBg;
      case AbuseReportPriority.medium:
        return AltruPetsTokens.warningBg;
      case AbuseReportPriority.low:
        return AltruPetsTokens.infoBg;
    }
  }

  Color get _statusBgColor {
    switch (report.status) {
      case AbuseReportStatus.filed:
        return AltruPetsTokens.errorBg;
      case AbuseReportStatus.classified:
        return AltruPetsTokens.warningBg;
      case AbuseReportStatus.underInvestigation:
        return AltruPetsTokens.infoBg;
      case AbuseReportStatus.resolved:
        return AltruPetsTokens.successBg;
      case AbuseReportStatus.closed:
        return AltruPetsTokens.surfaceCard;
    }
  }

  Color get _statusTextColor {
    switch (report.status) {
      case AbuseReportStatus.filed:
        return AltruPetsTokens.error;
      case AbuseReportStatus.classified:
        return AltruPetsTokens.warning;
      case AbuseReportStatus.underInvestigation:
        return AltruPetsTokens.info;
      case AbuseReportStatus.resolved:
        return AltruPetsTokens.success;
      case AbuseReportStatus.closed:
        return AltruPetsTokens.textSecondary;
    }
  }
}
