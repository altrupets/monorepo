import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';

/// Approval rules management page with 5 rule cards + toggles.
///
/// Uses MOCK DATA — GraphQL wiring is a separate follow-up ticket (Phase 6).
class ApprovalRulesPage extends StatefulWidget {
  const ApprovalRulesPage({super.key});

  @override
  State<ApprovalRulesPage> createState() => _ApprovalRulesPageState();
}

class _ApprovalRulesPageState extends State<ApprovalRulesPage> {
  final List<_RuleConfig> _rules = [
    _RuleConfig(
      type: 'VERIFIED_RESCUER',
      title: 'Rescatista verificada',
      description:
          'Requiere que el solicitante tenga su perfil verificado en la plataforma.',
      icon: Icons.verified_user,
      isEnabled: true,
    ),
    _RuleConfig(
      type: 'REGISTERED_ANIMAL',
      title: 'Animal registrado',
      description:
          'El animal debe tener microchip o estar inscrito en una casa cuna.',
      icon: Icons.pets,
      isEnabled: true,
    ),
    _RuleConfig(
      type: 'WITHIN_BUDGET',
      title: 'Dentro de presupuesto',
      description:
          'La solicitud no puede exceder el presupuesto mensual disponible.',
      icon: Icons.account_balance_wallet,
      isEnabled: true,
      parameterLabel: 'Presupuesto mensual (\u20A1)',
      parameterValue: '500000',
    ),
    _RuleConfig(
      type: 'AUTHORIZED_VET',
      title: 'Veterinaria autorizada',
      description:
          'La veterinaria asignada debe estar verificada por SENASA.',
      icon: Icons.local_hospital,
      isEnabled: true,
    ),
    _RuleConfig(
      type: 'NO_DUPLICATE',
      title: 'Sin solicitudes duplicadas',
      description:
          'No permite solicitudes repetidas para el mismo animal en una ventana de tiempo.',
      icon: Icons.content_copy,
      isEnabled: true,
      parameterLabel: 'Ventana (dias)',
      parameterValue: '30',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AltruPetsTokens.surfaceContent,
      padding: const EdgeInsets.all(AltruPetsTokens.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSummaryBanner(),
          const SizedBox(height: 16),
          Expanded(child: _buildRuleList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reglas de Aprobacion Automatica',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AltruPetsTokens.textPrimary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Configure las reglas que determinan si una solicitud de desembolso puede aprobarse automaticamente.',
          style: TextStyle(
            fontSize: 11,
            color: AltruPetsTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBanner() {
    final enabledCount = _rules.where((r) => r.isEnabled).length;
    final allEnabled = enabledCount == _rules.length;

    return AppCard(
      borderColor: allEnabled
          ? AltruPetsTokens.success
          : AltruPetsTokens.warning,
      child: Row(
        children: [
          Icon(
            allEnabled ? Icons.check_circle : Icons.info_outline,
            color: allEnabled
                ? AltruPetsTokens.success
                : AltruPetsTokens.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              allEnabled
                  ? 'Todas las reglas estan activas. Las solicitudes que cumplan las 5 reglas se aprueban automaticamente.'
                  : '$enabledCount de ${_rules.length} reglas activas. Las solicitudes que fallen alguna regla desactivada iran a revision manual.',
              style: const TextStyle(
                fontSize: 11,
                color: AltruPetsTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleList() {
    return ListView.separated(
      itemCount: _rules.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildRuleCard(_rules[index], index),
    );
  }

  Widget _buildRuleCard(_RuleConfig rule, int index) {
    return AppCard(
      borderColor: rule.isEnabled
          ? AltruPetsTokens.surfaceBorder
          : AltruPetsTokens.surfaceBorder.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: rule.isEnabled
                      ? AltruPetsTokens.successBg
                      : AltruPetsTokens.surfaceBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  rule.icon,
                  size: 18,
                  color: rule.isEnabled
                      ? AltruPetsTokens.success
                      : AltruPetsTokens.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: rule.isEnabled
                            ? AltruPetsTokens.textPrimary
                            : AltruPetsTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rule.description,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AltruPetsTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: rule.isEnabled,
                onChanged: (val) {
                  setState(() {
                    _rules[index] = rule.copyWith(isEnabled: val);
                  });
                },
                activeThumbColor: AltruPetsTokens.success,
              ),
            ],
          ),
          if (rule.parameterLabel != null && rule.isEnabled) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AltruPetsTokens.surfaceContent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AltruPetsTokens.surfaceBorder),
              ),
              child: Row(
                children: [
                  Text(
                    rule.parameterLabel!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AltruPetsTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller:
                          TextEditingController(text: rule.parameterValue),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AltruPetsTokens.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: AltruPetsTokens.surfaceBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: AltruPetsTokens.surfaceBorder,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
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

/// Internal model for rule configuration state.
class _RuleConfig {
  final String type;
  final String title;
  final String description;
  final IconData icon;
  final bool isEnabled;
  final String? parameterLabel;
  final String? parameterValue;

  const _RuleConfig({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.isEnabled,
    this.parameterLabel,
    this.parameterValue,
  });

  _RuleConfig copyWith({bool? isEnabled}) {
    return _RuleConfig(
      type: type,
      title: title,
      description: description,
      icon: icon,
      isEnabled: isEnabled ?? this.isEnabled,
      parameterLabel: parameterLabel,
      parameterValue: parameterValue,
    );
  }
}
