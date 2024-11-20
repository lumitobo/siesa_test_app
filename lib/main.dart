import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/constants/environment.dart';
import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';

Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();
  await Supabase.initialize(url: Environment.supabaseURL, anonKey: Environment.supabaseKEY);

  runApp(const ProviderScope(child: MainApp() ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}
