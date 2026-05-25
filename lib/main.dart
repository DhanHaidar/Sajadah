import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sajadah/core/configs/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sajadah/firebase_options.dart';
import 'package:sajadah/presentation/intro/bloc/them_cubit.dart';
import 'package:sajadah/presentation/splash/pages/splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sajadah/service_locator.dart';

// Import Bottom Nav Bar kamu di sini
import 'package:sajadah/common/widgets/bottom_nav_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase (Masih di-block sementara untuk testing)
  //await Supabase.initialize(
  //   url: 'https://nngtndfkbwefsphshnjz.supabase.co',
  //   anonKey: 'sb_publishable_X6hKInwoC4axwGLAsmONCA_Z5okXn4J',
  // );

  // Sign in anonymously so Firestore rules requiring auth won't block reads during development.
  try {
    await FirebaseAuth.instance.signInAnonymously();
  } catch (_) {}

  await intializeDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => ThemeCubit())],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          home: const SplashPage(),
        ),
      ),
    );
  }
}
