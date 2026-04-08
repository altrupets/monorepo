import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';

/// Approval rules management page with master toggle + 5 rule cards.
///
/// Uses MOCK DATA — GraphQL wiring is a separate follow-up ticket (Phase 6).
class ApprovalRulesPage extends StatefulWidget {
  const ApprovalRulesPage({super.key});

  @override
  State<ApprovalRulesPage> createState() => _ApprovalRulesPageState();
}

class _ApprovalRulesPageState extends State<ApprovalRulesPage> {
  bool _masterEnabled = true;

  final List<_RuleConfig> _rules = [
    _RuleConfig(
      type: 'VERIFIED_RESCUER',
      title: 'Rescatista Verificada',
      description:
          'Solo aprueba si la rescatista tiene cuenta verificada.',
      icon: Icons.verified_user,
      isEnabled: true,
    ),
    _RuleConfig(
      type: 'REGISTERED_ANIMAL',
      title: 'Animal Registrado',
      description:
          'Solo aprueba si el animal está registrado en la plataforma.',
      icon: Icons.pets,
      isEnabled: true,
    ),
    _RuleConfig(
      type: 'WITHIN_BUDGET',
      title: 'Dentro de Presupuesto',
      description:
          'Solo aprueba si el monto está dentro del presupuesto configurado.',
      icon: Icons.account_balance_wallet,
      isEnabled: true,
      parameters: [
        _RuleParameter(
          key: 'maxAmountPerRequest',
          label: 'Monto máximo por solicitud (₡)',
          value: '500000',
        ),
        _RuleParameter(
          key: 'evaluationPeriodDays',
          label: 'Período de evaluación (días)',
          value: '30',
        ),
      ],
    ),
    _RuleConfig(
      type: 'AUTHORIZED_VET',
      title: 'Veterinaria Autorizada',
      description:
          'Solo aprueba si la veterinaria está en la lista autorizada.',
      icon: Icons.local_hospital,
      isEnabled: true,
    ),
    _RuleConfig(
      type: 'NO_DUPLICATE',
      title: 'Sin Duplicados',
      description:
          'No permite solicitudes repetidas para el mismo animal en una ventana de tiempo.',
      icon: Icons.content_copy,
      isEnabled: true,
      parameters: [
        _RuleParameter(
          key: 'detectionWindowDays',
          label: 'Ventana de detección (días)',
          value: '30',
        ),
      ],
    ),
  ];

  /// Persistent controllers keyed by "ruleType.paramKey".
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    for (final rule in _rules) {
      for (final param in rule.parameters) {
        final key = '${rule.type}.${param.key}';
        _controllers[key] = TextEditingController(text: param.value);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AltruPetsTokens.surfaceContent,
      padding: const EdgeInsets.all(AltruPetsTokens.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AltruPetsTokens.spacing16),
          _buildMasterToggle(),
          const SizedBox(height: AltruPetsTokens.spacing8),
          if (!_masterEnabled) ...[
            _buildWarningBanner(),
            const SizedBox(height: AltruPetsTokens.spacing8),
          ],
          _buildSummaryBanner(),
          const SizedBox(height: AltruPetsTokens.spacing16),
          Expanded(child: _buildRuleList()),
          const SizedBox(height: AltruPetsTokens.spacing16),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reglas de Aprobación Automática',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AltruPetsTokens.textPrimary,
          ),
        ),
        SizedBox(height: AltruPetsTokens.spacing2),
        Text(
          'Configure las reglas que determinan si una solicitud de desembolso puede aprobarse automáticamente.',
          style: TextStyle(
            fontSize: 11,
            color: AltruPetsTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMasterToggle() {
    return AppCard(
      borderColor: _masterEnabled
          ? AltruPetsTokens.success
          : AltruPetsTokens.surfaceBorder,
      child: Row(
        children: [
          Icon(
            _masterEnabled ? Icons.flash_on : Icons.flash_off,
            color: _masterEnabled
                ? AltruPetsTokens.success
                : AltruPetsTokens.textSecondary,
            size: 20,
          ),
          const SizedBox(width: AltruPetsTokens.spacing10),
          const Expanded(
            child: Text(
              'Auto-aprobación habilitada',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AltruPetsTokens.textPrimary,
              ),
            ),
          ),
          Switch(
            value: _masterEnabled,
            onChanged: (val) {
              setState(() {
                _masterEnabled = val;
              });
            },
            activeTrackColor: AltruPetsTokens.success,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return AppCard(
      borderColor: AltruPetsTokens.warning,
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AltruPetsTokens.warning,
            size: 20,
          ),
          const SizedBox(width: AltruPetsTokens.spacing10),
          Expanded(
            child: Text(
              'Auto-aprobación desactivada. Todas las solicitudes irán a revisión manual.',
              style: TextStyle(
                fontSize: 11,
                color: AltruPetsTokens.warning.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
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
          const SizedBox(width: AltruPetsTokens.spacing10),
          Expanded(
            child: Text(
              allEnabled
                  ? 'Todas las reglas están activas. Las solicitudes que cumplan las 5 reglas se aprueban automáticamente.'
                  : '$enabledCount de ${_rules.length} reglas activas. Las solicitudes que fallen alguna regla desactivada irán a revisión manual.',
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
      separatorBuilder: (_, _) => const SizedBox(height: AltruPetsTokens.spacing8),
      itemBuilder: (context, index) => _buildRuleCard(_rules[index], index),
    );
  }

  Widget _buildRuleCard(_RuleConfig rule, int index) {
    final effectiveEnabled = _masterEnabled && rule.isEnabled;

    return AppCard(
      borderColor: effectiveEnabled
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
                  color: effectiveEnabled
                      ? AltruPetsTokens.successBg
                      : AltruPetsTokens.surfaceBorder,
                  borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
                ),
                alignment: Alignment.center,
                child: Icon(
                  rule.icon,
                  size: 18,
                  color: effectiveEnabled
                      ? AltruPetsTokens.success
                      : AltruPetsTokens.textSecondary,
                ),
              ),
              const SizedBox(width: AltruPetsTokens.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: effectiveEnabled
                            ? AltruPetsTokens.textPrimary
                            : AltruPetsTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AltruPetsTokens.spacing2),
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
                onChanged: _masterEnabled
                    ? (val) {
                        setState(() {
                          _rules[index] = rule.copyWith(isEnabled: val);
                        });
                      }
                    : null,
                activeTrackColor: AltruPetsTokens.success,
              ),
            ],
          ),
          if (rule.parameters.isNotEmpty && effectiveEnabled) ...[
            const SizedBox(height: AltruPetsTokens.spacing10),
            Container(
              padding: const EdgeInsets.all(AltruPetsTokens.spacing10),
              decoration: BoxDecoration(
                color: AltruPetsTokens.surfaceContent,
                borderRadius: BorderRadius.circular(AltruPetsTokens.radiusSm),
                border: Border.all(color: AltruPetsTokens.surfaceBorder),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < rule.parameters.length; i++) ...[
                    if (i > 0)
                      const SizedBox(height: AltruPetsTokens.spacing8),
                    _buildParameterRow(rule, rule.parameters[i]),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParameterRow(_RuleConfig rule, _RuleParameter param) {
    final controllerKey = '${rule.type}.${param.key}';
    final controller = _controllers[controllerKey]!;

    return Row(
      children: [
        Expanded(
          child: Text(
            param.label,
            style: const TextStyle(
              fontSize: 11,
              color: AltruPetsTokens.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AltruPetsTokens.spacing10),
        SizedBox(
          width: 120,
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontSize: 12,
              color: AltruPetsTokens.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AltruPetsTokens.spacing8,
                vertical: AltruPetsTokens.spacing6,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AltruPetsTokens.spacing4),
                borderSide: const BorderSide(
                  color: AltruPetsTokens.surfaceBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AltruPetsTokens.spacing4),
                borderSide: const BorderSide(
                  color: AltruPetsTokens.surfaceBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AltruPetsTokens.spacing4),
                borderSide: const BorderSide(
                  color: AltruPetsTokens.primary,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _onSave,
        icon: const Icon(Icons.save, size: 18),
        label: const Text('Guardar configuración'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AltruPetsTokens.primary,
          foregroundColor: AltruPetsTokens.textOnPrimary,
          padding: const EdgeInsets.symmetric(
            vertical: AltruPetsTokens.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AltruPetsTokens.radiusMd),
          ),
        ),
      ),
    );
  }

  void _onSave() {
    // TODO(ALT-70): Wire to GraphQL mutation in Phase 6.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Configuración guardada (mock)'),
        backgroundColor: AltruPetsTokens.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AltruPetsTokens.radiusMd),
        ),
      ),
    );
  }
}

/// A single parameter within a rule.
class _RuleParameter {
  final String key;
  final String label;
  final String value;

  const _RuleParameter({
    required this.key,
    required this.label,
    required this.value,
  });
}

/// Internal model for rule configuration state.
class _RuleConfig {
  final String type;
  final String title;
  final String description;
  final IconData icon;
  final bool isEnabled;
  final List<_RuleParameter> parameters;

  const _RuleConfig({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.isEnabled,
    this.parameters = const [],
  });

  _RuleConfig copyWith({bool? isEnabled}) {
    return _RuleConfig(
      type: type,
      title: title,
      description: description,
      icon: icon,
      isEnabled: isEnabled ?? this.isEnabled,
      parameters: parameters,
    );
  }
}
