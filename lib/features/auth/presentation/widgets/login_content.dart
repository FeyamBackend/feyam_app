import 'package:feyam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:feyam/features/auth/presentation/widgets/login_page.dart';
import 'package:feyam/features/main/presentation/screens/main_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginContent extends StatefulWidget {
  const LoginContent({super.key});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<AuthBloc>().add(AuthSessionChecked());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AuthBloc>().add(AuthSessionChecked());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == AuthStatus.success,
      listener: (context, state) {
        final isCupertino =
            !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
        final route = isCupertino
            ? CupertinoPageRoute<void>(builder: (_) => const MainScreen())
            : MaterialPageRoute<void>(builder: (_) => const MainScreen());
        Navigator.of(context).pushReplacement(route);
      },
      child: const LoginPage(),
    );
  }
}
