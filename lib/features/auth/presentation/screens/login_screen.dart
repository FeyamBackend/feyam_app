import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:feyam/features/auth/presentation/widgets/login_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: Theme(
        data: Theme.of(context).copyWith(platform: defaultTargetPlatform),
        child: const LoginContent(),
      ),
    );

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoPageScaffold(child: content);
    }

    return Scaffold(body: content);
  }
}
