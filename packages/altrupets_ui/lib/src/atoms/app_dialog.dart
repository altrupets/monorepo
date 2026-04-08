import 'package:flutter/material.dart';
import '../theme/altrupets_tokens.dart';

/// A themed modal dialog matching the AltruPets dark design.
class AppDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final double maxWidth;

  const AppDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions,
    this.maxWidth = 520,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AltruPetsTokens.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AltruPetsTokens.radiusXl),
        side: const BorderSide(color: AltruPetsTokens.primary),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AltruPetsTokens.spacing20,
                vertical: AltruPetsTokens.spacing16,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AltruPetsTokens.surfaceBorder),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AltruPetsTokens.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AltruPetsTokens.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AltruPetsTokens.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AltruPetsTokens.spacing20),
                child: body,
              ),
            ),
            // Footer / Actions
            if (actions != null && actions!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AltruPetsTokens.spacing20,
                  vertical: AltruPetsTokens.spacing12,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AltruPetsTokens.surfaceBorder),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!
                      .map((a) => Padding(
                            padding: const EdgeInsets.only(
                                left: AltruPetsTokens.spacing8),
                            child: a,
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
