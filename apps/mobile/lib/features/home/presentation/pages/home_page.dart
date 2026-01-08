import 'package:flutter/material.dart';
import 'package:altrupets/features/home/presentation/widgets/service_card.dart';
import 'package:altrupets/features/home/presentation/widgets/main_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2; // Home as default

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    onTap: () {},
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
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
