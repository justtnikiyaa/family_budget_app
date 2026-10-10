import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../main_navigation.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _pulseController;

  // Staggered choreographed animations
  late Animation<double> _badgeFade;
  late Animation<Offset> _badgeSlide;

  late Animation<double> _emblemScale;
  late Animation<double> _vectorDraw;

  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;

  late Animation<double> _multiGenFade;
  late Animation<Offset> _multiGenSlide;

  late Animation<double> _avatar1Scale;
  late Animation<double> _avatar2Scale;
  late Animation<double> _avatar3Scale;
  late Animation<double> _avatar4Scale;

  late Animation<double> _progressAnimation;

  final AuthService _authService = AuthService();
  String _statusText = 'Connecting Sri Lankan household node...';

  UserModel? _preloadedUserModel;
  bool _dataLoadComplete = false;

  @override
  void initState() {
    super.initState();

    // Preload user data in background while animation plays
    _preloadUserData();

    // 2500ms duration: perfect sweet spot to experience the rich choreographed animation
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Continuous ambient breathing pulse for the glowing background orbs
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // 1. Top Badge (0.05 -> 0.28)
    _badgeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.04, 0.25, curve: Curves.easeOut),
      ),
    );
    _badgeSlide = Tween<Offset>(
      begin: const Offset(0.0, -0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.04, 0.28, curve: Curves.easeOutBack),
      ),
    );

    // 2. Emblem Card pop-in with spring physics (0.08 -> 0.38)
    _emblemScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.08, 0.38, curve: Curves.easeOutBack),
      ),
    );

    // 3. Dynamic Vector Stroke Draw (0.16 -> 0.78)
    _vectorDraw = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.16, 0.78, curve: Curves.easeInOutCubic),
      ),
    );

    // 4. Title Cascade (0.28 -> 0.52)
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.28, 0.48, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.28, 0.52, curve: Curves.easeOutCubic),
      ),
    );

    // 5. Subtitle Cascade (0.38 -> 0.58)
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.38, 0.54, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.38, 0.58, curve: Curves.easeOutCubic),
      ),
    );

    // 6. Multi-Gen Sync Pill Cascade (0.45 -> 0.68)
    _multiGenFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.45, 0.62, curve: Curves.easeOut),
      ),
    );
    _multiGenSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.45, 0.68, curve: Curves.easeOutBack),
      ),
    );

    // 7. Staggered Avatars Pop (0.50 -> 0.72)
    _avatar1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.50, 0.62, curve: Curves.elasticOut),
      ),
    );
    _avatar2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.54, 0.66, curve: Curves.elasticOut),
      ),
    );
    _avatar3Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.58, 0.70, curve: Curves.elasticOut),
      ),
    );
    _avatar4Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.62, 0.74, curve: Curves.elasticOut),
      ),
    );

    // 8. Progress Bar: smooth ease across 0.06 -> 0.96 with no freeze
    _progressAnimation = Tween<double>(begin: 0.05, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.06, 0.96, curve: Curves.easeInOutCubic),
      ),
    );

    _animController.forward();

    // Orchestrated status text updates
    Timer(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() {
          _statusText = 'Synchronizing household ledger...';
        });
      }
    });

    Timer(const Duration(milliseconds: 1350), () {
      if (mounted) {
        setState(() {
          _statusText = 'Encrypting multi-gen family vault...';
        });
      }
    });

    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _statusText = 'Household vault ready';
        });
      }
    });

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Wait for data load + brief victory hold before seamless navigation
        Future.delayed(const Duration(milliseconds: 150), () {
          _navigateWhenReady();
        });
      }
    });
  }

  void _preloadUserData() async {
    // Wait a tick for Firebase Auth to restore session from disk
    await Future.delayed(const Duration(milliseconds: 300));
    final user = _authService.currentUser;
    if (user != null) {
      try {
        _preloadedUserModel = await _authService.getUserModel(user.uid);
        // Fallback: if Firestore doc missing, build from Auth
        _preloadedUserModel ??= UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Family Member',
        );
      } catch (_) {
        _preloadedUserModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Family Member',
        );
      }
    }
    _dataLoadComplete = true;
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Navigate only after data load is confirmed; poll briefly if still loading
  void _navigateWhenReady() {
    if (!mounted) return;
    if (!_dataLoadComplete) {
      // Data not yet ready – retry after 200ms (max ~2s total wait)
      Future.delayed(const Duration(milliseconds: 200), () => _navigateWhenReady());
      return;
    }
    _navigateNext();
  }

  void _navigateNext() {
    if (!mounted) return;

    if (_preloadedUserModel != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) =>
              MainNavigationScreen(currentUser: _preloadedUserModel!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF8FAFC),
              Color(0xFFF0FDF4),
              Color(0xFFF8FAFC),
            ],
            stops: [0.0, 0.35, 0.75, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Breathing Ambient Glowing Orbs
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final pulse = _pulseController.value;
                return Stack(
                  children: [
                    Positioned(
                      top: -40 + (pulse * 15),
                      right: -30 + (pulse * 10),
                      child: Container(
                        width: 240 + (pulse * 30),
                        height: 240 + (pulse * 30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF14B8A6).withValues(
                            alpha: 0.06 + (pulse * 0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF14B8A6).withValues(
                                alpha: 0.10 + (pulse * 0.06),
                              ),
                              blurRadius: 80,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 60 - (pulse * 10),
                      left: -40 + (pulse * 10),
                      child: Container(
                        width: 220 + (pulse * 25),
                        height: 220 + (pulse * 25),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0F766E).withValues(
                            alpha: 0.05 + (pulse * 0.04),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F766E).withValues(
                                alpha: 0.08 + (pulse * 0.05),
                              ),
                              blurRadius: 90,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            SafeArea(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final progressVal = _progressAnimation.value.clamp(0.0, 1.0);
                  final progressPercent = (progressVal * 100).toInt();

                  // Subtle dynamic floating physics for the emblem
                  final floatY = sin(_animController.value * pi * 3.5) * 4.0;

                  return Column(
                    children: [
                      const SizedBox(height: 18),

                      // 1. Top Sri Lanka National Finance Badge (Fade + Slide)
                      FadeTransition(
                        opacity: _badgeFade,
                        child: SlideTransition(
                          position: _badgeSlide,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF14B8A6).withValues(alpha: 0.35),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F766E).withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🇱🇰', style: TextStyle(fontSize: 13)),
                                SizedBox(width: 6),
                                Text(
                                  'SMART SRI LANKAN FAMILY BUDGET',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F766E),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // 2. Center Crisp Glassmorphic Emblem Card with Live Vector Drawing
                      Transform.translate(
                        offset: Offset(0, floatY),
                        child: ScaleTransition(
                          scale: _emblemScale,
                          child: Center(
                            child: Container(
                              width: 122,
                              height: 122,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(34),
                                border: Border.all(
                                  color: const Color(0xFF14B8A6).withValues(alpha: 0.28),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F766E).withValues(alpha: 0.15),
                                    blurRadius: 36,
                                    spreadRadius: 4,
                                    offset: const Offset(0, 14),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomPaint(
                                  size: const Size(66, 66),
                                  painter: _AnimatedShieldHouseGrowthPainter(
                                    progress: _vectorDraw.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 3. App Title (Smart Family Budget)
                      FadeTransition(
                        opacity: _titleFade,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                letterSpacing: -0.5,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Smart Family\n',
                                  style: TextStyle(color: Color(0xFF0F172A)),
                                ),
                                TextSpan(
                                  text: 'Budget',
                                  style: TextStyle(
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 4. Subtitle: SHARED HOUSEHOLD FINANCES
                      FadeTransition(
                        opacity: _subtitleFade,
                        child: SlideTransition(
                          position: _subtitleSlide,
                          child: const Text(
                            'SHARED HOUSEHOLD FINANCES',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.2,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 5. Multi-Gen Sync Pill with Staggered Avatar Pop
                      FadeTransition(
                        opacity: _multiGenFade,
                        child: SlideTransition(
                          position: _multiGenSlide,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildAnimatedAvatarOverlap(),
                                const SizedBox(width: 10),
                                const Text(
                                  'Multi-Gen Sync',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Pulsing green live indicator
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.6),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 4),

                      // 6. Smooth Real-Time Progress Bar & Percentage
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF0F766E),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: Text(
                                        _statusText,
                                        key: ValueKey<String>(_statusText),
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '$progressPercent%',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Color(0xFF0F766E),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Sleek Glowing Progress Track
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Stack(
                                children: [
                                  // Background Track
                                  Container(
                                    height: 5.5,
                                    width: double.infinity,
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  // Animated Active Gradient Fill with Glowing Cap
                                  FractionallySizedBox(
                                    widthFactor: progressVal,
                                    child: Container(
                                      height: 5.5,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF2DD4BF),
                                            Color(0xFF14B8A6),
                                            Color(0xFF0F766E),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF14B8A6).withValues(alpha: 0.5),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 7. Security Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Secured by Cloud Firestore • Multi-Device Sync',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Staggered Animated Member Avatars
  Widget _buildAnimatedAvatarOverlap() {
    return SizedBox(
      width: 66,
      height: 22,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: ScaleTransition(
              scale: _avatar1Scale,
              child: _buildAvatarCircle(label: 'M', color: const Color(0xFF0D9488)),
            ),
          ),
          Positioned(
            left: 14,
            child: ScaleTransition(
              scale: _avatar2Scale,
              child: _buildAvatarCircle(label: 'F', color: const Color(0xFF0284C7)),
            ),
          ),
          Positioned(
            left: 28,
            child: ScaleTransition(
              scale: _avatar3Scale,
              child: _buildAvatarCircle(label: 'K', color: const Color(0xFFF59E0B)),
            ),
          ),
          Positioned(
            left: 42,
            child: ScaleTransition(
              scale: _avatar4Scale,
              child: _buildAvatarCircle(label: '+', color: const Color(0xFF8B5CF6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCircle({required String label, required Color color}) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Dynamic Vector Painter that draws the Shield, House, and Rising Growth Trend Line in real time!
class _AnimatedShieldHouseGrowthPainter extends CustomPainter {
  final double progress;

  _AnimatedShieldHouseGrowthPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sub-progress mapping for phased drawing
    // Phase 1 (0.00 -> 0.40): Shield
    final shieldT = (progress / 0.40).clamp(0.0, 1.0);
    // Phase 2 (0.25 -> 0.65): House
    final houseT = ((progress - 0.25) / 0.40).clamp(0.0, 1.0);
    // Phase 3 (0.45 -> 1.00): Trend Line & Peak Dot
    final trendT = ((progress - 0.45) / 0.55).clamp(0.0, 1.0);

    // 1. Draw Shield
    final shieldPath = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..cubicTo(w * 0.75, h * 0.1, w * 0.9, h * 0.22, w * 0.9, h * 0.45)
      ..cubicTo(w * 0.9, h * 0.7, w * 0.65, h * 0.88, w * 0.5, h * 0.95)
      ..cubicTo(w * 0.35, h * 0.88, w * 0.1, h * 0.7, w * 0.1, h * 0.45)
      ..cubicTo(w * 0.1, h * 0.22, w * 0.25, h * 0.1, w * 0.5, h * 0.1)
      ..close();

    // Shield Wash
    final shieldFillPaint = Paint()
      ..color = const Color(0xFFF0FDF4).withValues(alpha: shieldT)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shieldPath, shieldFillPaint);

    // Shield Progressive Stroke
    final shieldStrokePaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    if (shieldT > 0.0) {
      final metrics = shieldPath.computeMetrics();
      for (final metric in metrics) {
        final extracted = metric.extractPath(0.0, metric.length * shieldT);
        canvas.drawPath(extracted, shieldStrokePaint);
      }
    }

    // 2. Draw House
    if (houseT > 0.0) {
      final housePaint = Paint()
        ..color = const Color(0xFF0F766E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final housePath = Path()
        // Roof
        ..moveTo(w * 0.32, h * 0.52)
        ..lineTo(w * 0.5, h * 0.38)
        ..lineTo(w * 0.68, h * 0.52)
        // Body
        ..moveTo(w * 0.36, h * 0.52)
        ..lineTo(w * 0.36, h * 0.68)
        ..lineTo(w * 0.64, h * 0.68)
        ..lineTo(w * 0.64, h * 0.52)
        // Door
        ..moveTo(w * 0.45, h * 0.68)
        ..lineTo(w * 0.45, h * 0.56)
        ..lineTo(w * 0.55, h * 0.56)
        ..lineTo(w * 0.55, h * 0.68);

      final metrics = housePath.computeMetrics();
      for (final metric in metrics) {
        final extracted = metric.extractPath(0.0, metric.length * houseT);
        canvas.drawPath(extracted, housePaint);
      }
    }

    // 3. Draw Rising Growth Trend Line
    if (trendT > 0.0) {
      final trendPaint = Paint()
        ..color = const Color(0xFF14B8A6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final trendPath = Path()
        ..moveTo(w * 0.22, h * 0.64)
        ..lineTo(w * 0.38, h * 0.52)
        ..lineTo(w * 0.52, h * 0.58)
        ..lineTo(w * 0.74, h * 0.34);

      final metrics = trendPath.computeMetrics();
      for (final metric in metrics) {
        final currentLength = metric.length * trendT;
        final extracted = metric.extractPath(0.0, currentLength);
        canvas.drawPath(extracted, trendPaint);

        // Dynamic Tangent Point for Moving Tip / Arrowhead
        final tangent = metric.getTangentForOffset(currentLength);
        if (tangent != null) {
          // Glow Dot at current head of line
          final tipGlow = Paint()
            ..color = const Color(0xFF14B8A6).withValues(alpha: 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
          canvas.drawCircle(tangent.position, 6.0, tipGlow);

          final tipOuter = Paint()..color = const Color(0xFF0F766E);
          final tipInner = Paint()..color = Colors.white;
          canvas.drawCircle(tangent.position, 4.2, tipOuter);
          canvas.drawCircle(tangent.position, 2.2, tipInner);
        }
      }

      // If trend line is completed, draw final arrowhead
      if (trendT >= 0.95) {
        final arrowPaint = Paint()
          ..color = const Color(0xFF14B8A6)
          ..style = PaintingStyle.fill;

        final arrowPath = Path()
          ..moveTo(w * 0.74, h * 0.34)
          ..lineTo(w * 0.66, h * 0.34)
          ..lineTo(w * 0.74, h * 0.42)
          ..close();

        canvas.drawPath(arrowPath, arrowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedShieldHouseGrowthPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
