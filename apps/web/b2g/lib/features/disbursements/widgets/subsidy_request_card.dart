import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';
import '../models/subsidy_request_model.dart';

/// A list item card for a subsidy request, matching the mockup design.
///
/// Shows: animal emoji + name + requester + diagnosis + vet + time + amount +
/// status badge + action button.
class SubsidyRequestCard extends StatelessWidget {
  final SubsidyRequestModel request;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  const SubsidyRequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: null,
      padding: const EdgeInsets.symmetric(
        horizontal: AltruPetsTokens.spacing12,
        vertical: AltruPetsTokens.spacing10,
      ),
      child: Row(
        children: [
          // Animal avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _avatarBgColor,
              borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
            ),
            alignment: Alignment.center,
            child: Text(
              request.animalEmoji,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: AltruPetsTokens.spacing10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${request.requesterName} \u2192 ${request.animalName} (${request.diagnosis})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AltruPetsTokens.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  '${request.vetClinicName} \u00B7 ${request.timeAgo} \u00B7 ${request.formattedAmount}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AltruPetsTokens.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AltruPetsTokens.spacing8),
          // Status badge
          AppChip(
            label: _badgeLabel,
            backgroundColor: _badgeBgColor,
            textColor: _badgeTextColor,
          ),
          const SizedBox(width: AltruPetsTokens.spacing8),
          // Action button
          _buildActionButton(),
          // View button (only for auto-eligible)
          if (request.urgency == RequestUrgency.autoEligible) ...[
            const SizedBox(width: AltruPetsTokens.spacing4),
            OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                side: const BorderSide(color: AltruPetsTokens.surfaceBorder),
                foregroundColor: AltruPetsTokens.textSecondary,
                textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Ver'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return OutlinedButton(
      onPressed: onAction,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        side: BorderSide(color: _actionColor),
        backgroundColor: _actionBgColor,
        foregroundColor: _actionColor,
        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(_actionLabel),
    );
  }

  // ─── Computed properties based on urgency ────

  Color get _avatarBgColor {
    switch (request.urgency) {
      case RequestUrgency.autoEligible:
        return AltruPetsTokens.successBg;
      case RequestUrgency.manualReview:
        return AltruPetsTokens.warningBg;
      case RequestUrgency.needsVerification:
        return AltruPetsTokens.errorBg;
    }
  }

  String get _badgeLabel {
    switch (request.urgency) {
      case RequestUrgency.autoEligible:
        return 'Aprobacion automatica disponible';
      case RequestUrgency.manualReview:
        return 'Requiere su revision';
      case RequestUrgency.needsVerification:
        return 'Necesita verificacion';
    }
  }

  Color get _badgeBgColor {
    switch (request.urgency) {
      case RequestUrgency.autoEligible:
        return AltruPetsTokens.successBg;
      case RequestUrgency.manualReview:
        return AltruPetsTokens.warningBg;
      case RequestUrgency.needsVerification:
        return AltruPetsTokens.errorBg;
    }
  }

  Color get _badgeTextColor {
    switch (request.urgency) {
      case RequestUrgency.autoEligible:
        return AltruPetsTokens.success;
      case RequestUrgency.manualReview:
        return AltruPetsTokens.warning;
      case RequestUrgency.needsVerification:
        return AltruPetsTokens.error;
    }
  }

  String get _actionLabel {
    switch (request.urgency) {
      case RequestUrgency.autoEligible:
        return 'Aprobar \u2713';
      case RequestUrgency.manualReview:
        return 'Revisar \u2192';
      case RequestUrgency.needsVerification:
        return 'Investigar \u26A0';
    }
  }

  Color get _actionColor {
    switch (request.urgency) {
      case RequestUrgency.autoEligible:
        return AltruPetsTokens.success;
      case RequestUrgency.manualReview:
        return AltruPetsTokens.warning;
      case RequestUrgency.needsVerification:
        return AltruPetsTokens.error;
    }
  }

  Color get _actionBgColor {
    switch (request.urgency) {
      case RequestUrgency.autoEligible:
        return AltruPetsTokens.successBg;
      case RequestUrgency.manualReview:
        return AltruPetsTokens.warningBg;
      case RequestUrgency.needsVerification:
        return AltruPetsTokens.errorBg;
    }
  }
}
