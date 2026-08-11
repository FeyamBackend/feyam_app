import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/locale/locale_cubit.dart';
import 'package:feyam/core/theme/cupertino_theme.dart';
import 'package:feyam/core/theme/material_theme.dart';
import 'package:feyam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:feyam/features/auth/presentation/screens/login_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeyamApp extends StatelessWidget {
  const FeyamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<LocaleCubit>.value(value: sl<LocaleCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return _useCupertino
              ? CupertinoApp(
                  title: 'Feyam',
                  theme: buildCupertinoTheme(),
                  locale: locale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  // Some screens use Material widgets / Theme.of(context) even on
                  // the Cupertino path. Without a Theme ancestor here they'd fall
                  // back to Flutter's stock Material palette instead of the
                  // Feyam brand, so we thread buildMaterialTheme() through.
                  builder: (context, child) =>
                      Theme(data: buildMaterialTheme(), child: child!),
                  home: const LoginScreen(),
                )
              : MaterialApp(
                  title: 'Feyam',
                  theme: buildMaterialTheme(),
                  locale: locale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: const LoginScreen(),
                );
        },
      ),
    );
  }

  bool get _useCupertino {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.iOS;
  }
}
