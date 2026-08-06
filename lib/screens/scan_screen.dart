import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_ai/screens/preview_screen.dart';
import 'package:plant_ai/theme/app_theme.dart';
import 'package:plant_ai/widgets/floating_decor.dart';
import 'package:plant_ai/utils/app_route.dart';

/// Entry point for the scan flow.
///
/// Flutter Web cannot reliably render a live `camera` package preview
/// across every browser (permission timing, video-element sizing,
/// autoplay policies all vary), so on web we hand capture off to the
/// browser's own native camera UI via `image_picker`, which is far
/// more robust — it either opens the OS/browser camera immediately or
/// falls back to a file picker, but it never hangs on a blank preview.
///
/// Native platforms keep the live in-app camera preview.
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? const _WebScanScreen() : const _NativeScanScreen();
  }
}

// ---------------------------------------------------------------------------
// WEB FLOW
// ---------------------------------------------------------------------------

enum _WebCaptureState { idle, opening, error }

class _WebScanScreen extends StatefulWidget {
  const _WebScanScreen();

  @override
  State<_WebScanScreen> createState() => _WebScanScreenState();
}

class _WebScanScreenState extends State<_WebScanScreen> {
  _WebCaptureState _state = _WebCaptureState.idle;
  String? _errorMessage;

  Future<void> _capture(ImageSource source) async {
    setState(() {
      _state = _WebCaptureState.opening;
      _errorMessage = null;
    });

    try {
      final picker = ImagePicker();
      final file = await picker
          .pickImage(source: source, imageQuality: 90, maxWidth: 2000)
          .timeout(
            const Duration(seconds: 45),
            onTimeout: () => throw TimeoutException('capture timed out'),
          );

      if (!mounted) return;

      if (file == null) {
        // User closed the picker without choosing a photo — not an error.
        setState(() => _state = _WebCaptureState.idle);
        return;
      }

      await Navigator.push(
        context,
        AppRoute.to(PreviewScreen(imagePath: file.path)),
      );

      if (mounted) setState(() => _state = _WebCaptureState.idle);
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _state = _WebCaptureState.error;
        _errorMessage = 'That took too long to respond. Please try again.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _WebCaptureState.error;
        _errorMessage = source == ImageSource.camera
            ? 'Could not open your camera. Your browser may not support in-page camera capture — try "Choose a photo" instead, or allow camera access and retry.'
            : 'Could not open the file picker. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final opening = _state == _WebCaptureState.opening;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            const FloatingDecor(),
            SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              children: [
                Row(
                  children: [
                    _RoundIconButton(icon: Icons.close_rounded, onTap: () => Navigator.pop(context)),
                    const Spacer(),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
                  ),
                  child: Icon(
                    _state == _WebCaptureState.error ? Icons.error_outline_rounded : Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ).animate(target: opening ? 1 : 0).scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.06, 1.06),
                      duration: 700.ms,
                      curve: Curves.easeInOut,
                    ),
                const SizedBox(height: 26),
                const Text(
                  'Scan a cardamom leaf',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  _state == _WebCaptureState.error
                      ? _errorMessage ?? 'Something went wrong.'
                      : 'Your browser will open its own camera to take the photo, or you can choose one from your files.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _state == _WebCaptureState.error ? const Color(0xFFFFD3CC) : Colors.white70,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                if (_state == _WebCaptureState.error)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TextButton.icon(
                      onPressed: () => setState(() {
                        _state = _WebCaptureState.idle;
                        _errorMessage = null;
                      }),
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      label: const Text('Try again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: FilledButton.icon(
                    onPressed: opening ? null : () => _capture(ImageSource.camera),
                    icon: opening
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.forest),
                          )
                        : const Icon(Icons.camera_alt_rounded),
                    label: Text(
                      opening ? 'Opening camera…' : 'Open camera',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.forest,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: opening ? null : () => _capture(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
                    label: const Text(
                      'Choose a photo instead',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NATIVE FLOW (Android / iOS / desktop) — live camera preview
// ---------------------------------------------------------------------------

enum _CamState { initializing, ready, error }

class _NativeScanScreen extends StatefulWidget {
  const _NativeScanScreen();

  @override
  State<_NativeScanScreen> createState() => _NativeScanScreenState();
}

class _NativeScanScreenState extends State<_NativeScanScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  _CamState _state = _CamState.initializing;
  String? _errorMessage;
  bool _capturing = false;
  bool _showFlash = false;

  late final AnimationController _scanLine;

  @override
  void initState() {
    super.initState();
    _scanLine = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
    _startCamera();
  }

  Future<void> _startCamera() async {
    setState(() {
      _state = _CamState.initializing;
      _errorMessage = null;
    });

    final oldController = _controller;
    _controller = null;
    if (oldController != null) {
      await oldController.dispose();
    }

    try {
      final cameras = await availableCameras().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('availableCameras timed out'),
      );

      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _state = _CamState.error;
          _errorMessage = 'No camera was found on this device.';
        });
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          controller.dispose();
          throw TimeoutException('initialize timed out');
        },
      );

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _state = _CamState.ready;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _state = _CamState.error;
        _errorMessage = 'The camera took too long to start. Please try again.';
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _CamState.error;
        _errorMessage = _describeCameraError(e);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = _CamState.error;
        _errorMessage = 'The camera could not start. Please try again.';
      });
    }
  }

  String _describeCameraError(CameraException e) {
    switch (e.code) {
      case 'CameraAccessDenied':
      case 'CameraAccessDeniedWithoutPrompt':
      case 'CameraAccessRestricted':
        return 'Camera permission was denied. Enable camera access in your device settings and try again.';
      case 'AudioAccessDenied':
        return 'Microphone permission was denied, but a photo scan does not need audio — try again.';
      default:
        return 'Camera error: ${e.description ?? e.code}';
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || controller.value.isTakingPicture || _capturing) {
      return;
    }

    setState(() {
      _capturing = true;
      _showFlash = true;
    });
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) setState(() => _showFlash = false);
    });

    try {
      final image = await controller.takePicture();
      if (!mounted) return;
      await Navigator.push(
        context,
        AppRoute.to(PreviewScreen(imagePath: image.path)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not capture the image. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _switchCamera() async {
    final old = _controller;
    if (old == null) return;

    try {
      final cameras = await availableCameras();
      if (cameras.length < 2) return;

      final next = cameras.firstWhere(
        (c) => c.lensDirection != old.description.lensDirection,
        orElse: () => cameras.first,
      );

      await old.dispose();
      if (!mounted) return;
      setState(() {
        _controller = null;
        _state = _CamState.initializing;
      });

      final controller = CameraController(next, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _state = _CamState.ready;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not switch cameras on this device.')),
        );
      }
    }
  }

  Future<void> _toggleFlash() async {
    final c = _controller;
    if (c == null) return;
    try {
      final mode = c.value.flashMode == FlashMode.off ? FlashMode.auto : FlashMode.off;
      await c.setFlashMode(mode);
      if (mounted) setState(() {});
    } catch (_) {
      // Some devices/desktop cameras don't support flash control — ignore.
    }
  }

  Future<void> _useGallery() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 92);
      if (file == null || !mounted) return;
      Navigator.push(context, AppRoute.to(PreviewScreen(imagePath: file.path)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the gallery.')),
      );
    }
  }

  @override
  void dispose() {
    _scanLine.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = _state == _CamState.ready && _controller != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_state == _CamState.initializing)
              const _InitializingView()
            else if (_state == _CamState.error)
              _ErrorView(message: _errorMessage ?? 'Something went wrong.', onRetry: _startCamera, onUseGallery: _useGallery)
            else
              CameraPreview(_controller!),

            if (ready) ...[
              IgnorePointer(child: CustomPaint(painter: _ScannerPainter(_scanLine), size: Size.infinite)),
              Positioned(
                top: 14,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    _RoundIconButton(icon: Icons.close_rounded, onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CardamomAI', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                          Text('Leaf health scanner', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    _RoundIconButton(
                      icon: _controller!.value.flashMode == FlashMode.off ? Icons.flash_off_rounded : Icons.flash_auto_rounded,
                      onTap: _toggleFlash,
                    ),
                    const SizedBox(width: 8),
                    _RoundIconButton(icon: Icons.flip_camera_ios_rounded, onTap: _switchCamera),
                  ],
                ),
              ),
              Positioned(
                top: 105,
                left: 25,
                right: 25,
                child: Column(
                  children: [
                    const Text(
                      'SCAN A CARDAMOM LEAF',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Place the affected area inside the frame',
                      style: TextStyle(color: Colors.white.withOpacity(.82), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 25,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    TextButton.icon(
                      onPressed: _useGallery,
                      icon: const Icon(Icons.photo_library_outlined, color: Colors.white70, size: 18),
                      label: const Text('Use a photo instead', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _capturing ? null : _capture,
                      child: Container(
                        width: 84,
                        height: 84,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _capturing ? Colors.white54 : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: _capturing
                              ? const Padding(
                                  padding: EdgeInsets.all(18),
                                  child: CircularProgressIndicator(strokeWidth: 3),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text('CAPTURE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  ],
                ),
              ),
            ],

            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _showFlash ? 1 : 0,
                duration: const Duration(milliseconds: 90),
                child: Container(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitializingView extends StatelessWidget {
  const _InitializingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white),
              ),
            ).animate(onPlay: (c) => c.repeat()).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.08, 1.08),
                  duration: 900.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 22),
            const Text('Starting camera…', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Allow camera access if your browser or device asks for it.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onUseGallery;

  const _ErrorView({required this.message, required this.onRetry, required this.onUseGallery});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_rounded, color: Colors.white70, size: 56),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again', style: TextStyle(fontWeight: FontWeight.w800)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.emeraldLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: onUseGallery,
                  icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
                  label: const Text('Use a photo instead', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go back', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      ),
    );
  }
}

class _ScannerPainter extends CustomPainter {
  final Animation<double> progress;

  _ScannerPainter(this.progress) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    const box = 285.0;
    final left = (size.width - box) / 2;
    final top = (size.height - box) / 2;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, box, box),
      const Radius.circular(26),
    );

    final overlay = Paint()..color = Colors.black.withOpacity(.32);
    final outside = Path()..addRect(Offset.zero & size);
    final hole = Path()..addRRect(rect);
    canvas.drawPath(Path.combine(PathOperation.difference, outside, hole), overlay);

    final p = Paint()
      ..color = const Color(0xFFC9F7D1)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const c = 30.0;
    canvas.drawLine(Offset(rect.left, rect.top + c), Offset(rect.left, rect.top), p);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left + c, rect.top), p);
    canvas.drawLine(Offset(rect.right - c, rect.top), Offset(rect.right, rect.top), p);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right, rect.top + c), p);
    canvas.drawLine(Offset(rect.left, rect.bottom - c), Offset(rect.left, rect.bottom), p);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left + c, rect.bottom), p);
    canvas.drawLine(Offset(rect.right - c, rect.bottom), Offset(rect.right, rect.bottom), p);
    canvas.drawLine(Offset(rect.right, rect.bottom - c), Offset(rect.right, rect.bottom), p);

    final lineY = rect.top + 6 + progress.value * (rect.height - 12);
    final lineRect = Rect.fromLTWH(rect.left + 6, lineY, rect.width - 12, 2.4);
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, const Color(0xFF9FF7BE).withOpacity(0.9), Colors.transparent],
      ).createShader(lineRect);
    canvas.drawRect(lineRect, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerPainter oldDelegate) => true;
}
