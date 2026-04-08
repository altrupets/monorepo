import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';
import '../models/campaign_model.dart';
import 'campaign_stepper.dart';

/// A campaign list card showing status badge, title, stepper, and capacity.
class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback? onTap;

  const CampaignCard({
    super.key,
    required this.campaign,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: null,
      padding: const EdgeInsets.all(AltruPetsTokens.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: status badge + code
          Row(
            children: [
              AppChip(
                label: campaign.statusLabel,
                backgroundColor: _badgeBgColor,
                textColor: _badgeTextColor,
              ),
              const SizedBox(width: AltruPetsTokens.spacing8),
              Text(
                campaign.code,
                style: const TextStyle(
                  fontSize: 10,
                  color: AltruPetsTokens.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Capacity indicator
              _buildCapacityBadge(),
            ],
          ),
          const SizedBox(height: AltruPetsTokens.spacing8),
          // Title
          Text(
            campaign.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AltruPetsTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          // Location + date + budget
          Text(
            '${campaign.location} \u00B7 ${campaign.surgeryDate} \u00B7 ${campaign.formattedBudget}',
            style: const TextStyle(
              fontSize: 10,
              color: AltruPetsTokens.textSecondary,
            ),
          ),
          const SizedBox(height: AltruPetsTokens.spacing10),
          // Stepper
          CampaignStepper(
            activeStep: campaign.activeStepIndex,
            completedSteps: campaign.completedSteps,
            showLabels: true,
            nodeSize: 22,
            labelFontSize: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityBadge() {
    final isCompleted = campaign.status == CampaignStatus.completed ||
        campaign.status == CampaignStatus.archived;
    final count = isCompleted ? campaign.operatedCount : campaign.registrationCount;
    final label = isCompleted ? 'operados' : 'inscritos';
    final fillPercent = campaign.maxCapacity > 0
        ? (count / campaign.maxCapacity * 100).clamp(0.0, 100.0)
        : 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count/${campaign.maxCapacity}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: fillPercent >= 90
                ? AltruPetsTokens.warning
                : AltruPetsTokens.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: AltruPetsTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Color get _badgeBgColor {
    switch (campaign.status) {
      case CampaignStatus.registrationOpen:
        return AltruPetsTokens.successBg;
      case CampaignStatus.draft:
      case CampaignStatus.published:
        return AltruPetsTokens.warningBg;
      case CampaignStatus.registrationClosed:
      case CampaignStatus.inProgress:
        return AltruPetsTokens.infoBg;
      case CampaignStatus.completed:
      case CampaignStatus.archived:
        return AltruPetsTokens.surfaceCard;
    }
  }

  Color get _badgeTextColor {
    switch (campaign.status) {
      case CampaignStatus.registrationOpen:
        return AltruPetsTokens.success;
      case CampaignStatus.draft:
      case CampaignStatus.published:
        return AltruPetsTokens.warning;
      case CampaignStatus.registrationClosed:
      case CampaignStatus.inProgress:
        return AltruPetsTokens.info;
      case CampaignStatus.completed:
      case CampaignStatus.archived:
        return AltruPetsTokens.textSecondary;
    }
  }
}
