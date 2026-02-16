import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_system_state.dart';

class TypographyShowcase extends StatelessWidget {
  final DesignSystemManager manager;
  const TypographyShowcase({super.key, required this.manager});

  TextStyle _getStyle(String fontFamily, TextStyle baseStyle) {
    if (['Lemon Milk', 'Poppins'].contains(fontFamily)) {
      return baseStyle.copyWith(fontFamily: fontFamily, package: 'altrupets');
    }
    try {
      return GoogleFonts.getFont(fontFamily, textStyle: baseStyle);
    } catch (e) {
      return baseStyle.copyWith(fontFamily: fontFamily);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 48),
          _buildFontPickers(context),
          const SizedBox(height: 48),
          _TypeSection(
            category: 'Display',
            description: 'As the largest text on the screen, display styles are reserved for short, important text or numerals.',
            fontFamily: manager.headerFont,
            styles: [
              _TypeItem(
                label: 'Display Large',
                style: _getStyle(manager.headerFont, Theme.of(context).textTheme.displayLarge!),
                info: '${manager.headerFont} - 57/64 - -0.25',
              ),
              _TypeItem(
                label: 'Display Medium',
                style: _getStyle(manager.headerFont, Theme.of(context).textTheme.displayMedium!),
                info: '${manager.headerFont} - 45/52 - 0',
              ),
              _TypeItem(
                label: 'Display Small',
                style: _getStyle(manager.headerFont, Theme.of(context).textTheme.displaySmall!),
                info: '${manager.headerFont} - 36/44 - 0',
              ),
            ],
          ),
          const _Divider(),
          _TypeSection(
            category: 'Headline',
            description: 'Headlines are best-suited for short, high-emphasis text on smaller screens.',
            fontFamily: manager.headerFont,
            styles: [
              _TypeItem(
                label: 'Headline Large',
                style: _getStyle(manager.headerFont, Theme.of(context).textTheme.headlineLarge!),
                info: '${manager.headerFont} - 32/40 - 0',
              ),
              _TypeItem(
                label: 'Headline Medium',
                style: _getStyle(manager.headerFont, Theme.of(context).textTheme.headlineMedium!),
                info: '${manager.headerFont} - 28/36 - 0',
              ),
              _TypeItem(
                label: 'Headline Small',
                style: _getStyle(manager.headerFont, Theme.of(context).textTheme.headlineSmall!),
                info: '${manager.headerFont} - 24/32 - 0',
              ),
            ],
          ),
          const _Divider(),
          _TypeSection(
            category: 'Title',
            description: 'Titles are smaller than headlines and should be used for medium-emphasis text that remains relatively short.',
            fontFamily: manager.bodyFont,
            styles: [
              _TypeItem(
                label: 'Title Large',
                style: _getStyle(manager.bodyFont, Theme.of(context).textTheme.titleLarge!),
                info: '${manager.bodyFont} - 22/28 - 0',
              ),
              _TypeItem(
                label: 'Title Medium',
                style: _getStyle(manager.bodyFont, Theme.of(context).textTheme.titleMedium!),
                info: '${manager.bodyFont} - 16/24 - 0.15',
              ),
              _TypeItem(
                label: 'Title Small',
                style: _getStyle(manager.bodyFont, Theme.of(context).textTheme.titleSmall!),
                info: '${manager.bodyFont} - 14/20 - 0.1',
              ),
            ],
          ),
          const _Divider(),
          _TypeSection(
            category: 'Body',
            description: 'Body styles are used for longer passages of text in your app.',
            fontFamily: manager.bodyFont,
            styles: [
              _TypeItem(
                label: 'Body Large',
                style: _getStyle(manager.bodyFont, Theme.of(context).textTheme.bodyLarge!),
                info: '${manager.bodyFont} - 16/24 - 0.5',
              ),
              _TypeItem(
                label: 'Body Medium',
                style: _getStyle(manager.bodyFont, Theme.of(context).textTheme.bodyMedium!),
                info: '${manager.bodyFont} - 14/20 - 0.25',
              ),
              _TypeItem(
                label: 'Body Small',
                style: _getStyle(manager.bodyFont, Theme.of(context).textTheme.bodySmall!),
                info: '${manager.bodyFont} - 12/16 - 0.4',
              ),
            ],
          ),
          const _Divider(),
          _TypeSection(
            category: 'Label',
            description: 'Label styles are smaller, utilitarian styles used for areas of the UI such as text inside of buttons or secondary text in list items.',
            fontFamily: manager.bodyFont,
            styles: [
              _TypeItem(
                label: 'Label Large',
                style: _getStyle(manager.bodyFont, Theme.of(context).textTheme.labelLarge!),
                info: '${manager.bodyFont} - 14/20 - 0.1',
              ),
              _TypeItem(
                label: 'Label Medium',
                style: _getStyle(manager.bodyFont, Theme.of(context).textTheme.labelMedium!),
                info: '${manager.bodyFont} - 12/16 - 0.5',
              ),
              _TypeItem(
                label: 'Label Small',
                style: _getStyle(manager.bodyFont, Theme.of(context).textTheme.labelSmall!),
                info: '${manager.bodyFont} - 11/16 - 0.5',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.text_fields_rounded, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Typography Management',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your typography settings and visualize the M3 type scale.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _buildActionButton(
                  context,
                  label: 'Load',
                  icon: Icons.refresh_rounded,
                  onPressed: () => manager.loadTokens(),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: manager.isLoading ? null : () => manager.syncAll(),
                  label: const Text('SYNC CHANGES'),
                  icon: manager.isLoading 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.sync_rounded),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    );
  }

  Widget _buildFontPickers(BuildContext context) {
    final List<String> availableFonts = [
      'Lemon Milk',
      'Poppins',
      'Roboto',
      'Open Sans',
      'Montserrat',
      'Lato',
      'Playfair Display',
      'Merriweather',
      'Inter',
    ];

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: _buildDropdown(
                context,
                'Header Font',
                manager.headerFont,
                availableFonts,
                (val) => manager.updateFonts(header: val),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildDropdown(
                context,
                'Body/Primary Font',
                manager.bodyFont,
                availableFonts,
                (val) => manager.updateFonts(body: val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    String label,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Column(
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : null,
              isExpanded: true,
              hint: Text('Select Font'),
              items: options.map((String font) {
                return DropdownMenuItem<String>(
                  value: font,
                  child: Text(font),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeSection extends StatelessWidget {
  final String category;
  final String description;
  final String fontFamily;
  final List<_TypeItem> styles;

  const _TypeSection({
    required this.category,
    required this.description,
    required this.fontFamily,
    required this.styles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              category,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                fontFamily,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 32),
        ...styles,
      ],
    );
  }
}

class _TypeItem extends StatelessWidget {
  final String label;
  final TextStyle style;
  final String info;

  const _TypeItem({
    required this.label,
    required this.style,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  info,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              'The quick brown fox jumps over the lazy dog',
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Divider(thickness: 1, height: 1),
    );
  }
}
