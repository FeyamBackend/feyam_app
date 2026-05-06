import 'package:feyam/core/widgets/adaptive/adaptive_app_button.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_app_disclaimer.dart';
import 'package:feyam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:feyam/features/auth/presentation/widgets/login_background.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCupertino = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final panelColor = isCupertino
        ? CupertinoTheme.of(context).scaffoldBackgroundColor
        : colorScheme.surface;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const LoginBackground(),
        LayoutBuilder(
          builder: (context, constraints) {
            final logoWidth = (constraints.maxWidth * 0.42)
                .clamp(180.0, 240.0)
                .toDouble();
            final panelHeight = (constraints.maxHeight * 0.40)
                .clamp(360.0, 420.0)
                .toDouble();

            return Stack(
              children: <Widget>[
                SafeArea(
                  bottom: false,
                  child: Align(
                    alignment: const Alignment(0, -0.48),
                    child: Image.asset(
                      'assets/branding/logo.png',
                      width: logoWidth,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: panelHeight + bottomInset,
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(32, 40, 32, 18 + bottomInset),
                    decoration: BoxDecoration(
                      color: panelColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(56),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.10),
                          blurRadius: 34,
                          offset: const Offset(0, -16),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  final isLoading =
                                      state.status == AuthStatus.loading;

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      AdaptiveAppButton(
                                        text: l10n.login,
                                        icon: const Icon(Icons.arrow_forward),
                                        isLoading: isLoading,
                                        onPressed: isLoading
                                            ? null
                                            : () {
                                                context.read<AuthBloc>().add(
                                                  SignInPressed(),
                                                );
                                              },
                                        height: 72,
                                        borderRadius: BorderRadius.circular(28),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                        ),
                                      ),
                                      if (state.status == AuthStatus.failure &&
                                          state.errorMessage != null) ...[
                                        const SizedBox(height: 14),
                                        Text(
                                          state.errorMessage!,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: colorScheme.error,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              AdaptiveAppDisclaimer(
                                message: l10n.loginDisclaimer,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 18,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                backgroundColor: colorScheme.surface.withValues(
                                  alpha: 0.72,
                                ),
                                foregroundColor: colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
