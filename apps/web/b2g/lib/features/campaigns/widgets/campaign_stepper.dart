import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';

/// A horizontal 5-step stepper with semaforo (traffic-light) coloring.
///
/// Steps: Plan -> Promo -> Inscripcion -> Cirugia -> Seguimiento
/// - Completed steps: green circle + checkmark
/// - Active step: blue circle + number
/// - Pending steps: gray circle + number
class CampaignStepper extends StatelessWidget {
  /// Index of the currently active step (0-4).
  final int activeStep;

  /// Number of completed steps. Steps < completedSteps show green.
  final int completedSteps;

  /// Whether to show step labels below the circles.
  final bool showLabels;

  /// Size of each circle node.
  final double nodeSize;

  /// Font size of step labels.
  final double labelFontSize;

  static const _stepLabels = [
    'Plan',
    'Promo',
    'Inscripcion',
    'Cirugia',
    'Seguimiento',
  ];

  const CampaignStepper({
    super.key,
    required this.activeStep,
    required this.completedSteps,
    this.showLabels = true,
    this.nodeSize = 26,
    this.labelFontSize = 9,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: showLabels ? 16 : 4),
          child: Row(
            children: [
              for (int i = 0; i < _stepLabels.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 3,
                      color: _lineColor(i),
                    ),
                  ),
                _buildNode(i),
              ],
            ],
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_stepLabels.length, (i) {
                return SizedBox(
                  width: 60,
                  child: Text(
                    _stepLabels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontWeight: i <= activeStep
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: _labelColor(i),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNode(int index) {
    final isCompleted = index < completedSteps;
    final isActive = index == activeStep;

    Color bgColor;
    if (isCompleted) {
      bgColor = AltruPetsTokens.success;
    } else if (isActive) {
      bgColor = AltruPetsTokens.info;
    } else {
      bgColor = AltruPetsTokens.surfaceBorder;
    }

    return Container(
      width: nodeSize,
      height: nodeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      alignment: Alignment.center,
      child: Text(
        isCompleted ? '\u2713' : '${index + 1}',
        style: TextStyle(
          fontSize: nodeSize * 0.42,
          fontWeight: FontWeight.w700,
          color: (isCompleted || isActive)
              ? Colors.white
              : AltruPetsTokens.textSecondary,
        ),
      ),
    );
  }

  Color _lineColor(int toIndex) {
    if (toIndex < completedSteps) return AltruPetsTokens.success;
    if (toIndex == activeStep) return AltruPetsTokens.info;
    return AltruPetsTokens.surfaceBorder;
  }

  Color _labelColor(int index) {
    if (index < completedSteps) return AltruPetsTokens.success;
    if (index == activeStep) return AltruPetsTokens.info;
    return AltruPetsTokens.textSecondary;
  }
}
