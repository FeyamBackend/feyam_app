import 'package:feyam/core/theme/app_theme_palette.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_app_button.dart';
import 'package:feyam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Sign In and Create Account share one loading status on AuthState, so this
  // tracks which of the two buttons the spinner belongs to.
  bool _signUpInFlight = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const ColoredBox(color: Colors.white),
        SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final logoWidth = (constraints.maxWidth * 0.44)
                  .clamp(160.0, 210.0)
                  .toDouble();
              final illustrationWidth = (constraints.maxWidth * 0.28)
                  .clamp(110.0, 140.0)
                  .toDouble();
              final waveDip = (constraints.maxWidth * 0.19)
                  .clamp(48.0, 72.0)
                  .toDouble();

              return Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _WavePainter(
                            dip: waveDip,
                            color: ConciergeProPalette.primary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 10, 28, 36),
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/branding/logo_white.png',
                              width: logoWidth,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l10n.loginTaglinePrimary,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 19,
                                height: 1.2,
                              ),
                            ),
                            Text(
                              l10n.loginTaglineHighlight,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF8FBC42),
                                fontWeight: FontWeight.w800,
                                fontSize: 19,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.loginSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),
                            RepaintBoundary(
                              child: Image.asset(
                                'assets/branding/globe_mark.png',
                                width: illustrationWidth,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        28,
                        30,
                        28,
                        10 + bottomInset,
                      ),
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state.status == AuthStatus.loading;
                          final onSignIn = isLoading
                              ? null
                              : () {
                                  setState(() => _signUpInFlight = false);
                                  context.read<AuthBloc>().add(SignInPressed());
                                };
                          final onSignUp = isLoading
                              ? null
                              : () {
                                  setState(() => _signUpInFlight = true);
                                  context.read<AuthBloc>().add(SignUpPressed());
                                };

                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              const Expanded(child: SizedBox()),
                              AdaptiveAppButton(
                                text: l10n.login,
                                icon: const Icon(Icons.person_outline),
                                isLoading: isLoading && !_signUpInFlight,
                                onPressed: onSignIn,
                                height: 48,
                                backgroundColor: ConciergeProPalette.primary,
                                foregroundColor: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              const SizedBox(height: 10),
                              AdaptiveAppButton(
                                text: l10n.createAccount,
                                icon: const Icon(Icons.add_circle_outline),
                                isLoading: isLoading && _signUpInFlight,
                                onPressed: onSignUp,
                                height: 48,
                                backgroundColor: ConciergeProPalette.secondary,
                                foregroundColor: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              if (state.status == AuthStatus.failure &&
                                  state.errorMessage != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  state.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: ConciergeProPalette.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: <Widget>[
                                  const Expanded(
                                    child: Divider(
                                      color: ConciergeProPalette.outlineVariant,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      l10n.orContinueWith,
                                      style: TextStyle(
                                        color: ConciergeProPalette
                                            .onSurfaceVariant,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(
                                      color: ConciergeProPalette.outlineVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  _SocialLoginButton(
                                    semanticLabel: 'Google',
                                    onPressed: onSignIn,
                                    child: const _GoogleMark(),
                                  ),
                                  const SizedBox(width: 14),
                                  _SocialLoginButton(
                                    semanticLabel: 'Apple',
                                    onPressed: onSignIn,
                                    child: const Icon(
                                      Icons.apple,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  _SocialLoginButton(
                                    semanticLabel: 'Facebook',
                                    onPressed: onSignIn,
                                    child: const Icon(
                                      Icons.facebook,
                                      color: Color(0xFF1877F2),
                                      size: 26,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Icon(
                                    Icons.lock_outline,
                                    size: 14,
                                    color: ConciergeProPalette.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      l10n.loginDisclaimer,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: ConciergeProPalette
                                            .onSurfaceVariant,
                                        fontSize: 11,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Paints the wave-bottom navy hero shape directly instead of using
/// [ClipPath], which triggers a Flutter/Impeller compositing bug that
/// renders transparent PNG regions as opaque black when a clipped subtree
/// contains an [Image].
class _WavePainter extends CustomPainter {
  const _WavePainter({required this.dip, required this.color});

  final double dip;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final flatY = size.height - dip;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, flatY)
      ..quadraticBezierTo(size.width / 2, size.height + dip, size.width, flatY)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.dip != dip || oldDelegate.color != color;
}

/// Social sign-in avatars all redirect through the same Keycloak-hosted
/// login flow as [AuthBloc]'s [SignInPressed] — there's no native Google/
/// Apple/Facebook SDK integrated, so brokering those providers (if enabled)
/// happens on the hosted login page itself.
class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Opacity(
        opacity: onPressed == null ? 0.5 : 1,
        child: Material(
          color: Colors.white,
          shape: CircleBorder(
            side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
          ),
          elevation: 1,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(width: 44, height: 44, child: Center(child: child)),
          ),
        ),
      ),
    );
  }
}

/// Hand-drawn "G" mark in Google's brand colors — no brand icon font is
/// bundled in this app, so this stands in for the official multi-color logo.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const SweepGradient(
        colors: <Color>[
          Color(0xFF4285F4),
          Color(0xFF34A853),
          Color(0xFFFBBC05),
          Color(0xFFEA4335),
          Color(0xFF4285F4),
        ],
      ).createShader(bounds),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}
