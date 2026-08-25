import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'core/services/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://zwviiatgqkyjagrsnjqd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp3dmlpYXRncWt5amFncnNuanFkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc2NTE1OTMsImV4cCI6MjEwMzIyNzU5M30.nyBwX2p7oUVbkDpnM5Ibw2PrC3iNohUz7a9OXDjo9dg',
  );

  final appState = AppState();
  await appState.initLocalStorage();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
      ],
      child: const SuaraWargaApp(),
    ),
  );
}
