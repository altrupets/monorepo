import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:material_color_utilities/scheme/scheme_tonal_spot.dart';
import 'package:material_color_utilities/hct/hct.dart';
import 'design_system_state.dart';

class TonalPaletteGenerator extends StatelessWidget {
  final DesignSystemManager manager;
  const TonalPaletteGenerator({super.key, required this.manager});

  SchemeTonalSpot _getScheme(Color color) {
    return SchemeTonalSpot(
      sourceColorHct: Hct.fromInt(color.toARGB32()),
      isDark: false,
      contrastLevel: 0.0,
    );
  }

  void _onBrandColorChanged(String key, Color color) {
    manager.updateColor(key, color);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          _buildActionButtons(context),
          const SizedBox(height: 48),
          _buildBrandColorsSection(context),
          const SizedBox(height: 48),
          _buildPaletteSection(
            context,
            'Primary Palette',
            _getScheme(manager.primaryColor).primaryPalette,
          ),
          _buildPaletteSection(
            context,
            'Secondary Palette',
            _getScheme(manager.secondaryColor).primaryPalette,
          ),
          _buildPaletteSection(
            context,
            'Accent Palette',
            _getScheme(manager.accentColor).primaryPalette,
          ),
          _buildPaletteSection(
            context,
            'Success Palette',
            _getScheme(manager.successColor).primaryPalette,
          ),

          const SizedBox(height: 48),
          const Divider(),
          const SizedBox(height: 24),
          Text(
            'System Palettes (Derived from Primary)',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildPaletteSection(
            context,
            'Neutral Palette',
            _getScheme(manager.primaryColor).neutralPalette,
          ),
          _buildPaletteSection(
            context,
            'Neutral Variant Palette',
            _getScheme(manager.primaryColor).neutralVariantPalette,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'M3 Design System Sync',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your brand tokens and sync them with the mobile application.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: manager.loadTokens,
          icon: const Icon(Icons.file_open_rounded),
          label: const Text('Load Tokens'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: manager.isLoading ? null : () => manager.syncAll(),
          icon: manager.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.sync_rounded),
          label: const Text('SYNC CHANGES'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandColorsSection(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined),
                const SizedBox(width: 12),
                Text(
                  'Brand Colors',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: manager.loadTokens,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Define your 5 primary brand colors. Each color will generate a complete scale from 100-900.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                final double itemWidth = (constraints.maxWidth - 32) / 3;
                return Wrap(
                  spacing: 16,
                  runSpacing: 24,
                  children: [
                    _buildColorPickerItem(
                      context,
                      'Brand Primary',
                      'primary',
                      manager.primaryColor,
                      itemWidth,
                    ),
                    _buildColorPickerItem(
                      context,
                      'Brand Secondary',
                      'secondary',
                      manager.secondaryColor,
                      itemWidth,
                    ),
                    _buildColorPickerItem(
                      context,
                      'Brand Accent',
                      'accent',
                      manager.accentColor,
                      itemWidth,
                    ),
                    _buildColorPickerItem(
                      context,
                      'Brand Warning',
                      'warning',
                      manager.warningColor,
                      itemWidth,
                    ),
                    _buildColorPickerItem(
                      context,
                      'Brand Error',
                      'error',
                      manager.errorColor,
                      itemWidth,
                    ),
                    _buildColorPickerItem(
                      context,
                      'Brand Success',
                      'success',
                      manager.successColor,
                      itemWidth,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPickerItem(
    BuildContext context,
    String label,
    String key,
    Color color,
    double width,
  ) {
    final String hex =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final newColor = await _showColorPickerDialog(
                context,
                label,
                color,
              );
              if (newColor != null) {
                _onBrandColorChanged(key, newColor);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    hex,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Color?> _showColorPickerDialog(
    BuildContext context,
    String label,
    Color currentColor,
  ) async {
    Color selected = currentColor;
    final TextEditingController controller = TextEditingController(
      text:
          '#${currentColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
    );

    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick $label'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Hex Color',
                hintText: '#RRGGBB',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
              onChanged: (value) {
                final hex = value.replaceAll('#', '');
                if (hex.length == 6) {
                  final intColor = int.tryParse('FF$hex', radix: 16);
                  if (intColor != null) {
                    selected = Color(intColor);
                  }
                }
              },
            ),
            const SizedBox(height: 24),
            // Quick presets
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                        const Color(0xFF094F72),
                        const Color(0xFFEA840B),
                        const Color(0xFF1370A6),
                        const Color(0xFFF4AE22),
                        const Color(0xFFE54C12),
                        const Color(0xFF2E7D32),
                        const Color(0xFF6750A4),
                      ]
                      .map(
                        (c) => GestureDetector(
                          onTap: () => Navigator.pop(context, c),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, selected),
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaletteSection(
    BuildContext context,
    String name,
    TonalPalette palette,
  ) {
    final tones = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99, 100];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Row(
            children: [
              Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildTokenBadge(
                context,
                name.toLowerCase().replaceAll(' ', '-'),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: tones.map((tone) {
                final color = Color(palette.get(tone));
                final colorHex = color
                    .toARGB32()
                    .toRadixString(16)
                    .padLeft(8, '0')
                    .substring(2)
                    .toUpperCase();
                final onColor = tone > 50 ? Colors.black : Colors.white;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Tooltip(
                      message: 'Tone $tone: #$colorHex',
                      child: GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: '#$colorHex'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copied Tone $tone to clipboard!'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(12),
                                border: tone == 100 || tone == 0
                                    ? Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$tone',
                                  style: TextStyle(
                                    color: onColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '#$colorHex',
                              style: const TextStyle(
                                fontSize: 10,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTokenBadge(BuildContext context, String key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'md.ref.palette.$key',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
