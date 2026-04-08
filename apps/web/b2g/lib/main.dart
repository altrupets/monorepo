import 'package:flutter/material.dart';
import 'package:altrupets_ui/altrupets_ui.dart';
import 'app_router.dart';

void main() {
  runApp(const AltruPetsB2GApp());
}

class AltruPetsB2GApp extends StatelessWidget {
  const AltruPetsB2GApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AltruPets B2G',
      debugShowCheckedModeBanner: false,
      theme: AltruPetsTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
