import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';
import '../theme/altrupets_b2g_theme.dart';

/// The B2G shell layout: Rail (56px) + Panel (210px) + Content.
class AppShell extends StatefulWidget {
  final Widget child;
  final int selectedNavIndex;
  final int selectedPanelIndex;
  final ValueChanged<int>? onNavChanged;
  final ValueChanged<int>? onPanelChanged;

  const AppShell({
    super.key,
    required this.child,
    this.selectedNavIndex = 0,
    this.selectedPanelIndex = 0,
    this.onNavChanged,
    this.onPanelChanged,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Rail
          _buildRail(),
          // Panel
          _buildPanel(),
          // Content
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildRail() {
    return Container(
      width: 56,
      color: B2GColors.railBg,
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Logo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AltruPetsTokens.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _railIcon(Icons.local_hospital, 0, badge: true),
          _railIcon(Icons.bar_chart, 1),
          _railIcon(Icons.handshake, 2),
          _railIcon(Icons.settings, 3),
          const Spacer(),
          // Avatar
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AltruPetsTokens.surfaceCard,
              border: Border.all(color: AltruPetsTokens.primary, width: 2),
            ),
            alignment: Alignment.center,
            child: const Text(
              'MA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AltruPetsTokens.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _railIcon(IconData icon, int index, {bool badge = false}) {
    final isActive = widget.selectedNavIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: InkWell(
        onTap: () => widget.onNavChanged?.call(index),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? AltruPetsTokens.surfaceCard
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: AltruPetsTokens.textPrimary),
              if (badge)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AltruPetsTokens.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return Container(
      width: 210,
      color: B2GColors.panelBg,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _panelHeader('Operaciones'),
          _panelItem('Campanas de Castracion', 0, count: 3),
          _panelItem('Desembolsos Veterinarios', 1, count: 7),
          _panelItem('Denuncias de Maltrato', 2, count: 2),
          _panelItem('Emergencias', 3, dimmed: true),
          _panelHeader('Reportes'),
          _panelItem('Dashboard General', 4),
          _panelItem('Informe SENASA', 5),
          _panelItem('Informe Concejo', 6),
          _panelHeader('Comunidad'),
          _panelItem('Rescatistas', 7),
          _panelItem('Veterinarias', 8),
          _panelHeader('Configuracion'),
          _panelItem('Reglas de Aprobacion', 9),
          _panelItem('Horario y Guardia', 10),
        ],
      ),
    );
  }

  Widget _panelHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 8,
          color: AltruPetsTokens.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _panelItem(String label, int index, {int? count, bool dimmed = false}) {
    final isActive = widget.selectedPanelIndex == index;
    return InkWell(
      onTap: () => widget.onPanelChanged?.call(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AltruPetsTokens.surfaceCard : Colors.transparent,
          border: isActive
              ? const Border(
                  left: BorderSide(color: AltruPetsTokens.primary, width: 2),
                )
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: dimmed
                      ? AltruPetsTokens.textSecondary
                      : isActive
                          ? Colors.white
                          : AltruPetsTokens.textPrimary,
                ),
              ),
            ),
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? AltruPetsTokens.primary
                      : AltruPetsTokens.surfaceCard,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 9,
                    color: isActive
                        ? Colors.white
                        : AltruPetsTokens.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
