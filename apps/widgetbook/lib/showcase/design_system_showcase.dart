import 'package:flutter/material.dart';
import 'tonal_palette_generator.dart';
import 'typography_showcase.dart';
import 'elevation_showcase.dart';
import 'design_system_state.dart';

class DesignSystemShowcase extends StatefulWidget {
  const DesignSystemShowcase({super.key});

  @override
  State<DesignSystemShowcase> createState() => _DesignSystemShowcaseState();
}

class _DesignSystemShowcaseState extends State<DesignSystemShowcase> {
  int _selectedIndex = 0;
  late final DesignSystemManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = DesignSystemManager();
    _manager.loadTokens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _manager,
        builder: (context, _) {
          return Row(
            children: [
              NavigationRail(
                extended: MediaQuery.of(context).size.width > 1200,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.palette_outlined),
                    selectedIcon: Icon(Icons.palette),
                    label: Text('Colors'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.text_fields_outlined),
                    selectedIcon: Icon(Icons.text_fields),
                    label: Text('Typography'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.layers_outlined),
                    selectedIcon: Icon(Icons.layers),
                    label: Text('Elevation'),
                  ),
                ],
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
              const VerticalDivider(thickness: 1, width: 1),
              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return TonalPaletteGenerator(manager: _manager);
      case 1:
        return TypographyShowcase(manager: _manager);
      case 2:
        return ElevationShowcase(manager: _manager);
      default:
        return TonalPaletteGenerator(manager: _manager);
    }
  }
}
