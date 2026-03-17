import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:just_audio/just_audio.dart';

import '../domain/surface_type.dart';
import 'painters/shader_painter.dart';
import '../../../core/theme/app_colors.dart';

class TactileSurfaceScreen extends StatefulWidget {
  final SurfaceType type;

  const TactileSurfaceScreen({
    super.key,
    required this.type,
  });

  @override
  State<TactileSurfaceScreen> createState() => _TactileSurfaceScreenState();
}

class _TactileSurfaceScreenState extends State<TactileSurfaceScreen> with TickerProviderStateMixin {
  bool _soundEnabled = true;

  // Shader program & instance
  ui.FragmentProgram? _program;
  ui.FragmentShader? _shader;
  bool _shaderLoaded = false;

  // Touch data
  final List<RippleData> _ripples = [];       // For water ripples

  // Audio players
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Animation
  late AnimationController _tickController;
  Timer? _cleanupTimer;
  final Stopwatch _stopwatch = Stopwatch();

  // Constants
  static const int _maxRipples = 10;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();

    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _cleanupTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      _cleanupOldData();
    });

    _loadShader();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _ambientPlayer.setAsset('assets/audio/ocean_base.mp3');
      await _ambientPlayer.setLoopMode(LoopMode.all);
      await _sfxPlayer.setAsset('assets/audio/water_drop.wav');
      if (_soundEnabled && mounted) {
        _ambientPlayer.play();
      }
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  Future<void> _loadShader() async {
    final shaderPath = 'shaders/water.frag';

    try {
      _program = await ui.FragmentProgram.fromAsset(shaderPath);
      _shader = _program!.fragmentShader();
      if (mounted) {
        setState(() => _shaderLoaded = true);
      }
    } catch (e) {
      debugPrint('Failed to load shader: $e');
    }
  }

  void _cleanupOldData() {
    final now = DateTime.now();
    bool needsUpdate = false;

    // Prune ripples (lifespan ~4s)
    final initRipples = _ripples.length;
    _ripples.removeWhere((r) => now.difference(r.startTime).inMilliseconds > 4000);
    if (_ripples.length != initRipples) needsUpdate = true;

    if (needsUpdate && mounted) setState(() {});
  }

  @override
  void dispose() {
    _tickController.dispose();
    _cleanupTimer?.cancel();
    _shader?.dispose();
    _stopwatch.stop();
    _ambientPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  // === GESTURE HANDLERS ===
  void _handlePanStart(DragStartDetails details) {
    _addRipple(details.localPosition);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_ripples.isEmpty ||
        (details.localPosition - _ripples.last.center).distance > 40) {
      _addRipple(details.localPosition);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    HapticFeedback.lightImpact();
  }

  void _handleTapDown(TapDownDetails details) {
    _addRipple(details.localPosition);
  }

  void _addRipple(Offset position) {
    setState(() {
      _ripples.add(RippleData(
        center: position,
        startTime: DateTime.now(),
      ));
      if (_ripples.length > _maxRipples) {
        _ripples.removeAt(0);
      }
    });
    
    // Haptics and sound
    HapticFeedback.mediumImpact();
    if (_soundEnabled) {
      _sfxPlayer.seek(Duration.zero);
      _sfxPlayer.play();
    }
  }

  // === SHADER UNIFORM MANAGEMENT ===

  void _setRippleUniforms(ui.FragmentShader shader, Size size) {
    final time = _stopwatch.elapsedMilliseconds / 1000.0;

    // uResolution (vec2)
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    // uTime
    shader.setFloat(2, time);
    // uRippleCount
    shader.setFloat(3, _ripples.length.toDouble());
    // uRipples[10] (vec3 × 10 = 30 floats) = indices 4-33
    for (int i = 0; i < _maxRipples; i++) {
      if (i < _ripples.length) {
        final ripple = _ripples[i];
        final startTime = _stopwatch.elapsedMilliseconds / 1000.0 -
            DateTime.now().difference(ripple.startTime).inMilliseconds / 1000.0;
        shader.setFloat(4 + i * 3, ripple.center.dx);
        shader.setFloat(4 + i * 3 + 1, ripple.center.dy);
        shader.setFloat(4 + i * 3 + 2, startTime);
      } else {
        shader.setFloat(4 + i * 3, 0);
        shader.setFloat(4 + i * 3 + 1, 0);
        shader.setFloat(4 + i * 3 + 2, -10); // Very old = invisible
      }
    }
  }

  // === BUILD ===
  Widget _buildPainter() {
    if (!_shaderLoaded || _shader == null) {
      return const SizedBox.expand();
    }

    return AnimatedBuilder(
      animation: _tickController,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final shader = _program!.fragmentShader();

            // Set uniforms
            _setRippleUniforms(shader, size);

            return CustomPaint(
              painter: ShaderPainter(shader: shader),
              size: Size.infinite,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppColors.bgDark;
    final Color uiColor = Colors.white;
    final double uiOpacity = 0.5;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. The Interactive Surface Layer
          GestureDetector(
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            onTapDown: _handleTapDown,
            behavior: HitTestBehavior.opaque,
            child: SizedBox.expand(
              child: _buildPainter(),
            ),
          ),

          // 2. Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: uiColor, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ).animate().fadeIn(duration: 800.ms),
                  
                  Text(
                    widget.type.title.toUpperCase(),
                    style: TextStyle(
                      color: uiColor.withValues(alpha: uiOpacity),
                      fontSize: 14,
                      letterSpacing: 4.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(duration: 800.ms, delay: 200.ms),

                  IconButton(
                    icon: Icon(
                      _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      color: uiColor.withValues(alpha: uiOpacity - 0.1),
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() => _soundEnabled = !_soundEnabled);
                      HapticFeedback.lightImpact();
                    },
                  ).animate().fadeIn(duration: 800.ms),
                ],
              ),
            ),
          ),

          // 3. Helper Text (Bottom)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                widget.type.helperText,
                style: TextStyle(
                  color: uiColor.withValues(alpha: 0.35),
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ).animate()
               .fadeIn(duration: 1.seconds, delay: 1.seconds)
               .then()
               .fadeOut(duration: 3.seconds, delay: 2.seconds),
            ),
          ),
        ],
      ),
    );
  }
}

// === DATA CLASSES ===

class RippleData {
  final Offset center;
  final DateTime startTime;

  RippleData({required this.center, required this.startTime});
}

class PathData {
  final List<Offset> points;
  final DateTime startTime;

  PathData({required this.points, required this.startTime});
}
