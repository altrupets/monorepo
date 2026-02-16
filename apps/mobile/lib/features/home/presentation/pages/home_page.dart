import 'package:altrupets/core/theme/app_motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:altrupets/core/widgets/molecules/app_service_card.dart';
import 'package:altrupets/core/widgets/molecules/home_welcome_header.dart';
import 'package:altrupets/core/widgets/organisms/main_navigation_bar.dart';
import 'package:altrupets/features/profile/presentation/pages/profile_page.dart';
import 'package:altrupets/features/rescues/presentation/pages/rescues_page.dart';
import 'package:altrupets/features/settings/presentation/pages/settings_page.dart';
import 'package:altrupets/features/profile/presentation/providers/profile_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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
    debugPrint('[HomePage] 🏠 initState llamado');

    _pages = [
      const Center(key: ValueKey(0), child: Text('Comunidad', style: TextStyle(color: Colors.white))),
      const Center(key: ValueKey(1), child: Text('Mensajes', style: TextStyle(color: Colors.white))),
      _HomeContent(
        key: const ValueKey(2),
        onRescuesTap: () => _onPageChanged(5),
        greetingName: null,
      ),
      ProfilePage(
        key: const ValueKey(3),
        onBack: () => _onPageChanged(2),
      ),
      const SettingsPage(key: ValueKey(4)),
      RescuesPage(
        key: const ValueKey(5),
        onBack: () => _onPageChanged(2),
      ),
    ];

    // Race condition fix: Solo invalidar si no viene de login exitoso
    // El login ya invalida y precarga el provider
    Future.microtask(() async {
      final currentUserAsync = ref.read(currentUserProvider);
      debugPrint('[HomePage] ⏳ initState - currentUserProvider state: ${currentUserAsync.toString()}');

      // Solo recargar si está en estado inicial (no está cargando ni tiene valor)
      if (currentUserAsync is! AsyncLoading && currentUserAsync is! AsyncData) {
        debugPrint('[HomePage] 🔄 Invalidando currentUserProvider desde initState...');
        ref.invalidate(currentUserProvider);
        final user = await ref.read(currentUserProvider.future);
        debugPrint('[HomePage] ✅ currentUserProvider resuelto: ${user != null ? user.username : 'NULL'}');
      } else {
        debugPrint('[HomePage] ⏭️ Saltando recarga - provider ya en estado: ${currentUserAsync.runtimeType}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayIndex = _currentIndex > 4 ? 5 : _currentIndex;
    final currentUserAsync = ref.watch(currentUserProvider);
    final user = currentUserAsync.valueOrNull;
    final fullName = [
      user?.firstName?.trim() ?? '',
      user?.lastName?.trim() ?? '',
    ].where((value) => value.isNotEmpty).join(' ');
    final greetingName = fullName.isNotEmpty ? fullName : user?.username;

    debugPrint('[HomePage] 🔨 BUILD - currentUserAsync: ${currentUserAsync.runtimeType}, user: ${user?.username ?? 'NULL'}, greetingName: $greetingName');

    final updatedPages = [
      _pages[0],
      _pages[1],
      _HomeContent(
        key: const ValueKey(2),
        onRescuesTap: () => _onPageChanged(5),
        greetingName: greetingName,
      ),
      _pages[3],
      _pages[4],
      _pages[5],
    ];

    return PopScope(
      canPop: _currentIndex == 2, // Only allow system pop if on Home tab
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        // If not on Home tab, go back to Home tab (index 2)
        if (_currentIndex != 2) {
          setState(() {
            _currentIndex = 2;
          });
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Stack(
          children: List.generate(updatedPages.length, (index) {
            final isSelected = index == displayIndex;
            return AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: AppMotion.medium,
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring: !isSelected,
                child: updatedPages[index],
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
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.onRescuesTap,
    required this.greetingName,
    super.key,
  });

  final VoidCallback onRescuesTap;
  final String? greetingName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeWelcomeHeader(
            onNotificationTap: () {},
            greetingName: greetingName,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
              physics: const BouncingScrollPhysics(),
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = (constraints.maxWidth / 300).floor().clamp(1, 3);
                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 12,
                      childAspectRatio: 3.0,
                      children: [
                        AppServiceCard(
                          title: 'Rescates',
                          subtitle: 'Interactúa con la red de rescatistas',
                          icon: Icons.support,
                          gradientColors: const [
                            Color(0xFF2563EB),
                            Color(0xFF3B82F6),
                          ],
                          onTap: onRescuesTap,
                        ),
                        AppServiceCard(
                          title: 'Adopciones',
                          subtitle: 'Explora a detalle o escoge al azar',
                          icon: Icons.volunteer_activism,
                          gradientColors: const [
                            Color(0xFF3B82F6),
                            Color(0xFF6366F1),
                          ],
                          onTap: () {},
                        ),
                        AppServiceCard(
                          title: 'Bienestar',
                          subtitle: 'Donaciones y denuncias',
                          icon: Icons.security,
                          gradientColors: const [
                            Color(0xFF2563EB),
                            Color(0xFF1D4ED8),
                          ],
                          onTap: () {},
                        ),
                        AppServiceCard(
                          title: 'Salud, Higiene y Aseo',
                          subtitle: 'Busca clínicas, productos y servicios',
                          icon: Icons.medical_services,
                          gradientColors: const [
                            Color(0xFF3B82F6),
                            Color(0xFF2563EB),
                          ],
                          onTap: () {},
                        ),
                        AppServiceCard(
                          title: 'Alimentos',
                          subtitle: 'Accede a la red de proveedores',
                          icon: Icons.pets,
                          gradientColors: const [
                            Color(0xFF2563EB),
                            Color(0xFF3B82F6),
                          ],
                          onTap: () {},
                        ),
                        AppServiceCard(
                          title: 'Accesorios y Juguetes',
                          subtitle: 'Lo mejor para tus compañeros',
                          icon: Icons.toys,
                          gradientColors: const [
                            Color(0xFF3B82F6),
                            Color(0xFF6366F1),
                          ],
                          onTap: () {},
                        ),
                      ],
                    );
                  },
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
