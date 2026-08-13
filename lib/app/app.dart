import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/app_state.dart';
import 'routes.dart';
import 'theme.dart';

// Auth
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';

// Shell
import '../shared/widgets/app_shell.dart';

// Government Services
import '../features/government/presentation/pages/government_services_page.dart';
import '../features/government/presentation/pages/letter_interpreter_page.dart';
import '../features/government/presentation/pages/smart_form_page.dart';
import '../features/government/presentation/pages/document_checker_page.dart';

// Mobility
import '../features/mobility/presentation/pages/mobility_page.dart';
import '../features/mobility/presentation/pages/tropical_route_page.dart';
import '../features/mobility/presentation/pages/public_transport_page.dart';

// Walkability
import '../features/walkability/presentation/pages/walkability_page.dart';

// Voice
import '../features/voice/presentation/pages/listening_page.dart';
import '../features/voice/presentation/pages/processing_page.dart';

class SuaraWargaApp extends StatelessWidget {
  const SuaraWargaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      title: 'SuaraWarga AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(appState),
      initialRoute: appState.isLoggedIn ? AppRoutes.home : AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),
        AppRoutes.home: (_) => const AppShell(),
        AppRoutes.govServices: (_) => const GovernmentServicesPage(),
        AppRoutes.letterInterpreter: (_) => const LetterInterpreterPage(),
        AppRoutes.formAssistant: (_) => const SmartFormPage(),
        AppRoutes.docChecker: (_) => const DocumentCheckerPage(),
        AppRoutes.smartMobility: (_) => const SmartMobilityPage(),
        AppRoutes.tropicalRoute: (_) => const TropicalRoutePage(),
        AppRoutes.transitGuide: (_) => const PublicTransportPage(),
        AppRoutes.walkability: (_) => const WalkabilityPage(),
        AppRoutes.listening: (_) => const ListeningPage(),
        AppRoutes.processing: (_) => const ProcessingPage(),
      },
    );
  }
}
