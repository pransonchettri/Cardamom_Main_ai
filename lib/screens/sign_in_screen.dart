import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_ai/screens/otp_verify_screen.dart';
import 'package:plant_ai/screens/root_shell.dart';
import 'package:plant_ai/services/auth_service.dart';
import 'package:plant_ai/services/settings_controller.dart';
import 'package:plant_ai/theme/app_theme.dart';
import 'package:plant_ai/utils/app_route.dart';
import 'package:plant_ai/utils/haptics.dart';
import 'package:plant_ai/widgets/app_logo.dart';

/// Optional sign-in screen — shown after onboarding if the user isn't
/// signed in yet, but always skippable. Every core feature of
/// CardamomAI works fully without an account; this exists for anyone
/// who wants their scan history tied to an identity in the future,
/// not as a gate.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phoneController = TextEditingController();
  bool _googleLoading = false;
  bool _phoneLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continueToApp() {
    context.read<SettingsController>().setHasSeenSignIn(true);
    Navigator.of(context).pushAndRemoveUntil(
      AppRoute.to(const RootShell()),
      (route) => false,
    );
  }

  Future<void> _handleGoogleSignIn() async {
    final settings = context.read<SettingsController>();
    final auth = context.read<AuthService>();

    if (!auth.isAvailable) {
      setState(() => _error = 'Sign-in isn\'t set up for this build yet — tap "Skip for now" to keep using the app.');
      return;
    }

    Haptics.medium(settings);
    setState(() {
      _googleLoading = true;
      _error = null;
    });

    try {
      final result = await auth.signInWithGoogle();
      if (!mounted) return;
      if (result != null) {
        _continueToApp();
      } else {
        setState(() => _googleLoading = false);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _googleLoading = false;
        _error = _messageForAuthError(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _googleLoading = false;
        // Most commonly a PlatformException from google_sign_in itself
        // (e.g. no matching OAuth client registered for this app's
        // package name + SHA-1 in the Firebase console yet) rather than
        // a FirebaseAuthException — still worth naming as a setup issue
        // rather than a vague "try again", since retrying won't help.
        final text = e.toString().toLowerCase();
        _error = text.contains('developer_error') || text.contains('10:') || text.contains('sha')
            ? 'Google sign-in isn\'t fully configured yet for this build (missing SHA-1 fingerprint in the Firebase console). This is a setup issue, not something retrying will fix.'
            : 'Google sign-in didn\'t go through. Please try again.';
      });
    }
  }

  /// Turns a [FirebaseAuthException] code into a message that tells the
  /// difference between "this is a setup problem you (the developer)
  /// need to fix in the Firebase console" and "this is a normal,
  /// retry-able failure" — the two were previously shown identically as
  /// a generic "try again", which is actively misleading for the first
  /// case since retrying can never fix it.
  String _messageForAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'operation-not-allowed':
        return 'Google sign-in isn\'t enabled yet for this project (Firebase Console → Authentication → Sign-in method). This won\'t fix itself by retrying.';
      case 'invalid-credential':
      case 'account-exists-with-different-credential':
        return 'That Google account is already linked to a different sign-in method here.';
      case 'network-request-failed':
        return 'No internet connection — check your connection and try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return e.message ?? 'Google sign-in didn\'t go through. Please try again.';
    }
  }

  Future<void> _handleSendCode() async {
    final raw = _phoneController.text.trim();
    if (raw.length < 8) {
      setState(() => _error = 'Enter a full phone number, including country code (e.g. +91...).');
      return;
    }

    final auth = context.read<AuthService>();
    if (!auth.isAvailable) {
      setState(() => _error = 'Sign-in isn\'t set up for this build yet — tap "Skip for now" to keep using the app.');
      return;
    }

    final settings = context.read<SettingsController>();
    Haptics.medium(settings);
    setState(() {
      _phoneLoading = true;
      _error = null;
    });

    try {
      await auth.sendPhoneOtp(
        phoneNumber: raw,
        onCodeSent: (verificationId) {
          if (!mounted) return;
          setState(() => _phoneLoading = false);
          Navigator.push(
            context,
            AppRoute.to(OtpVerifyScreen(
              verificationId: verificationId,
              phoneNumber: raw,
              onVerified: _continueToApp,
            )),
          );
        },
        onError: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _phoneLoading = false;
            _error = e.message ?? 'Could not send a code to that number. Please check it and try again.';
          });
        },
        onAutoVerified: (_) {
          if (!mounted) return;
          _continueToApp();
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phoneLoading = false;
        _error = 'Something went wrong sending the code. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 20, 26, 26),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 46),
                child: IntrinsicHeight(
                  child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _continueToApp,
                  child: Text(
                    'Skip for now',
                    style: TextStyle(color: context.secondaryText, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const AppLogoMark(size: 64, iconScale: 0.5),
              const SizedBox(height: 22),
              Text(
                'Sign in to CardamomAI',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: context.primaryText),
              ),
              const SizedBox(height: 8),
              Text(
                'Totally optional — every feature already works without an account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.secondaryText, fontSize: 12.5, height: 1.5),
              ),
              const SizedBox(height: 32),
              if (_error != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.danger.withOpacity(0.25)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger, fontSize: 12.5),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _googleLoading ? null : _handleGoogleSignIn,
                  icon: _googleLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const _GoogleGlyph(),
                  label: Text(
                    _googleLoading ? 'Signing in…' : 'Continue with Google',
                    style: TextStyle(fontWeight: FontWeight.w800, color: context.primaryText),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(child: Divider(color: context.borderColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or use your phone', style: TextStyle(color: context.secondaryText, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: context.borderColor)),
                ],
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: context.primaryText),
                decoration: InputDecoration(
                  hintText: '+91 98765 43210',
                  hintStyle: TextStyle(color: context.secondaryText),
                  prefixIcon: Icon(Icons.phone_rounded, color: context.secondaryText),
                  filled: true,
                  fillColor: context.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _phoneLoading ? null : _handleSendCode,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _phoneLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Send code', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const Spacer(),
              Text(
                'Standard SMS rates may apply.',
                style: TextStyle(color: context.secondaryText, fontSize: 10.5),
              ),
            ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

/// A small drawn "G" mark so the Google button doesn't need a bundled
/// image asset — just four coloured arcs, Google's own brand shape.
class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.22;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    void arc(double startDeg, double sweepDeg, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startDeg * 3.14159 / 180, sweepDeg * 3.14159 / 180, false, paint);
    }

    arc(-45, 90, const Color(0xFF4285F4));
    arc(45, 90, const Color(0xFF34A853));
    arc(135, 90, const Color(0xFFFBBC05));
    arc(225, 90, const Color(0xFFEA4335));

    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - strokeWidth / 2, radius - strokeWidth * 0.3, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
