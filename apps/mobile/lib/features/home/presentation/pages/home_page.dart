import 'package:flutter/material.dart';
import 'package:altrupets/features/home/presentation/widgets/service_card.dart';
import 'package:altrupets/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:altrupets/features/profile/presentation/pages/profile_page.dart';
import 'package:altrupets/features/rescues/presentation/pages/rescues_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2; // Home as default

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Center(key: ValueKey(0), child: Text('Comunidad', style: TextStyle(color: Colors.white))),
      const Center(key: ValueKey(1), child: Text('Mensajes', style: TextStyle(color: Colors.white))),
      _HomeContent(key: const ValueKey(2), onRescuesTap: () => _onPageChanged(5)),
      const ProfilePage(key: ValueKey(3)),
      const Center(key: ValueKey(4), child: Text('Ajustes', style: TextStyle(color: Colors.white))),
      const RescuesPage(key: ValueKey(5)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayIndex = _currentIndex > 4 ? 5 : _currentIndex;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: List.generate(_pages.length, (index) {
          final isSelected = index == displayIndex;
          return AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: !isSelected,
              child: _pages[index],
            ),
          );
        }),
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex > 4 ? 2 : _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.onRescuesTap, super.key});

  final VoidCallback onRescuesTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (keep same header)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bienvenido',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '¿Cómo podemos ayudarte hoy?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              physics: const BouncingScrollPhysics(),
              children: [
                ServiceCard(
                  title: 'Rescates',
                  subtitle: 'Interactúa con la red de rescatistas',
                  icon: Icons.support,
                  gradientColors: const [
                    Color(0xFF2563EB),
                    Color(0xFF3B82F6),
                  ],
                  onTap: onRescuesTap,
                ),
                ServiceCard(
                  title: 'Adopciones',
                  subtitle: 'Explora a detalle o escoge al azar',
                  icon: Icons.volunteer_activism,
                  gradientColors: const [
                    Color(0xFF3B82F6),
                    Color(0xFF6366F1),
                  ],
                  onTap: () {},
                ),
                ServiceCard(
                  title: 'Bienestar',
                  subtitle: 'Donaciones y denuncias',
                  icon: Icons.security,
                  gradientColors: const [
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8),
                  ],
                  onTap: () {},
                ),
                ServiceCard(
                  title: 'Salud, Higiene y Aseo',
                  subtitle: 'Busca clínicas, productos y servicios',
                  icon: Icons.medical_services,
                  gradientColors: const [
                    Color(0xFF3B82F6),
                    Color(0xFF2563EB),
                  ],
                  onTap: () {},
                ),
                ServiceCard(
                  title: 'Alimentos',
                  subtitle: 'Accede a la red de proveedores',
                  icon: Icons.pets,
                  gradientColors: const [
                    Color(0xFF2563EB),
                    Color(0xFF3B82F6),
                  ],
                  onTap: () {},
                ),
                ServiceCard(
                  title: 'Accesorios y Juguetes',
                  subtitle: 'Lo mejor para tus compañeros',
                  icon: Icons.toys,
                  gradientColors: const [
                    Color(0xFF3B82F6),
                    Color(0xFF6366F1),
                  ],
                  onTap: () {},
                ),
                const SizedBox(height: 100), // Space for navigation bar
              ],
            ),
          ),
        ],
      ),
    );
  }
}
